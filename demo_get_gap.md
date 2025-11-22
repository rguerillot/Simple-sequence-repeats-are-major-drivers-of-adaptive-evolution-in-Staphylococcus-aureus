# get_gap_ambiguous_snp_score.sh demo

A five-sequence toy alignment (`demo/get_gap_ambiguous_snp_score/core_subset.aln`) demonstrates how the script now consolidates per-position metrics into one TSV plus Artemis-ready userplots.

## Inputs

- `demo/get_gap_ambiguous_snp_score/core_subset.aln`: alignment containing true gaps (`-`), ambiguous calls (`N`), and SNPs.
- Requires **trimal** on the PATH.

````text
Positions:  01 02 03 04 05 06 07 08 09 10 11 12 13 14 15
strain1   : ATGCA-NTTGCATGN
strain2   : AT-CAGNTTGCATGA
strain3   : ATGCAANT-GCATGA
strain4   : ATG-AANTT-CAAGA
strain5   : ATGCAANTTGCATNN
````

- Columns 3, 4, 6, 9, and 10 carry single-sequence deletions (20% gaps).
- Column 7 is fully ambiguous (all Ns), while column 15 ends with two terminal Ns (40% gap-or-N).
- Column 13 encodes a SNP (strain4 carries `A` instead of `T`), and column 6 mixes a gap with four distinct nucleotides, so both sites show nucleotide diversity.

## Run the demo

From the repository root:

```bash
bash demo/get_gap_ambiguous_snp_score/run_get_gap_demo.sh
```

Outputs appear next to the alignment:

- `core_subset.aln.gap_metrics.tsv`: unified table with columns `position`, `percent_gap`, `percent_gap_or_N`, `percent_ambiguous`, and `percent_snp`.
- Four `.userplot` files (`pct_gap`, `pct_gap_ambiguous`, `pct_ambiguous`, `pct_snp`) derived from the TSV columns for Artemis.

## Expected results

`core_subset.aln.gap_metrics.tsv` (excerpt below) should match the per-column behavior described above:

| Position | % gap | % gap or N | % ambiguous only | % SNP | Notes |
|----------|-------|------------|------------------|-------|-------|
| 3, 4, 6, 9, 10 | 20 | 20 | 0 | 0 / 20 | Single-sequence deletions; column 6 also introduces SNP diversity (20%). |
| 7 | 0 | 100 | 100 | 0 | All sequences carry `N`. |
| 13 | 0 | 0 | 0 | 20 | Strain4 carries `A` while others carry `T`. |
| 14 | 0 | 20 | 20 | 0 | One ambiguous base near the end. |
| 15 | 0 | 40 | 40 | 0 | Two terminal `N`s. |

All other positions remain 0 across the board. Because the TSV is the canonical source, the userplots simply expose integer-rounded versions of columns 2–5, so you can spot those peaks immediately in Artemis.

## Interpretation tips

- Use `% gap or N` to determine whether to mask a column altogether; `% ambiguous` isolates Ns specifically.
- `% SNP` highlights positions where at least one sequence carries a nucleotide different from the column majority, ignoring gaps and Ns.
- Temporary files are managed in an isolated directory and removed automatically, so only the TSV and `.userplot` files remain.
