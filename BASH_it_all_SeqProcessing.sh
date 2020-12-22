#!/usr/bin/env bash

# This code was written by Timo Rey in December 2020.
# Have fun!


# #### BEFORE you start, please check the pre-requisits to run this code: #### #

# You will need to download and install the following software:
# SRA-toolkit from: https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit
# FastQC from:      https://www.bioinformatics.babraham.ac.uk/projects/fastqc/
# Bowtie from:


# You can then run this script from your working-repository on the cluster, by typing:
# ./BASH_it_all_SeqProcessing.sh                                                # (without the '#')

# the below will then run

# ------------------------------------------------------------------------------
# 01_Download data:  -----------------------------------------------------------
list_of_files=(SRR1944912 SRR1944913 SRR1944914 SRR1944921 SRR1944922 SRR1944923) # list of all file-names <- can change this to download other samples

export PATH=$PATH:$PWD/sratoolkit.2.10.8-centos_linux64/bin                     # needed to append path to binaries PATH env variable <- may need to change this depending on your software!
for i in ${list_of_files[@]};                                                   # for every name in the list
# note: configuration needs to be set manually -> including to specify the output directory
do prefetch $i; done                                                            # fetch raw sequences in .sra format

# 01_2_Convert to .fastq format:
for i in $(ls -d 01_Data/00_SRA_rawSeq/sra/*.sra);                              # find all files with extension .sra
do chmod gou+wrx $i; done                                                       # give read write and execution rights to these files

for i in $(ls -d 01_Data/00_SRA_rawSeq/sra/*.sra);
do fastq-dump --outdir 01_Data/01_fastq_rawSeq/ $i; done                        # convert to .fastq

for i in $(ls -d 01_Data/01_fastq_rawSeq/*.fastq);                              # give all rights to new .fastq files
do chmod gou+wrx $i; done


# ------------------------------------------------------------------------------
# 02_Quality control of raw sequences:  ----------------------------------------
#SBATCH --cpus-per-task=2                                                       # allocate computational resources for the task
#SBATCH --mem-per-cpu=1000M
fastqc somefile.txt someotherfile.txt

for i in $(ls -d 01_Data/01_fastq_rawSeq/*.fastq);
do ./00_Software/FastQC/fastqc --outdir=/02_IntermOutput/01_rawQC/ $i;          # do FastQC analysis for each file & save to output-directory
done


# ------------------------------------------------------------------------------
# 03_Clean transcripts from non-messenger RNA  ---------------------------------
# First, fetch non-messenger transcript-sequences & combine into single file for mapping
# then, annotate
# build indeces:
bowtie -build rRNA.fa rRNA
bowtie -build R64-1-1*

#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=80000M
bowtie -t 4 ./... $i --un *_clean.fastq 2>> logfile.txt
use toplevel


# 04_Annotate mRNA

# Then, map

# Then, annotate
#from Melina:
module add UHTS/Aligner/bowtie/1.2.0
bowtie -p 4 RNA_index SRR1944912.fastq --un SRR1944912_no_RNA.fastq 2> my_errors.txt


# 05_Quality assessment
# First, convert .sam to .bam list_of_files

# Then, assess mRNA-reads quality with Ribo-seQC




#from Melina:

featureCounts -t exon -g gene_id -a Saccharomyces_cerevisiae.R64-1-1.101.gtf   -o counts.txt SRR1944912_genome_sorted.bam SRR1944913_genome_sorted.bam SRR1944914_genome_sorted.bam SRR1944921_genome_sorted.bam SRR1944922_genome_sorted.bam SRR1944923_genome_sorted.bam
