#!/bin/bash

# Deployment initialization script
# Sets up the repository for deployment

set -e

echo "=== Initializing gsAgent for Deployment ==="

# Create output directory structure
mkdir -p output/.claude/skills output/.opencode/skills output/.github/skills output/.gemini/skills

# Create output directories for agents
echo "Creating output directories..."
mkdir -p output/.claude/agents output/.opencode/agents output/.github/agents output/.gemini/agents

echo "Repository ready for deployment!"
echo ""
echo "Next steps:"
echo "1. Add your agent JSON files to the agents/ directory"
echo "2. Add your skill JSON files to the skills/ directory"
echo "3. Run: python compiler/compile.py --all"
echo "4. Commit and push to trigger deployment"
echo ""
echo "GitHub Actions will:"
echo "- Compile agents for each provider (claude, copilot, opencode)"
echo "- Deploy to separate branches: agents-claude, agents-copilot, agents-opencode"
echo "- Create release artifacts for each provider"