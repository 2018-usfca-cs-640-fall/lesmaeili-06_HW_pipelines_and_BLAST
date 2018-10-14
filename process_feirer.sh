# !/bin/bash
# Leila Esmaeili
# HW6 _Fall_2018

# email: lesmaeili@dons.usfca.edu

# exclude first line
for SRA_number in $(cut -f 6 data/metadata/fierer_forensic_hand_mouse_SraRunTable.txt | tail -n +2)
do
    fastq-dump -v $SRA_number -O data/raw_data
done

# Apply fastQ to all files
echo " apply fast! to all files"
fastqc data/raw_data/*.fastq --outdir=output/fastqc

#  Trim files
echo " trim files"
for f in data/raw_data/*; do
	B="$(cut -d'/' -f3 <<<"$f")"
	echo $B
	
	TrimmomaticSE -threads 2 -phred33 $f data/trimmed/$(basename -s .fastq $B).trim.fastq LEADING:5 TRAILING:5 SLIDINGWINDOW:8:25 MINLEN:150
done

#  Convert FastQ into Fasta
echo " convert fastQ into  Fasta"
for f in data/trimmed/*.fastq; do
	B="$(cut -d'/' -f3 <<<"$f")"
	C="$(cut -d'.' -f1 <<<"$B")"
	#echo $C 
	bioawk -c fastx '{print ">"$name"\n"$seq}' $f > data/trimmed/$C.trim.fasta
	echo $f 
done
