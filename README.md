# CodeRabbit Codex Integration Skill

A Codex skill that integrates CodeRabbit CLI for in-loop code review: implement changes, run CodeRabbit review, apply fixes based on findings.

## Installation

```bash
./install.sh
```

Options:
- `--source <path>` - Path to `.skill` package or skill directory
- `--dest <dir>` - Destination skills directory (default: `$CODEX_HOME/skills`)
- `--force` - Replace existing installation with backup

Restart Codex after installation.

## Usage

### Prerequisites

1. Install CodeRabbit CLI:
   ```bash
   curl -fsSL https://cli.coderabbit.ai/install.sh | sh
   ```

2. Authenticate inside Codex:
   ```bash
   coderabbit auth login
   coderabbit auth status  # verify
   ```

### Review → Fix Loop

Run review with AI-friendly output:
```bash
coderabbit --prompt-only
```

Or use the helper script:
```bash
scripts/run_coderabbit_prompt_only.sh
```

Scope controls:
- `--type uncommitted` - Review uncommitted changes only
- `--base main` - Configure base branch

## Project Structure

```
├── install.sh                      # Installation script
├── coderabbit-codex-integration/
│   ├── SKILL.md                    # Skill definition
│   ├── scripts/
│   │   └── run_coderabbit_prompt_only.sh
│   └── references/
│       └── coderabbit-docs-codex-integration.md
└── dist/
    └── coderabbit-codex-integration.skill  # Packaged skill
```

## License

MIT
