#!/bin/bash

# Script to count SSR length using grep on an amplicons.effect file generated by rmseq
# usage rmseq_count_ssr <file>

echo -e "sample \t 10A \t 9A \t 8A \t 7A \t 6A \t 5A \t all"
header=1

for file in "$@"
do
	sample=$(tail -n1 $file | cut -f2)
	ten=$(cut -f 10 $file | grep -i -c "GTGCCAAAAAAAAAATAAAG")
	nine=$(cut -f 10 $file | grep -i -c "GTGCCAAAAAAAAATAAAG")
	height=$(cut -f 10 $file | grep -i -c "GTGCCAAAAAAAATAAAG")
	seven=$(cut -f 10 $file | grep -i -c "GTGCCAAAAAAATAAAG")
	six=$(cut -f 10 $file | grep -i -c "GTGCCAAAAAATAAAG")
	five=$(cut -f 10 $file | grep -i -c "GTGCCAAAAATAAAG")
	nblines=$(wc -l $file | cut -d" " -f1)
	all="$(($nblines-$header))"

	echo -e "${sample} \t ${ten} \t ${nine} \t ${height} \t ${seven} \t ${six} \t ${five} \t ${all}"
done
