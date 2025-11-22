#!/bin/bash
# Test script for sample_run_gubbins.sh
#
# NOTE: This test requires 'run_gubbins.py' (Gubbins) to be installed.
# Installation instructions:
#   - conda install -c bioconda gubbins

echo "Testing sample_run_gubbins.sh..."
echo "================================="

# Check if gubbins is available
if ! command -v run_gubbins.py &> /dev/null; then
    echo "ERROR: 'run_gubbins.py' (Gubbins) is not installed."
    echo "Please install it using: conda install -c bioconda gubbins"
    exit 1
fi

# Get the directory where this test script is located
TEST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$TEST_DIR")"

# Create a test version of the script with reduced parameters
cd "$TEST_DIR"

# Create a modified version for testing
cat > test_sample_run_gubbins_modified.sh << 'EOF'
#!/bin/bash

FA_TO_SAMPLE="test_sample_core.full.aln"
N_SAMPLE=3  # Reduced for testing
SIZE_SAMPLE=5  # Reduced for testing
MIN_SNPS=2  # Reduced for testing

for i in $(seq 1 "$N_SAMPLE")
do
	# Randomly sample fasta sequence in core.full.aln
	cat $FA_TO_SAMPLE | awk '/^>/ { if(i>0) printf("\n"); i++; printf("%s\t",$0); next;} {printf("%s",$0);} END { printf("\n");}' | shuf | head -n $SIZE_SAMPLE | awk '{printf("%s\n%s\n",$1,$2)}' > core.full.aln.samp${SIZE_SAMPLE}_${i}
	# Run gubbins on subsampled fasta
	echo "Running gubbins iteration $i..."
	run_gubbins.py --min_snps $MIN_SNPS --prefix gubbins.samp${SIZE_SAMPLE}_${i} --threads 2 core.full.aln.samp${SIZE_SAMPLE}_${i} 
done

EOF

chmod +x test_sample_run_gubbins_modified.sh

echo "Running modified sample_run_gubbins.sh with reduced parameters..."
bash test_sample_run_gubbins_modified.sh

echo ""
echo "Test completed!"
echo ""
echo "Expected output:"
echo "- Created 3 subsampled alignment files (core.full.aln.samp5_1, samp5_2, samp5_3)"
echo "- Generated Gubbins output files for each subsample"
echo ""
echo "Note: The original script is designed to run 100 iterations with 100 genomes each,"
echo "      which would take significant computational time. This test uses reduced parameters."
