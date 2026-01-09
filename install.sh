#!/usr/bin/env bash
set -euo pipefail

skill_name="coderabbit-codex-integration"

usage() {
  cat <<'EOF'
Usage: ./install.sh [--source <path>] [--dest <skills-dir>] [--force]

Installs the Codex skill into $CODEX_HOME/skills (default: ~/.codex/skills).

Options:
  --source <path>   Path to a `.skill` package or a skill directory.
                    Default: `dist/coderabbit-codex-integration.skill` if present,
                    otherwise `./coderabbit-codex-integration/`.
  --dest <dir>      Destination skills directory (defaults to `$CODEX_HOME/skills`).
  --force           If destination exists, move it to a timestamped backup and reinstall.
  -h, --help        Show this help.
EOF
}

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_path=""
dest_root=""
force=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      if [[ $# -lt 2 || -z "${2:-}" || "${2:-}" == "-"* ]]; then
        echo "Missing or invalid value for --source" >&2
        usage >&2
        exit 2
      fi
      source_path="$2"
      shift 2
      ;;
    --dest)
      if [[ $# -lt 2 || -z "${2:-}" || "${2:-}" == "-"* ]]; then
        echo "Missing or invalid value for --dest" >&2
        usage >&2
        exit 2
      fi
      dest_root="$2"
      shift 2
      ;;
    --force)
      force=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$dest_root" ]]; then
  codex_home="${CODEX_HOME:-$HOME/.codex}"
  dest_root="$codex_home/skills"
fi

if [[ -z "$source_path" ]]; then
  if [[ -f "$repo_root/dist/$skill_name.skill" ]]; then
    source_path="$repo_root/dist/$skill_name.skill"
  else
    source_path="$repo_root/$skill_name"
  fi
fi

mkdir -p "$dest_root"
dest_dir="$dest_root/$skill_name"

if [[ -e "$dest_dir" ]]; then
  if [[ $force -ne 1 ]]; then
    echo "Destination already exists: $dest_dir" >&2
    echo "Re-run with --force to replace (existing will be moved to a backup)." >&2
    exit 1
  fi
  ts="$(date +%Y%m%d%H%M%S)"
  backup="${dest_dir}.bak.${ts}"
  mv "$dest_dir" "$backup"
  echo "Moved existing skill to: $backup" >&2
fi

if [[ -f "$source_path" ]]; then
  python3 - <<'PY' "$source_path" "$dest_root"
import os
import sys
import zipfile

src = sys.argv[1]
dest_root = sys.argv[2]

dest_root_real = os.path.realpath(dest_root)
os.makedirs(dest_root_real, exist_ok=True)

with zipfile.ZipFile(src, "r") as zip_file:
    for info in zip_file.infolist():
        extracted_path = os.path.realpath(os.path.join(dest_root_real, info.filename))
        if extracted_path == dest_root_real or extracted_path.startswith(dest_root_real + os.sep):
            continue
        raise SystemExit("Error: archive contains files outside the destination.")
    zip_file.extractall(dest_root_real)
PY
elif [[ -d "$source_path" ]]; then
  python3 - <<'PY' "$source_path" "$dest_dir"
import os
import shutil
import sys

src = sys.argv[1]
dest = sys.argv[2]

if not os.path.isdir(src):
    raise SystemExit(f"Error: source directory not found: {src}")
if os.path.exists(dest):
    raise SystemExit(f"Error: destination already exists: {dest}")

shutil.copytree(src, dest)
PY
else
  echo "Source not found: $source_path" >&2
  exit 1
fi

if [[ ! -f "$dest_dir/SKILL.md" ]]; then
  echo "Install failed: missing SKILL.md at $dest_dir/SKILL.md" >&2
  exit 1
fi

if [[ -f "$dest_dir/scripts/run_coderabbit_prompt_only.sh" ]]; then
  chmod +x "$dest_dir/scripts/run_coderabbit_prompt_only.sh" || true
fi

echo "Installed $skill_name to: $dest_dir"
echo "Restart Codex to pick up the new skill."
