#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR%/demo/rmseq_SSR_count}"
cd "$ROOT_DIR"

# rmseq_SSR_count.sh prints its own header
bash rmseq_SSR_count.sh demo/rmseq_SSR_count/sample_amplicons.effect
