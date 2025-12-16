#!/usr/bin/env node

const { GoogleGenerativeAI } = require('@google/generative-ai');
const fs = require('fs');
const path = require('path');

// Configuration
const PROJECT_ID = process.env.GOOGLE_CLOUD_PROJECT || '136334456295';
const API_KEY = process.env.GEMINI_API_KEY || process.env.GOOGLE_API_KEY;
const MODEL_NAME = process.env.GEMINI_MODEL || 'gemini-2.0-flash-exp';

if (!API_KEY) {
  console.error('Error: GEMINI_API_KEY environment variable is required');
  process.exit(1);
}

const genAI = new GoogleGenerativeAI(API_KEY);

// Parse command line arguments for @file/@directory syntax
function parsePromptWithFiles(args) {
  let prompt = '';
  const filesToInclude = [];

  for (const arg of args) {
    if (arg.startsWith('@')) {
      const filePath = arg.substring(1);
      filesToInclude.push(filePath);
    } else {
      prompt += arg + ' ';
    }
  }

  return { prompt: prompt.trim(), filesToInclude };
}

// Read file or directory contents
function readFileOrDirectory(filePath) {
  const fullPath = path.resolve(filePath);

  if (!fs.existsSync(fullPath)) {
    return `[Error: File or directory not found: ${filePath}]`;
  }

  const stats = fs.statSync(fullPath);

  if (stats.isFile()) {
    try {
      const content = fs.readFileSync(fullPath, 'utf-8');
      return `\n--- File: ${filePath} ---\n${content}\n--- End of ${filePath} ---\n`;
    } catch (err) {
      return `[Error reading file ${filePath}: ${err.message}]`;
    }
  } else if (stats.isDirectory()) {
    let dirContent = `\n--- Directory: ${filePath} ---\n`;
    try {
      const files = getAllFiles(fullPath);
      for (const file of files) {
        const relativePath = path.relative(process.cwd(), file);
        const content = fs.readFileSync(file, 'utf-8');
        dirContent += `\n=== ${relativePath} ===\n${content}\n`;
      }
      dirContent += `--- End of directory ${filePath} ---\n`;
      return dirContent;
    } catch (err) {
      return `[Error reading directory ${filePath}: ${err.message}]`;
    }
  }

  return '';
}

// Recursively get all files in a directory
function getAllFiles(dirPath, arrayOfFiles = []) {
  const files = fs.readdirSync(dirPath);

  files.forEach(file => {
    const filePath = path.join(dirPath, file);

    // Skip node_modules, .git, and other common directories
    if (file === 'node_modules' || file === '.git' || file === 'dist' || file === 'build' || file.startsWith('.')) {
      return;
    }

    if (fs.statSync(filePath).isDirectory()) {
      arrayOfFiles = getAllFiles(filePath, arrayOfFiles);
    } else {
      // Only include text files
      const ext = path.extname(file);
      const textExtensions = ['.js', '.ts', '.tsx', '.jsx', '.json', '.md', '.sql', '.txt', '.css', '.html', '.xml', '.yaml', '.yml', '.env', '.swift', '.plist', '.xcconfig'];
      if (textExtensions.includes(ext) || !ext) {
        arrayOfFiles.push(filePath);
      }
    }
  });

  return arrayOfFiles;
}

async function main() {
  const args = process.argv.slice(2);

  if (args.length === 0) {
    console.log('Usage: node gemini-api-client.js "@file.js @directory/ Your prompt here"');
    console.log('Example: node gemini-api-client.js "@src/ Analyze this codebase"');
    process.exit(1);
  }

  const { prompt, filesToInclude } = parsePromptWithFiles(args);

  let fullPrompt = '';

  // Include file contents
  for (const file of filesToInclude) {
    fullPrompt += readFileOrDirectory(file);
  }

  // Add user prompt
  fullPrompt += `\n\nUser Request: ${prompt}`;

  try {
    const model = genAI.getGenerativeModel({ model: MODEL_NAME });

    console.log(`Using model: ${MODEL_NAME}`);
    console.log(`Project ID: ${PROJECT_ID}`);
    console.log('Generating response...\n');

    const result = await model.generateContent(fullPrompt);
    const response = await result.response;
    const text = response.text();

    console.log(text);

    // Usage statistics
    if (response.usageMetadata) {
      console.log('\n--- Usage Statistics ---');
      console.log(`Prompt tokens: ${response.usageMetadata.promptTokenCount || 'N/A'}`);
      console.log(`Response tokens: ${response.usageMetadata.candidatesTokenCount || 'N/A'}`);
      console.log(`Total tokens: ${response.usageMetadata.totalTokenCount || 'N/A'}`);
    }

  } catch (error) {
    console.error('Error calling Gemini API:', error.message);
    if (error.response) {
      console.error('Response data:', error.response.data);
    }
    process.exit(1);
  }
}

main();
