#!/usr/bin/env bash
set -euo pipefail

# Author: R. Guerillot
# Description: Use trimal -sgc option to calculate %gap, %ambiguous and %snp
# at every position of a Snippy core alignment. Outputs are consolidated into a
# single TSV plus four Artemis userplot tracks.

if [[ $# -lt 1 ]]; then
	echo "Usage: $0 <alignment.fa>" >&2
	exit 1
fi

if ! command -v trimal >/dev/null 2>&1; then
	echo "Error: trimal is not on PATH" >&2
	exit 127
fi

aln="$1"

if [[ ! -s "$aln" ]]; then
	echo "Error: alignment '$aln' not found or empty" >&2
	exit 2
fi

echo "processing $aln file"

tmp_dir="$(mktemp -d)"
cleanup() {
	rm -rf "$tmp_dir"
}
trap cleanup EXIT

metrics_tsv="${aln}.gap_metrics.tsv"
printf "position\tpercent_gap\tpercent_gap_or_N\tpercent_ambiguous\tpercent_snp\n" > "$metrics_tsv"

run_trimal() {
	local input="$1"
	local label="$2"
	local out_file="$tmp_dir/${label}.sgc"
	trimal -in "$input" -sgc > "$out_file"
	grep -Ev '^\||\+|^\s*$' "$out_file" | awk '{printf "%d\t%s\n", $1 + 1, $2}' > "$tmp_dir/${label}.tsv"
	cat "$tmp_dir/${label}.tsv"
}

echo "get %gap at each position"
run_trimal "$aln" gap > "$tmp_dir/gap.values"

echo "get %ambiguous or gap at each position"
amb_gap_fa="$tmp_dir/amb_gap.fa"
sed 's|[Nn]|-|g' "$aln" > "$amb_gap_fa"
run_trimal "$amb_gap_fa" gap_amb > "$tmp_dir/gap_amb.values"

echo "get %ambiguous at each position"
gap_to_t="$tmp_dir/gap_to_t.fa"
sed 's|-|T|g' "$aln" > "$gap_to_t"
amb_only_fa="$tmp_dir/amb_only.fa"
sed 's|[Nn]|-|g' "$gap_to_t" > "$amb_only_fa"
run_trimal "$amb_only_fa" amb > "$tmp_dir/amb.values"

echo "get %snp at each position"
awk -v OFS="\t" '
BEGIN {
	seq_idx = 0
	max_pos = 0
	split("A C G T", bases)
}
/^>/ {
	seq_idx++
	next
}
/^$/ { next }
{
	line = $0
	len = length(line)
	for (i = 1; i <= len; ++i) {
		pos = pos_tracker[seq_idx] + i
		base = substr(line, i, 1)
		if (base ~ /-/) {
			gap[pos]++
		} else if (base ~ /[Nn]/) {
			amb[pos]++
		} else if (base ~ /[ACGTacgt]/) {
			nuc[pos]++
			upper = toupper(base)
			counts[pos ":" upper]++
		}
		if (pos > max_pos) {
			max_pos = pos
		}
	}
	pos_tracker[seq_idx] += len
}
END {
	for (pos = 1; pos <= max_pos; ++pos) {
		max_count = 0
		for (b in bases) {
			key = pos ":" bases[b]
			if (counts[key] > max_count) {
				max_count = counts[key]
			}
		}
		if (nuc[pos] == 0 || seq_idx == 0) {
			perc = 0
		} else {
			perc = ((nuc[pos] - max_count) / seq_idx) * 100
		}
		printf "%d\t%.10f\n", pos, perc
	}
}
' "$aln" > "$tmp_dir/snp.values"

paste "$tmp_dir/gap.values" "$tmp_dir/gap_amb.values" "$tmp_dir/amb.values" "$tmp_dir/snp.values" \
	| awk -F'\t' 'BEGIN {OFS="\t"} {print $1, $2, $4, $6, $8}' >> "$metrics_tsv"

echo "generate artemis userplots"
generate_userplot() {
	local column="$1"
	local outfile="$2"
	cut -f"$column" "$metrics_tsv" | tail -n +2 | awk '{printf "%i\n", $1}' > "$outfile"
}

generate_userplot 2 "${aln}.pct_gap.userplot"
generate_userplot 3 "${aln}.pct_gap_ambiguous.userplot"
generate_userplot 4 "${aln}.pct_ambiguous.userplot"
generate_userplot 5 "${aln}.pct_snp.userplot"

echo "summary written to $metrics_tsv"
