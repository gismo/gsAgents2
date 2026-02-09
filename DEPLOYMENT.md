# gsAgent Deployment

This repository is ready for deployment following the gsAgents pattern.

## Current Status

- ✅ **Repository structure**: Matches gsAgents pattern
- ✅ **Compilation engine**: Complete with provider templates
- ✅ **Validation system**: JSON schema validation
- ✅ **GitHub Actions**: Deployment workflow configured
- ✅ **Agent configurations**: 2 agents, 1 skill compiled

## Key Features

### Unified JSON Format
- Single source of truth for agent configurations
- Provider-specific compilation handled automatically
- Supports all major AI assistants

### Multi-Provider Support
- Claude Code: `.claude/` directory
- OpenCode: `.opencode/` directory
- GitHub Copilot: `.github/` directory
- Gemini CLI: `.gemini/` directory (skills only)

### Automated Deployment
- GitHub Actions triggers on push to main
- Compiles agents for each provider
- Deploys to separate branches
- Creates release artifacts

## Quick Deployment

1. **Initialize deployment:**
   ```bash
   ./init-deploy.sh
   ```

2. **Add your configurations:**
   - Place agent JSON files in `agents/`
   - Place skill JSON files in `skills/`

3. **Test compilation:**
   ```bash
   python3 compiler/compile.py --validate
   python3 compiler/compile.py --all
   ```

4. **Deploy:**
   - Commit and push to trigger GitHub Actions
   - Check workflow status in Actions tab

## Repository Structure

```
gsAgent/
├── agents/                 # Universal agent JSON files
├── skills/                 # Universal skill JSON files
├── compiler/               # Compilation engine
│   ├── compile.py          # Main compiler script
│   ├── templates/          # Provider templates
│   └── schema/            # JSON schemas
├── output/                 # Compiled outputs
├── .github/workflows/      # GitHub Actions
├── AGENTS.md              # Instructions
├── README.md              # This file
└── requirements.txt       # Python dependencies
```

## Available Agents

- **security-auditor.json** - Security-focused code auditor
- **code-reviewer.json** - Code review and quality assurance

## Available Skills

- **docx-creation.json** - Document creation and formatting

## Next Steps

1. **Review agent configurations** in `agents/` directory
2. **Add your own agents** following the JSON schema
3. **Test compilation** with `python3 compiler/compile.py --all`
4. **Push to trigger deployment** to separate provider branches
5. **Monitor GitHub Actions** for deployment status

## Support

For issues with compilation or deployment, check:
- GitHub Actions workflow logs
- Compilation output in `output/` directory
- JSON schema validation errors

This repository follows the same deployment pattern as the successful gsAgents repository, ensuring reliable multi-provider agent distribution.