#!/bin/bash
# author: R. Guerillot
# date: 19/11/2024

ref_path=$1
sample_R1=$2
sample_R2=$3
sample=$(basename $2 | cut -d. -f1 | cut -d"_" -f1)

echo "processing $sample with $ref reference"

# mapping
bwa mem -t 30 $ref_path $2 $3 | samtools sort -l 0 --threads 30 | samtools view -@ $30 -S -b - > ${sample}.bam

# indexing
samtools index ${sample}.bam

# calculate average and std deviation genome coverage
samtools depth ${sample}.bam | awk '{sum+=$3; sumsq+=$3*$3} END { print sum/NR"\t", sqrt(sumsq/NR - (sum/NR)**2)}' > ${sample}_coverage_mean_std.tsv
samtools coverage ${sample}.bam > ${sample}_coverage.tsv 
	
# prepare bam for lofreq
lofreq alnqual -b -r ${sample}.bam $ref_path > ${sample}_alnqual.bam
lofreq indelqual --dindel ${sample}_alnqual.bam -f ${ref_path} -o ${sample}_alnqual_indelqual.bam
samtools index ${sample}_alnqual_indelqual2.bam

# Call low frequency variants with lofreq
lofreq call-parallel --pp-threads 30 --call-indels -f ${ref_path} -o ${sample}_lofreq2.vcf ${sample}_alnqual_indelqual.bam

# normalise indels calls
cat ${sample}_lofreq2.vcf | vcfallelicprimitives -k > ${sample}_lofreq2_allelicprimitives.vcf
