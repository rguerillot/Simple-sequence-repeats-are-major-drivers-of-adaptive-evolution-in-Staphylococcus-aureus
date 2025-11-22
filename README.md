# Simple sequence repeats power *Staphylococcus aureus* adaptation

## Helper scripts documentation

This repository accompanies the study “Simple sequence repeats power *Staphylococcus aureus* adaptation,” gathering every helper script, mini demo, and usage note referenced in the Methods section of the *bioRxiv* preprint ([https://doi.org/10.1101/2025.07.08.663602](https://doi.org/10.1101/2025.07.08.663602)).

---

### Table of contents

- [Demo quickstart](#demo-quickstart)
- [1. `homoplastic_score.R`](#1-homoplastic_scorer)
- [2. `sample_run_gubbins.sh`](#2-sample_run_gubbinssh)
- [3. `get_gap_ambiguous_snp_score.sh`](#3-get_gap_ambiguous_snp_scoresh)
- [4. `rmseq_SSR_count.sh`](#4-rmseq_ssr_countsh)
- [5. `hetero_SSR_call.sh`](#5-hetero_ssr_callsh)

### Demo quickstart

- Homoplasy scoring: `bash demo/homoplastic_score/run_demo.sh` (see [`demo_homoplastic_score.md`](demo_homoplastic_score.md)).
- Gap/ambiguous profiling: `bash demo/get_gap_ambiguous_snp_score/run_get_gap_demo.sh` (see [`demo_get_gap.md`](demo_get_gap.md)).
- RM-seq SSR counting: `bash demo/rmseq_SSR_count/run_rmseq_demo.sh` (see [`demo_rmseq_SSR_count.md`](demo_rmseq_SSR_count.md)).

---

## 1. homoplastic_score.R

### Purpose (`homoplastic_score.R`)

Calculates homoplasy metrics (number of acquisition, consistency index, homoplasy slope, homoplasy slope ratio) for a given mutation across a phylogeny. Used to identify convergent (homoplastic) mutations in the context of the core SNP phylogeny of *S. aureus*.

### Dependencies (`homoplastic_score.R`)

- **R (≥ 3.x)**
- R packages:
  - **phangorn** (phylogenetic analysis)
  - **ape** (phylogenetic tree reading)
  - **argparser** (argument parsing)
- **sgrep** (sorted grep for extracting mutation IDs)

### Usage (`homoplastic_score.R`)

```bash
Rscript homoplastic_score.R <tree> <mutation_db> <mutation_id> [--nsims N] [--avg_hs VAL]
```

**Arguments:**

- `tree`: Path to the phylogenetic tree in Newick format (e.g., from RAxML).
- `mutation_db`: Sorted mutation database file (first column must be mutation ID).
- `mutation_id`: Mutation ID to analyze.
- `--nsims`: (Optional) Number of simulations used to estimate the average homoplasy slope (default: 0; random baseline is skipped unless this is > 0).
- `--avg_hs`: (Optional) Provide a precomputed average homoplasy slope value and skip simulations.
- `--print_header`: (Optional) Print a tab-delimited header before the metrics row (useful for piping results).

### Output (`homoplastic_score.R`)

Tab-delimited metrics: mutation count, number of convergent acquisitions (rounded integer), consistency index, homoplasy slope, average homoplasy slope (NA when not computed), homoplasy slope ratio (NA when random baseline is unavailable).

### Methods reference (`homoplastic_score.R`)

Used to assign number of convergent acquisitions to variants across 7,099 *S. aureus* genomes, as described in the Convergence analysis and CMAS calculation section.

See [`demo_homoplastic_score.md`](demo_homoplastic_score.md) for a runnable five-tip example that demonstrates how to interpret the **Number of acquisitions** metric.

---


## 2. sample_run_gubbins.sh

### Purpose (`sample_run_gubbins.sh`)

Runs Gubbins recombination detection on multiple random subsamples of a whole-genome alignment. Facilitates robust estimation of recombination rates at each genome position by repeated sampling.

### Dependencies (`sample_run_gubbins.sh`)

- **bash** (Unix shell)
- **awk** (text processing)
- **shuf** (randomization)
- **head** (text processing)
- **cat** (text processing)
- **run_gubbins.py** (Gubbins, v2.4.1+)
- **seq** (sequence generation; coreutils)

### Usage (`sample_run_gubbins.sh`)

```bash
bash sample_run_gubbins.sh
```

**Variables (set at the top):**

- `FA_TO_SAMPLE`: Path to the full core alignment FASTA (default: `../../core.full.aln`).
- `N_SAMPLE`: Number of subsampled runs (default: 100).
- `SIZE_SAMPLE`: Number of genomes per subsample (default: 100).
- `MIN_SNPS`: Minimum SNPs for Gubbins run (default: 10).

### Output (`sample_run_gubbins.sh`)

Generates multiple Gubbins output files (`gubbins.samp...`), each corresponding to a different random subset.

### Methods reference (`sample_run_gubbins.sh`)

Described under Convergence analysis and CMAS calculation. Recombination was estimated for every genome position by running gubbins 8 times on subsampled phylogenetic trees.

---


## 3. get_gap_ambiguous_snp_score.sh

### Purpose (`get_gap_ambiguous_snp_score.sh`)

Calculates the percentage of gaps, ambiguous bases, and SNPs at every position in a full genome alignment, generating userplot files for visualization. Used to filter out low-confidence positions prior to CMAS calculation.

### Dependencies (`get_gap_ambiguous_snp_score.sh`)

- **bash** (Unix shell)
- **trimal** (v1.4 or later; sequence alignment trimming and stats)
- **sed** (stream editor)
- **awk** (text processing)
- **grep** (text search)
- **cut** (text processing)
- **rm** (file removal)

### Usage (`get_gap_ambiguous_snp_score.sh`)

```bash
bash get_gap_ambiguous_snp_score.sh <alignment>
```

- `<alignment>`: Core genome alignment file (output from snippy).

### Output (`get_gap_ambiguous_snp_score.sh`)

Creates a consolidated `${aln}.gap_metrics.tsv` (columns: position, %gap, %gap-or-N, %ambiguous, %snp) plus four `.userplot` tracks derived from the TSV for Artemis plotting. Intermediate files are generated and cleaned up automatically.

### Methods reference (`get_gap_ambiguous_snp_score.sh`)

Used as described in Convergence analysis and CMAS calculation to determine the percentage of ambiguous and gap calls at every position.

See [`demo_get_gap.md`](demo_get_gap.md) for a reproducible miniature alignment plus instructions.

---


## 4. rmseq_SSR_count.sh

### Purpose (`rmseq_SSR_count.sh`)

Counts the frequency of SSR (simple sequence repeat) lengths in amplicon sequencing data generated by RM-seq, focusing on specific SSR patterns. Outputs a table of counts for each SSR length and sample.

### Dependencies (`rmseq_SSR_count.sh`)

- **bash** (Unix shell)
- **cut** (text processing)
- **grep** (text search)
- **wc** (word/line counting)
- **tail** (text processing)
- **echo** (text output)

### Usage (`rmseq_SSR_count.sh`)

```bash
bash rmseq_SSR_count.sh <file1> [<file2> ...]
```

- `<file>`: RM-seq amplicon effect file(s) to process.

- `<file>`: RM-seq amplicon effect file(s) to process. Each file must be tab-delimited with `mutation_id`, `sample`, and `SSR_sequence` in columns 1–3.

### Output (`rmseq_SSR_count.sh`)

Tabulated summary:

- Columns: sample name, counts for each SSR length (10A, 9A, ..., 5A), total count.
- The script prints the header once before listing per-sample rows so it can be safely chained in other pipelines.

### Methods reference (`rmseq_SSR_count.sh`)

Used in RM-seq amplicon deep-sequencing of SSR loci to count and compare SSR lengths across samples.

See [`demo_rmseq_SSR_count.md`](demo_rmseq_SSR_count.md) for a one-sample RM-seq table and walkthrough.

---


## 5. hetero_SSR_call.sh

### Purpose (`hetero_SSR_call.sh`)

Identifies SSR (simple sequence repeat) variant subpopulations in sequence data from human-derived samples. Maps reads, calculates coverage, prepares BAMs for low-frequency variant calling with LoFreq2, and normalizes indel calls.

### Dependencies (`hetero_SSR_call.sh`)

- **bash** (Unix shell)
- **bwa** (read mapper)
- **samtools** (v1.10+; BAM handling, coverage stats)
- **lofreq** (v2.1.2+; low-frequency variant caller)
- **vcfallelicprimitives** (vcflib; VCF normalization)
- **awk** (text processing)
- **cut** (text processing)
- **basename** (coreutils)

### Usage (`hetero_SSR_call.sh`)

```bash
bash hetero_SSR_call.sh <reference_fasta> <sample_R1.fastq> <sample_R2.fastq>
```

- `<reference_fasta>`: Reference genome (e.g., *S. aureus* NRS384).
- `<sample_R1.fastq>`: Forward reads.
- `<sample_R2.fastq>`: Reverse reads.

### Output (`hetero_SSR_call.sh`)

- `${sample}.bam`: Sorted BAM.
- `${sample}_coverage_mean_std.tsv`, `${sample}_coverage.tsv`: Coverage stats.
- `${sample}_lofreq2_allelicprimitives.vcf`: Normalized VCF of low-frequency variants.

### Methods reference (`hetero_SSR_call.sh`)

Described in Identification of SSR variants subpopulations in human derived samples. Automates mapping, LoFreq calling, and variant filtering pipeline.


---

Please see the Methods section of the manuscript for more context and rationale for each script’s use.

---

If you build on these scripts, please cite the *bioRxiv* preprint ([https://doi.org/10.1101/2025.07.08.663602](https://doi.org/10.1101/2025.07.08.663602)) and any third-party tools you run (see the references below).

## Tool References

- **phangorn** – K. Schliep, *Bioinformatics* 2011; <https://CRAN.R-project.org/package=phangorn>
- **ape** – E. Paradis & K. Schliep, *Bioinformatics* 2019; <https://CRAN.R-project.org/package=ape>
- **argparser** – L. Johnson, CRAN package; <https://CRAN.R-project.org/package=argparser>
- **sgrep** – GNU sgrep utility; <https://www.gnu.org/software/sgrep/>
- **Gubbins** – Croucher et al., *Nucleic Acids Research* 2015; <https://github.com/sanger-pathogens/gubbins>
- **trimal** – Capella-Gutiérrez et al., *Bioinformatics* 2009; <https://vicfero.github.io/trimal/>
- **GNU coreutils** (bash, awk, sed, grep, cut, seq, shuf, head, tail, rm, echo, wc, cat) – <https://www.gnu.org/software/coreutils/>
- **RM-seq method** – Guérillot et al., *Genome Medicine* 2018;
- **RM-seq software** – <https://github.com/rguerillot/rmseq>
- **BWA** – Li & Durbin, *Bioinformatics* 2009; <http://bio-bwa.sourceforge.net/>
- **samtools** – Danecek et al., *GigaScience* 2021; <http://www.htslib.org/>
- **LoFreq** – Wilm et al., *Nucleic Acids Research* 2012; <https://csb5.github.io/lofreq/>
- **vcflib / vcfallelicprimitives** – Garrison & Marth, arXiv:1207.3907; <https://github.com/vcflib/vcflib>
