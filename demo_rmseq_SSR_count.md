# rmseq_SSR_count.sh demo

A tiny RM-seq output (`demo/rmseq_SSR_count/sample_amplicons.effect`) demonstrates how SSR lengths are tallied across motifs.

## Inputs

- `demo/rmseq_SSR_count/sample_amplicons.effect`: tab-delimited file (column 1 mutation id, column 2 sample name, column 3 SSR sequence).
- Motifs span 10A down to 5A, covering every branch counted by the script.

## Run the demo

From the repository root:

```bash
bash demo/rmseq_SSR_count/run_rmseq_demo.sh
```

`rmseq_SSR_count.sh` prints the header once, so the helper script just streams its output. Sample result:

````text
sample    10A    9A    8A    7A    6A    5A    all
SampleX   1      1     1     1     1     2     7
````

## Interpretation tips

- The final column (`all`) subtracts the header row, so expect it to match the number of variant lines.
- Duplicate motifs (e.g., two rows containing the 5A pattern) increment their specific column but still count once toward `all`.
- Adjust the grep patterns in the script if your SSR flanks differ; this demo keeps the default `GTGCC…ATAAAG` backbone.
