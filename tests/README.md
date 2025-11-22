# Test Suite for Simple Sequence Repeats Analysis Scripts

This directory contains test datasets and test scripts for all analysis scripts in this repository.

## Overview

Each script has been provided with:
1. **Minimal test input data** - Small, simulated datasets that can be processed quickly
2. **Test script** - Automated test that runs the main script with the test data
3. **Documentation** - Expected outputs and dependency requirements

## Quick Start

### Prerequisites

The scripts have various dependencies. See individual test scripts for details.

**Common requirements:**
- bash (Unix shell)
- Standard Unix utilities (awk, sed, grep, cut, etc.)

**Specialized tools needed by specific scripts:**
- **R** (with packages: ape, phangorn, argparser) - for `homoplastic_score.R`
- **trimal** - for `get_gap_ambiguous_snp_score.sh`
- **Gubbins** (run_gubbins.py) - for `sample_run_gubbins.sh`
- **bwa, samtools, lofreq, vcflib** - for `hetero_SSR_call.sh`
- **sgrep** (sorted grep) - for `homoplastic_score.R`

Most bioinformatics tools can be installed via conda:
```bash
conda install -c bioconda bwa samtools lofreq vcflib trimal gubbins
```

R packages can be installed:
```bash
R -e "install.packages(c('ape', 'phangorn', 'argparser'))"
```

## Test Files

### 1. test_rmseq_SSR_count.sh ✓ WORKING

**Tests:** `rmseq_SSR_count.sh`

**Input data:**
- `test_rmseq_amplicon.effect` - Simulated RM-seq amplicon effect file with various SSR lengths

**How to run:**
```bash
cd tests
bash test_rmseq_SSR_count.sh
```

**Dependencies:** None (only standard Unix tools)

**Expected output:**
- Counts for each SSR length (10A, 9A, 8A, 7A, 6A, 5A)
- Total count of all amplicons

**Status:** ✓ Fully tested and working

---

### 2. test_get_gap_ambiguous_snp_score.sh

**Tests:** `get_gap_ambiguous_snp_score.sh`

**Input data:**
- `test_core.full.aln` - Small multi-sequence alignment with gaps, ambiguous bases (N), and SNPs

**How to run:**
```bash
cd tests
bash test_get_gap_ambiguous_snp_score.sh
```

**Dependencies:** 
- trimal (install: `conda install -c bioconda trimal`)

**Expected output:**
- `.pct_gap`, `.pct_gap_ambiguous`, `.pct_ambiguous`, `.pct_snp` files
- `.userplot` files for Artemis visualization

---

### 3. test_sample_run_gubbins.sh

**Tests:** `sample_run_gubbins.sh`

**Input data:**
- `test_sample_core.full.aln` - Alignment file with 10 genome sequences

**How to run:**
```bash
cd tests
bash test_sample_run_gubbins.sh
```

**Dependencies:**
- Gubbins (install: `conda install -c bioconda gubbins`)

**Expected output:**
- Multiple subsampled alignment files
- Gubbins output files for each subsample

**Note:** This test uses reduced parameters (3 iterations, 5 genomes per sample) compared to the production script (100 iterations, 100 genomes).

---

### 4. test_homoplastic_score.sh

**Tests:** `homoplastic_score.R`

**Input data:**
- `test_tree.newick` - Simple phylogenetic tree with 4 strains
- `test_mutation_db_sorted.txt` - Sorted mutation database with 3 test mutations

**How to run:**
```bash
cd tests
bash test_homoplastic_score.sh
```

**Dependencies:**
- R (≥ 3.x)
- R packages: ape, phangorn, argparser
- sgrep (sorted grep)

**Expected output:**
For each mutation:
- Mutation count
- Number of convergent acquisitions (extra steps)
- Consistency index (CI)
- Homoplasy slope (HS)
- Average homoplasy slope of random data
- Homoplasy slope ratio (HSR)

**Test mutations:**
- `mut_001`: Homoplastic mutation in strain1 and strain3
- `mut_002`: Homoplastic mutation in strain2 and strain4  
- `mut_003`: Multiple acquisitions in strain1, strain2, and strain3

---

### 5. test_hetero_SSR_call.sh

**Tests:** `hetero_SSR_call.sh`

**Input data:**
- `test_reference.fasta` - Small reference genome (300bp)
- `test_sample_R1.fastq` - Forward reads (3 reads)
- `test_sample_R2.fastq` - Reverse reads (3 reads)

**How to run:**
```bash
cd tests
bash test_hetero_SSR_call.sh
```

**Dependencies:**
- bwa (read mapper)
- samtools (≥ 1.10)
- lofreq (≥ 2.1.2)
- vcflib (for vcfallelicprimitives)

All can be installed via: `conda install -c bioconda bwa samtools lofreq vcflib`

**Expected output:**
- `test_sample.bam` - Sorted BAM file
- `test_sample_coverage_mean_std.tsv` - Coverage statistics
- `test_sample_coverage.tsv` - Per-position coverage
- `test_sample_lofreq2_allelicprimitives.vcf` - Normalized variant calls

**Note:** The minimal test data may not produce many variants. The test verifies the pipeline runs without errors.

---

## Running All Tests

To run all tests that don't require external dependencies:
```bash
cd tests
bash test_rmseq_SSR_count.sh
```

To run tests requiring bioinformatics tools (if installed):
```bash
cd tests
for test in test_*.sh; do
    echo "Running $test..."
    bash "$test"
    echo "---"
done
```

## Notes

1. **Minimal data by design:** Test datasets are intentionally small to ensure fast execution.

2. **Dependency requirements:** Not all tests will run out of the box. Check individual test scripts for dependency installation instructions.

3. **Realistic scenarios:** While the data is minimal, the test files represent realistic input formats and edge cases (gaps, ambiguous bases, homoplastic mutations, etc.).

4. **Production vs. test parameters:** Some tests use reduced parameters compared to production (e.g., fewer iterations, smaller sample sizes) to complete quickly.

## Troubleshooting

**"Command not found" errors:**
- Install the required dependencies listed in each test script
- Use conda/bioconda for bioinformatics tools
- Use CRAN or install.packages() for R packages

**"No such file or directory":**
- Make sure you're running tests from the `tests/` directory
- All test scripts use relative paths

**Tests take too long:**
- Test parameters are already reduced from production settings
- For very large production runs, these tests validate the pipeline works correctly on small data

## Contributing

When adding new scripts to the repository, please:
1. Create minimal test input data in the `tests/` directory
2. Write a test script following the naming convention `test_<script_name>.sh`
3. Document dependencies and expected outputs
4. Update this README with your test information
