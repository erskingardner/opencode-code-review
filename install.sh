#!/bin/bash
# Install opencode-code-review to global OpenCode config

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config/opencode"

echo "Installing opencode-code-review..."

# Create directories if needed
mkdir -p "${CONFIG_DIR}/agents"
mkdir -p "${CONFIG_DIR}/commands"
mkdir -p "${CONFIG_DIR}/plugins"

# Copy agents
echo "Copying agents..."
cp "${SCRIPT_DIR}/agents/"*.md "${CONFIG_DIR}/agents/"

# Copy command
echo "Copying command..."
cp "${SCRIPT_DIR}/commands/"*.md "${CONFIG_DIR}/commands/"

# Copy plugin (optional)
if [ -f "${SCRIPT_DIR}/plugins/code-review.ts" ]; then
  echo "Copying plugin..."
  cp "${SCRIPT_DIR}/plugins/code-review.ts" "${CONFIG_DIR}/plugins/"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Usage: In OpenCode TUI, on a PR branch, run:"
echo "  /code-review"
echo ""
echo "Or with --comment to post to GitHub:"
echo "  /code-review --comment"
echo ""
echo "Note: Make sure you have 'gh' CLI installed and authenticated."
