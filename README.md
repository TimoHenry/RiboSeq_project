# RiboSeq_project
December, 2020

This is a repository for a course-project to learn how to analyse Ribosome-Profiling Sequencing data. It is part of the curriculum towards a M.Sc. in Bioinformatics degree at the universities of Bern or Fribourg in Switzerland -> check out their websites in case you're interested to learn this kind of stuff, I find it fun!

In this repo, you should find a step-by-step guide to download and install necessary software, as well as the codes used to download, process and analyse the data. In case you would like to follow this approach, simply clone this repository somewhere on your PC and follow the instructions. Resources that I started with, were: Personal PC with Windows OS, Ubuntu for Windows (v.20.04), access to IBU-computing cluster at University of Bern [though you can calculate everything on your private machine as well].

Below you will find an outline of steps and filenames for detailed instructions to execute each step.
Good luck!  
                                                                                 (p.s.: do not hesitate to ask, in case you're stuck somewhere, it is likely I was stuck there too ;-) )
                                                                                   
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
****************************************************    I) Processing     ****************************************************

**Step 1) Download the data

Follow instructions in 01_GetSomeData.txt

**Step 1.2) Convert data (to .fastq format)

Follow instructions in 01_GetSomeData.txt

**Step 2) Quality Assessment of raw sequencing data

Follow instructions in 02_QualityControls.txt (point 1 & 2)

**Step 3) Remove 'uninteresting' sequences

Follow instructions in 03_ReadCleaning

**Step 4) Quality Assessment of cleaned sequencing data

Follow instructions in 02_QualityControls.txt (point 3)

**Step 5) Map sequencing reads to reference genome and transcriptome to obtain annotated (with biological attributes) reads

Follow instructions in 04_ReadAnnotation

**Step 6) Quality Assessement of annotated sequencing data

Follow instructions in 02_QualityControls.txt (point 4)

**Output I)                Processed reads, ready for analysis: Annotated sequencing data for each sample.

**********************************************    II) Analysis     ************************************************

Step 7) Compare samples, and identify differences

Step 8) Assess biological meaning of differences
