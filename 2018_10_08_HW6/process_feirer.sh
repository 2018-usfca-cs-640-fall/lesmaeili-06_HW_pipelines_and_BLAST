#!/bin/bash
#Leila Esmaeili HW6
#lesmaeili@dons.usfca.edu

# Step 8
# the pipe and tail -n +2 is a handy way to exclude the first line
for SRA_number in $(cut -f 6 data/metadata/fierer_forensic_hand_mouse_SraRunTable.txt | tail -n +2)
do
    fastq-dump -v $SRA_number -O data/raw_data
done

