#!/bin/bash
# Test script for get_gap_ambiguous_snp_score.sh
#
# NOTE: This test requires 'trimal' to be installed.
# Installation instructions: 
#   - Ubuntu: Install from source or conda
#   - conda install -c bioconda trimal

echo "Testing get_gap_ambiguous_snp_score.sh..."
echo "=========================================="

# Check if trimal is available
if ! command -v trimal &> /dev/null; then
    echo "ERROR: 'trimal' is not installed."
    echo "Please install it using: conda install -c bioconda trimal"
    echo "Or build from source: http://trimal.cgenomics.org/"
    exit 1
fi

# Get the directory where this test script is located
TEST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$TEST_DIR")"

# Run the script
cd "$TEST_DIR"
bash "$REPO_DIR/get_gap_ambiguous_snp_score.sh" test_core.full.aln

echo ""
echo "Test completed successfully!"
echo ""
echo "Expected output files:"
echo "- test_core.full.aln.pct_gap"
echo "- test_core.full.aln.pct_gap_ambiguous"
echo "- test_core.full.aln.pct_ambiguous"
echo "- test_core.full.aln.pct_snp"
echo "- test_core.full.aln.pct_gap.userplot"
echo "- test_core.full.aln.pct_gap_ambiguous.userplot"
echo "- test_core.full.aln.pct_ambiguous.userplot"
echo "- test_core.full.aln.pct_snp.userplot"
echo ""
echo "The test alignment contains:"
echo "- Position 13: 50% gaps (2/4 samples)"
echo "- Positions 17-19: 50% ambiguous bases (N) in 2/4 samples"
echo "- Position 11: SNP (C->T) in one sample"
