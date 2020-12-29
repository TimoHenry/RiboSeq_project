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
# then, index them
bowtie-build all_undesiredRNA_Refs.txt all_undesiredRNA_Refs.txt
# then, download the fastq files from server:
scp trey@binfservms01.unibe.ch:/data/users/trey/RNAseq/01_Data/01_fastq_rawSeq/ .
bowtie -t
# then, filter the sequences with the indexed unwanted RNA:



#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=80000M

for i in $(ls -d 01_Data/01_fastq_rawSeq/*.fastq);
do bowtie -t 4 ./... $i --un *_clean.fastq 2>> logfile.txt;
done

# 04_Annotate mRNA
# 04_1 index reference annotations:
# 04_2 map to transcriptome:

# 04_2 map to genome:
from Melina:
module add UHTS/Aligner/bowtie/1.2.0
bowtie -p 4 RNA_index SRR1944912.fastq --un SRR1944912_no_RNA.fastq 2> my_errors.txt

# ------------------------------------------------------------------------------
# 05_Quality assessment  -------------------------------------------------------
# First, convert .sam to .bam list_of_files
# -> go to SAMtool/bin/, then, for all transcriptome-annotated sam files:
./samtools view -S -b ../../04_bowtie_transcriptome/SRR19449*-transAnnot.sam > ../../05_BAM_out/SRR19449*_transcriptome.bam
# for all genome-annotated sam files:
./samtools view -S -b ../../04_bowtie_transcriptome/SRR19449*-GenAnnot.sam > ../../05_BAM_out/SRR19449*_genome.bam
# note: -S => expects .sam input (vs. default .bam); -b produces .bam output; default is STDOUT => need '>' operator

# sort genome.bam files:
./samtools sort ../../05_BAM_out/SRR1944912_genome.bam -o ../../05_BAM_out/SRR1944912_genome.sorted.bam


# Then, assess mRNA-reads quality with RiboseQC in R
# step 1) prepare annotation files:
#prepare_annotation_files(annotation_directory = "C:\Users\timor\Documents\UniFR\HS2020_RNAseq\05_RiboseQC",                # target directory to contain the output files
#                         twobit_file = "C:\Users\timor\Documents\UniFR\HS2020_RNAseq\05_RiboseQC\yeastGenome.2bit",
#                         gtf_file = "C:\Users\timor\Documents\UniFR\HS2020_RNAseq\05_RiboseQC\yeastGenome.gtf", # files to build reference from
#                         scientific_name = "Saccharomyces.cerevisiae",          # organism
#                         annotation_name = "yeast_RiboseQC",                    # name to give to annotation used
#                         export_bed_tables_TxDb = F, forge_BSgenome = T, create_TxDb = T)
# run the following one-liner:
prepare_annotation_files(annotation_directory="C:/Users/timor/Documents/UniFR/HS2020_RNAseq/05_RiboseQC",twobit_file="C:/Users/timor/Documents/UniFR/HS2020_RNAseq/05_RiboseQC/yeastGenome.2bit",gtf_file="C:/Users/timor/Documents/UniFR/HS2020_RNAseq/05_RiboseQC/yeastGenome.gtf",scientific_name="Saccharomyces.cerevisiae",annotation_name="yeast_RiboseQC",export_bed_tables_TxDb=T,forge_BSgenome=T,create_TxDb=T)

load_annotation( 'C:/Users/timor/Documents/UniFR/HS2020_RNAseq/05_RiboseQC/yeastGenome.gtf_Rannot' )
# From Melina:
featureCounts -t exon -g gene_id -a Saccharomyces_cerevisiae.R64-1-1.101.gtf   -o counts.txt SRR1944912_genome_sorted.bam SRR1944913_genome_sorted.bam SRR1944914_genome_sorted.bam SRR1944921_genome_sorted.bam SRR1944922_genome_sorted.bam SRR1944923_genome_sorted.bam

# step 2) perform analysis:                                                     # see documentation here: http://127.0.0.1:28535/library/RiboseQC/html/RiboseQC_analysis.html
# for single sample, in R type:
bam_filepath <- c("C:/Users/timor/Documents/UniFR/HS2020_RNAseq/05_RiboseQC/SRR1944912_genome.sorted.bam")
bam_names <- c("SRR1944912")

# for multiple samples, in R type:
bam_filepath <- c("C:/Users/timor/Documents/UniFR/HS2020_RNAseq/05_RiboseQC/SRR1944912_genome.sorted.bam",
"C:/Users/timor/Documents/UniFR/HS2020_RNAseq/05_RiboseQC/SRR1944913_genome.sorted.bam",
"C:/Users/timor/Documents/UniFR/HS2020_RNAseq/05_RiboseQC/SRR1944914_genome.sorted.bam",
"C:/Users/timor/Documents/UniFR/HS2020_RNAseq/05_RiboseQC/SRR1944921_genome.sorted.bam",
"C:/Users/timor/Documents/UniFR/HS2020_RNAseq/05_RiboseQC/SRR1944922_genome.sorted.bam",
"C:/Users/timor/Documents/UniFR/HS2020_RNAseq/05_RiboseQC/SRR1944923_genome.sorted.bam")
bam_names <- c("SRR1944912","SRR1944913","SRR1944914","SRR1944921","SRR1944922","SRR1944923")

RiboseQC_analysis(annotation_file="C:/Users/timor/Documents/UniFR/HS2020_RNAseq/05_RiboseQC/yeastGenome.gtf_Rannot", bam_files = bam_filepath, fast_mode = T, report_file="C:/Users/timor/Documents/UniFR/HS2020_RNAseq/05_RiboseQC/allYeast_riboseQC.html", sample_names=bam_names, dest_names=bam_names, write_tmp_files=T)
