#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR%/demo/get_gap_ambiguous_snp_score}"
cd "$ROOT_DIR"

ALN="demo/get_gap_ambiguous_snp_score/core_subset.aln"

echo "Running gap/ambiguous/SNP scoring on ${ALN}" 
./get_gap_ambiguous_snp_score.sh "$ALN"

echo "Artifacts written next to ${ALN}" 
