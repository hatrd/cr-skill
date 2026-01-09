---
name: coderabbit-codex-integration
description: Run CodeRabbit CLI inside Codex to review local code changes and implement fixes from CodeRabbit findings. Use for setup (install/auth via `coderabbit auth login/status`), running reviews in `--prompt-only` mode, iterating review→fix→re-run, and troubleshooting (`coderabbit --plain`, `--type uncommitted`, `--base main/develop`).
---

# CodeRabbit Codex Integration

## Overview

Enable Codex to execute CodeRabbit CLI in-loop: implement changes, run a CodeRabbit review, then apply fixes based on CodeRabbit’s context-rich findings.

## Workflow Decision Tree

- If `coderabbit` is not installed, install it first.
- If `coderabbit` is installed but not authenticated, authenticate inside the current Codex session.
- Otherwise, run the review → fix loop (prefer `--prompt-only`).

## 1) Install CodeRabbit CLI (one-time)

Install globally:

```sh
curl -fsSL https://cli.coderabbit.ai/install.sh | sh
```

Restart your shell (example):

```sh
source ~/.zshrc
```

## 2) Authenticate CodeRabbit inside Codex

Authentication must be performed inside the same Codex instance that will run `coderabbit`, and typically requires network approval/escalation.

Run:

```sh
coderabbit auth login
```

If Codex doesn’t surface an auth URL, request it explicitly and complete the login in your browser, then paste the token back. Expect that Codex may re-run `coderabbit auth login`; reuse the existing token if it still works.

Verify authentication:

```sh
coderabbit auth status
```

## 3) Review → Fix loop (recommended)

Prefer AI-friendly output:

- Run directly: `coderabbit --prompt-only`
- Or run and save output: `scripts/run_coderabbit_prompt_only.sh`

Let the review finish; it may take 8–30+ minutes depending on the change size. After the review completes:

- Read the `--prompt-only` output and convert it into a checklist of findings.
- If the output ends with `Review completed ✔` and there are no `=============`-separated finding blocks above it, CodeRabbit didn’t report any issues and you can safely stop the review loop.
- Implement fixes with minimal, focused changes.
- Continue until all important findings are addressed; if work stops early, explicitly continue with remaining findings.
- Re-run CodeRabbit and repeat until critical issues are resolved.

### Scope controls

- Review uncommitted changes only: `--type uncommitted`
- Configure base branch: `--base main` or `--base develop`

## Prompt templates (copy/paste)

```text
Please implement <FEATURE> and then run coderabbit --prompt-only,
let it run as long as it needs and fix any issues.
```

```text
Implement <FEATURE>.
Then run coderabbit. Once it completes, let it take as long as
it needs to fix any issues it might find.
```

## 4) Troubleshooting

### CodeRabbit not finding issues

- Check authentication (`coderabbit auth login`).
- Verify `git status` (reviews focus on tracked changes).
- Confirm you’re reviewing code files (not only docs/config).
- Try detailed output: `coderabbit --plain`.

### Codex not applying fixes

- Check authentication: `coderabbit auth status` (renew if needed).
- Ensure you use `coderabbit --prompt-only` for better AI integration.
- Provide explicit instructions (“fix the issues found by CodeRabbit”).
- Confirm CodeRabbit finished running (it may still be analyzing).
- If it seems to stop early, instruct “let CodeRabbit take as long as it takes”.

## Notes

- CodeRabbit can read an `agents.md` file for additional review context (coding standards, architecture preferences). This is a Pro paid plan feature.
- For additional details, read `references/coderabbit-docs-codex-integration.md`.
