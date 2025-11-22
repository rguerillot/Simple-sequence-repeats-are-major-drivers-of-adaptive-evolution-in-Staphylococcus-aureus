#!/bin/bash
# Test script for homoplastic_score.R
#
# NOTE: This test requires R with the following packages:
#   - ape
#   - phangorn
#   - argparser
# And also requires 'sgrep' (sorted grep) to be installed.
#
# Installation instructions:
#   R packages: R -e "install.packages(c('ape', 'phangorn', 'argparser'))"
#   sgrep: Available from https://github.com/arunsethuraman/sgrep or apt-get install sgrep

echo "Testing homoplastic_score.R..."
echo "==============================="

# Check if R is available
if ! command -v R &> /dev/null; then
    echo "ERROR: 'R' is not installed."
    echo "Please install R from https://www.r-project.org/"
    exit 1
fi

# Check if Rscript is available
if ! command -v Rscript &> /dev/null; then
    echo "ERROR: 'Rscript' is not available."
    echo "Please install R from https://www.r-project.org/"
    exit 1
fi

# Check if sgrep is available
if ! command -v sgrep &> /dev/null; then
    echo "WARNING: 'sgrep' is not installed."
    echo "The script requires sgrep for efficient mutation lookup."
    echo "You can install it from: https://github.com/arunsethuraman/sgrep"
    echo "Or use: apt-get install sgrep"
    echo ""
fi

# Get the directory where this test script is located
TEST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$TEST_DIR")"

# Test data setup
cd "$TEST_DIR"

echo "Test data:"
echo "- Tree: test_tree.newick (4 strains)"
echo "- Mutation database: test_mutation_db_sorted.txt"
echo "  - mut_001: appears in strain1 and strain3 (convergent/homoplastic)"
echo "  - mut_002: appears in strain2 and strain4 (convergent/homoplastic)"
echo "  - mut_003: appears in strain1, strain2, and strain3 (multiple acquisitions)"
echo ""

# Run the script for each mutation
echo "Testing mut_001..."
Rscript "$REPO_DIR/homoplastic_score.R" test_tree.newick test_mutation_db_sorted.txt mut_001 --nsims 10

echo ""
echo "Testing mut_002..."
Rscript "$REPO_DIR/homoplastic_score.R" test_tree.newick test_mutation_db_sorted.txt mut_002 --nsims 10

echo ""
echo "Testing mut_003..."
Rscript "$REPO_DIR/homoplastic_score.R" test_tree.newick test_mutation_db_sorted.txt mut_003 --nsims 10

echo ""
echo "Test completed!"
echo ""
echo "Expected output for each mutation:"
echo "- Mutation count: Number of strains with the mutation"
echo "- No convergent acquisition (ES): Extra steps indicating homoplasy"
echo "- Consistency index (CI): Measure of fit to tree (1 = no homoplasy)"
echo "- Homoplasy slope (HS): Normalized homoplasy measure"
echo "- Average homoplasy slope of random data: Baseline comparison"
echo "- Homoplasy slope ratio (HSR): Ratio of observed to expected homoplasy"
