#!/usr/bin/env bash
set -euo pipefail

# Creates and publishes all ten standalone public repositories.
# Requirements:
#   1. Install GitHub CLI: https://cli.github.com
#   2. Authenticate: gh auth login
#   3. Run from the extracted portfolio package root: ./publish-all.sh

OWNER="${GITHUB_OWNER:-amitvikram}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while IFS= read -r repo; do
  [[ -z "$repo" ]] && continue
  dir="$ROOT_DIR/$repo"

  if [[ ! -d "$dir" ]]; then
    echo "Missing repository folder: $dir" >&2
    exit 1
  fi

  echo "Publishing $OWNER/$repo"

  if gh repo view "$OWNER/$repo" >/dev/null 2>&1; then
    echo "Repository exists. Content will be pushed to main."
  else
    gh repo create "$OWNER/$repo" \
      --public \
      --description "Enterprise AI public-safe architecture and implementation shell"
  fi

  (
    cd "$dir"
    if [[ ! -d .git ]]; then
      git init -b main
    fi
    git add .
    git -c user.name="Amit Vikram" \
        -c user.email="amitvik@gmail.com" \
        commit -m "Create public-safe enterprise AI solution shell" || true
    git remote remove origin >/dev/null 2>&1 || true
    git remote add origin "https://github.com/$OWNER/$repo.git"
    git push -u origin main
  )
done <<'REPOS'
engineering-rca-ai
legal-research-rag-optimizer
employee-onboarding-copilot
legal-invoice-review-ai
multimodal-search-platform
dynamic-pricing-margin-optimizer
accounts-receivable-ai-agent
inquiry-to-quote-agent
demand-forecasting-procurement-ai
product-literature-generation-ai
REPOS

echo "All repositories published."
