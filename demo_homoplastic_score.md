# homoplastic_score.R demo

A tiny dataset bundled in `demo/homoplastic_score/` illustrates how to interpret the **Number of acquisitions** metric returned by `homoplastic_score.R`.

## Inputs

- `demo/homoplastic_score/tree5.nwk`: Newick tree `((A,B),(C,(D,E)))`.
- `demo/homoplastic_score/mutations5.tsv`: Mutation to strain mapping (mutation ids in column 1, strains in column 2).
- `demo/homoplastic_score/ascii_tree.txt`: Text rendering of the topology for quick inspection (also shown below).

```text
             ┌─ A (mut1)
         ┌───┤
         │   └─ B
 ROOT ───┤
         │       ┌─ C
         └───────┤
                 │   ┌─ D (mut1, mut2)
                 └───┤
                     └─ E (mut2)
```

- `mut1` occurs on A and D (two separate clades).
- `mut2` occurs on D and E (one monophyletic clade).

## Run the demo

From the repository root the helper script prints a tab-delimited header on the first call and then the metrics rows:

```bash
bash demo/homoplastic_score/run_demo.sh
```

The script runs `homoplastic_score.R` twice:

1. `mut1` demonstrates homoplasy: **Number of acquisitions > 1** because the mutation requires at least two independent gains (one on the A branch, one on the D branch).
2. `mut2` shows a single origin: **Number of acquisitions ≈ 1**, consistent with the mutation arising once in the D–E clade.

## Output columns refresher

After the mutation id prefix, the script prints:

1. Mutated tip count.
2. **Number of acquisitions** (parsimonious independent gains).
3. Consistency Index (CI).
4. Homoplasy slope (HS).
5. Average random HS (set to `NA` unless you supply `--nsims` > 0 or `--avg_hs`).
6. Homoplasy slope ratio (HSR = HS / avg random HS, also `NA` when no random baseline is provided). See Meier et al. (1991) for the original HSR formulation.

## References

- Archie, J. W. 1989. A randomization test for phylogenetic information in systematic data. *Systematic Zoology* 38(3):239–252. [https://doi.org/10.2307/2992406](https://doi.org/10.2307/2992406)
- Meier, R., P. Kores, and S. Darwin. 1991. Homoplasy Slope Ratio: A Better Measurement of Observed Homoplasy in Cladistic Analyses. *Systematic Biology* 40(1):74–88. [https://doi.org/10.1093/sysbio/40.1.74](https://doi.org/10.1093/sysbio/40.1.74)
