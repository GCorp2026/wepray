#!/bin/bash

# Backup Gemini API Client Script
# Uses custom Google Cloud project when @google/gemini-cli quota is exceeded

# Configuration
export GOOGLE_CLOUD_PROJECT="136334456295"
export GEMINI_MODEL="${GEMINI_MODEL:-gemini-1.5-flash}"
export GEMINI_API_KEY="AIzaSyBmwgQ5-GS39dmCc17p3uLaqm8svYM6-l0"

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed"
    exit 1
fi

# Check if the client script exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIENT_SCRIPT="$SCRIPT_DIR/gemini-api-client.cjs"

if [ ! -f "$CLIENT_SCRIPT" ]; then
    echo "Error: gemini-api-client.cjs not found at $CLIENT_SCRIPT"
    exit 1
fi

# Check if @google/generative-ai is installed
if ! node -e "require('@google/generative-ai')" 2>/dev/null; then
    echo "Installing @google/generative-ai..."
    npm install @google/generative-ai
fi

# Run the client with all arguments passed through
node "$CLIENT_SCRIPT" "$@"
