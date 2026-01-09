## Source

Derived from `https://docs.coderabbit.ai/cli/codex-integration`.

## What this integration enables

- Run CodeRabbit CLI from within a Codex session.
- Use CodeRabbit findings as context for Codex to apply fixes.
- Prefer `--prompt-only` for token-efficient, AI-friendly output.

## Key commands

- Install CLI (global): `curl -fsSL https://cli.coderabbit.ai/install.sh | sh`
- Restart shell (example): `source ~/.zshrc`
- Authenticate (must run inside Codex): `coderabbit auth login`
- Verify auth: `coderabbit auth status`

## Recommended review loop

- Run review: `coderabbit --prompt-only`
- Wait for completion (often 8–30+ minutes depending on scope).
- Apply fixes from findings; re-run until critical issues are resolved.

## Useful flags

- Detailed output: `coderabbit --plain`
- Review only uncommitted changes: `--type uncommitted`
- Configure base branch: `--base main` / `--base develop`

## Troubleshooting cues (from the guide)

- If CodeRabbit finds nothing: check auth, check `git status`, confirm you're reviewing code files, try `--plain`.
- If Codex doesn't apply fixes: check `coderabbit auth status`, ensure `--prompt-only`, be explicit (“fix the issues found by CodeRabbit”), confirm review finished, and allow long runtime.
