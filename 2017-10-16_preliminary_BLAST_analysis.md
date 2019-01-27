Leila Esmaeili
October 16, 2018

Bacterial communities that reside on the skin surface appear to be diverse. 
 In this paper, Fierer et al. have studied individual variability of skin
 bacteria for applications to forensic studies.  They have collected samples 
from different individuals computer mouse and sequenced these samples to be 
 compared  already known sequence in a gene bank.  They have concluded that
 bacterial finger prints can be used to in forensic studies. 

 I chose to study ERR1942293.trim.csv more closely.  I chose this sample
 because I was surprised that this sample had such a significant number
 of Acientobacter Haemolyticus (702 hits). Acientobacter is a gram negative
 bacteria often found in soil and it can sometimes be pathogenic (1). 
It could be that the person this sample came from was touching soil
 ( I.e.gardening) prior to when sample was taken. 

Since the scientists  leading the investigation need high quality data
 to support their hypothesis, they had to send their data to the following
 process: 
1. Download the Data
2. Apply fastQC to the data which stands for fast Quality Check
3. Trim the sequences
4. Convert from fastq to fasta format
5. Blastn to look at which bacteria was most similar


Fastq results allows for identifying and removing duplicate sequences
 or those with low quality.   According to Fastq analysis per base 
sequence quality for sample ERR 1942293, the first sequences have high 
quality  but we see some issues with number 185-262 where quality declines. 
Looking at per base sequence content, tells us the majority of base is each
 sequence.  Sequence duplication content is higher closer the end of the
 counts consistent .  CTCACCC is the sequence that has the highest
 presentation.  


References:

1- http://eol.org/pages/97490/hierarchy_entries/53144268/details

