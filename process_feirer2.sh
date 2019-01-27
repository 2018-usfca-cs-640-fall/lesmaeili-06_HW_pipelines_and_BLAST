#!/bin/bash
# Leila Esmaeili
# HW6 _Fall_2018

# email: lesmaeili@dons.usfca.edu

# exclude first line
for SRA_number in $(cut -f 6 data/metadata/fierer_forensic_hand_mouse_SraRunTable.txt | tail -n +2)
do
   fastq-dump -v "$SRA_number" -O data/raw_data
done

echo
echo
echo "done downloading data"
echo 
echo
sleep 2s

#making directory trimmed
mkdir data/trimmed
echo "made data/trimmed directory"

sleep 2s
 #Apply fastQ to all files
echo " apply fastqc to all files"
fastqc data/raw_data/*.fastq --outdir=output/fastqc

sleep 2s
# Trim files
echo " trim files"
for f in data/raw_data/*; do
	 B="$(cut -d'/' -f3 <<<"$f")"
	echo "$B"
	TrimmomaticSE -threads 2 -phred33 "$f" data/trimmed/"$(basename -s .fastq "$B")".trim.fastq LEADING:5 TRAILING:5 SLIDINGWINDOW:8:25 MINLEN:150
done


echo
echo
echo "done with trim"
echo
echo
sleep 2s


#  Convert FastQ into Fasta
echo " convert fastQ into  Fasta"
for f in data/trimmed/*.fastq; do
	B="$(cut -d'/' -f3 <<<"$f")"
	C="$(cut -d'.' -f1 <<<"$B")"
	bioawk -c fastx '{print ">"$name"\n"$seq}' "$f" > data/trimmed/"$C".trim.fasta
	echo "$f" 
done

echo " finished converting"
sleep 2s

echo "making directory blast results"
mkdir output/Blast_results

echo "time for  Blast"
for file in data/trimmed/*.fasta;
do
 blastn -db /blast-db/nt -num_threads 2 -outfmt '10 sscinames std' -out output/Blast_results/"$(basename -s .fasta "$file").csv" -max_target_seqs 1 -negative_gilist /blast-db/2018-09-19_environmental_sequence.gi -query "$file"  
 echo "Checked one file, moving on to the next..."
done 


