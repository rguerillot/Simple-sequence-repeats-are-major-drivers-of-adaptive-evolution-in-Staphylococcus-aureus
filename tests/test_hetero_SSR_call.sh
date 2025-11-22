#!/bin/bash
# Test script for hetero_SSR_call.sh
#
# NOTE: This test requires several bioinformatics tools:
#   - bwa (read mapper)
#   - samtools (BAM handling)
#   - lofreq (low-frequency variant caller)
#   - vcflib (for vcfallelicprimitives)
#
# Installation instructions:
#   conda install -c bioconda bwa samtools lofreq vcflib

echo "Testing hetero_SSR_call.sh..."
echo "=============================="

# Check for required tools
MISSING_TOOLS=""

if ! command -v bwa &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS bwa"
fi

if ! command -v samtools &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS samtools"
fi

if ! command -v lofreq &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS lofreq"
fi

if ! command -v vcfallelicprimitives &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS vcfallelicprimitives"
fi

if [ ! -z "$MISSING_TOOLS" ]; then
    echo "ERROR: The following required tools are not installed:$MISSING_TOOLS"
    echo ""
    echo "Please install them using conda:"
    echo "  conda install -c bioconda bwa samtools lofreq vcflib"
    exit 1
fi

# Get the directory where this test script is located
TEST_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$TEST_DIR")"

cd "$TEST_DIR"

# First, need to index the reference
echo "Indexing reference genome..."
bwa index test_reference.fasta

echo ""
echo "Running hetero_SSR_call.sh..."
echo "This will perform:"
echo "1. Read mapping with BWA"
echo "2. Coverage calculation"
echo "3. BAM preparation for LoFreq"
echo "4. Low-frequency variant calling"
echo "5. VCF normalization"
echo ""

# Run the script (note: modified to use fewer threads for testing)
bash "$REPO_DIR/hetero_SSR_call.sh" test_reference.fasta test_sample_R1.fastq test_sample_R2.fastq

echo ""
echo "Test completed!"
echo ""
echo "Expected output files:"
echo "- test_sample.bam: Sorted and indexed BAM file"
echo "- test_sample_coverage_mean_std.tsv: Coverage statistics"
echo "- test_sample_coverage.tsv: Per-position coverage"
echo "- test_sample_lofreq2_allelicprimitives.vcf: Normalized variant calls"
echo ""
echo "Note: The test data is minimal and may not produce many variants."
echo "      The goal is to verify the pipeline runs without errors."
