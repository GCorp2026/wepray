# Gemini CLI Setup

This project is configured to use Google's Gemini API for AI-powered development assistance.

## Local Project Setup

### Files Installed

1. **gemini-api-client.cjs** - Node.js script that interfaces with Gemini API
2. **gemini-backup.sh** - Backup script that can be used locally
3. **.env** - Environment configuration (contains API key - not committed to git)

### Dependencies

The project requires `@google/generative-ai` package. Install it with:

```bash
npm install @google/generative-ai
```

### Usage in This Project

You can use the Gemini CLI locally with:

```bash
# Using the backup script
./gemini-backup.sh "Your prompt here"

# Or directly with node
node gemini-api-client.cjs "Your prompt here"

# Include files or directories in your prompt
node gemini-api-client.cjs "@WePray/ Analyze this codebase"
node gemini-api-client.cjs "@ContentView.swift What does this view do?"
```

## Global Setup (All GitHub Projects)

### Installation

A global Gemini CLI has been installed at `~/bin/gemini` that can be used from any directory.

### Usage

After opening a new terminal (or running `source ~/.zshrc`), you can use:

```bash
# From any directory
gemini "Your prompt here"

# Include files from current directory
gemini "@README.md Summarize this file"

# Include entire directories
gemini "@WePray/ Review this code"
```

### How It Works

The global script:
1. Looks for `@google/generative-ai` package in any of your GitHub projects
2. Uses the package from the first project where it's found
3. Runs the Gemini API client with your prompt

### Configuration

The following environment variables are configured:

- `GEMINI_API_KEY` - Your Google API key
- `GEMINI_MODEL` - Model to use (default: gemini-2.0-flash-exp)
- `GOOGLE_CLOUD_PROJECT` - Your Google Cloud project ID

These are set in both:
- Local `.env` file (for this project)
- `~/.zshrc` (globally)
- `~/bin/gemini` script (fallback)

## Features

- **File/Directory Support**: Use `@filename` or `@directory/` syntax to include file contents in prompts
- **Automatic Model Selection**: Uses latest Gemini model (gemini-2.0-flash-exp)
- **Token Usage Stats**: Shows token counts after each response
- **Smart Path Resolution**: Works from any directory
- **Swift Support**: Includes .swift, .plist, and .xcconfig files in directory scans

## Examples

```bash
# Simple question
gemini "What is SwiftUI?"

# Code review
gemini "@ContentView.swift Review this SwiftUI view"

# Multiple files
gemini "@WePrayApp.swift @ContentView.swift Explain how this app works"

# Entire codebase analysis
gemini "@WePray/ Analyze the project structure"
```

## Troubleshooting

If you get "command not found: gemini":
1. Open a new terminal window, or
2. Run: `source ~/.zshrc`

If you get "Error: @google/generative-ai is not installed":
1. Run `npm install @google/generative-ai` in your project
2. Or use the local scripts instead of the global command

## Security Note

The `.env` file contains your API key and is excluded from git via `.gitignore`. Never commit API keys to version control.
