#!/usr/bin/env bash
set -Eeuo pipefail

# Apply the global git configuration that should hold on every machine.
# Identity (user.name / user.email) is NOT set here — that's personal and lives
# in scripts/personalize.sh, applied only when this is a "Charles PC".
# `git config --global` is idempotent, so this is safe to re-run.

echo "🔧 Applying global git config..."

# Short aliases.
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

# Sensible defaults.
git config --global init.defaultBranch master
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global commit.verbose true
git config --global column.ui auto
git config --global branch.sort -committerdate
git config --global tag.sort -version:refname

# Nicer diffs.
git config --global diff.algorithm histogram
git config --global diff.colorMoved plain
git config --global diff.mnemonicPrefix true

# Record & replay conflict resolutions across rebases/merges.
git config --global rerere.enabled true
git config --global rerere.autoupdate true

# Use the GitHub CLI as the credential helper when it's available.
if command -v gh >/dev/null 2>&1; then
  gh auth setup-git 2>/dev/null && echo "  ✅ gh configured as git credential helper." \
    || echo "  ⚠️  'gh auth setup-git' failed (run 'gh auth login' first)."
fi

echo "  ✅ git config applied."
