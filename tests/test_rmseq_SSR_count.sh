#!/bin/bash
# Test script for rmseq_SSR_count.sh

echo "Testing rmseq_SSR_count.sh..."
echo "=============================="

# Get the directory where this test script is located
TEST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$TEST_DIR")"

# Run the script
cd "$TEST_DIR"
bash "$REPO_DIR/rmseq_SSR_count.sh" test_rmseq_amplicon.effect

echo ""
echo "Test completed successfully!"
echo ""
echo "Expected output:"
echo "- sample: test_sample1"
echo "- 10A count: 2 (GTGCCAAAAAAAAAATAAAG)"
echo "- 9A count: 2 (GTGCCAAAAAAAAATAAAG)"
echo "- 8A count: 2 (GTGCCAAAAAAAATAAAG)"
echo "- 7A count: 1 (GTGCCAAAAAAATAAAG)"
echo "- 6A count: 1 (GTGCCAAAAAATAAAG)"
echo "- 5A count: 1 (GTGCCAAAAATAAAG)"
echo "- all: 10 (total lines minus header)"
