#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR%/demo/homoplastic_score}"
cd "$ROOT_DIR"

DEMO_DIR="demo/homoplastic_score"

echo "Mutation: mut1 (A,D) – homoplasic"
Rscript homoplastic_score.R "${DEMO_DIR}/tree5.nwk" "${DEMO_DIR}/mutations5.tsv" mut1 --print_header

echo "Mutation: mut2 (D,E) – monophyletic"
Rscript homoplastic_score.R "${DEMO_DIR}/tree5.nwk" "${DEMO_DIR}/mutations5.tsv" mut2
