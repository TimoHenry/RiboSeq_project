#!/usr/bin/env bash

# This code was written by Timo Rey in December 2020.
# Have fun!


# #### BEFORE you start, please check the pre-requisits to run this code: #### #

# You will need to download and install the following software:
# SRA-toolkit from: https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit
# FastQC from:      https://www.bioinformatics.babraham.ac.uk/projects/fastqc/
# Bowtie from:


# You can then run this script from your working-repository on the cluster, by typing:

# the below will then run
# ------------------------------------------------------------------------------

# 01_Download data:
list_of_files=(SRR1944912 SRR1944913 SRR1944914 SRR1944921 SRR1944922 SRR1944923)
for i in ${list_of_files[@]}; do echo $i; done


# 02_Quality control of raw sequences:
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=1000M


# remove 'junk'-transcripts:
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=8000M
