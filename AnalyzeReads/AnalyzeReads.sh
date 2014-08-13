#!/bin/bash

##############################################################
# User-configurable options for the AnalyzeReads mini-pipeline


## TODO handle subdirectories of RawReads
## TODO handle phred score automatically from parsing output of Fastqc
## TODO handle ILLUMINACLIP stuff automatically (?)

NUMBER_OF_THREADS=20

RAW_READS_DIRECTORY="RawReads"
TRIMMED_READS_DIRECTORY="TrimmedReads"
FASTQC_OUTPUT_DIRECTORY="FastqcOutput"
FASTQC_OUTPUT_DIRECTORY_BEFORE_TRIM=$FASTQC_OUTPUT_DIRECTORY/"Untrimmed"
FASTQC_OUTPUT_DIRECTORY_AFTER_TRIM=$FASTQC_OUTPUT_DIRECTORY/"Trimmed"

NUMBER_OF_READS_PER_SUBSET=10000 # TODO no this is #lines per subset!
SUBSET_DIRECTORY="SubsetData"
SUBSET_DIRECTORY_BEFORE_TRIM=$SUBSET_DIRECTORY/"Untrimmed"
SUBSET_DIRECTORY_AFTER_TRIM=$SUBSET_DIRECTORY/"Trimmed"

# End of user-configurable options -- please don't change anything below
########################################################################

module load fastq_tools

# Verify required executables, input files are available
# Dependencies: RawReads directory contains files with extension .fastq
#               fastqc, scrape_fastqc.py, trimmomatic (wrapper for .jar) are in PATH
# TODO


# Create some directories
mkdir $FASTQC_OUTPUT_DIRECTORY
mkdir $FASTQC_OUTPUT_DIRECTORY_BEFORE_TRIM
mkdir $FASTQC_OUTPUT_DIRECTORY_AFTER_TRIM
mkdir $SUBSET_DIRECTORY
mkdir $SUBSET_DIRECTORY_BEFORE_TRIM
mkdir $SUBSET_DIRECTORY_AFTER_TRIM
mkdir $TRIMMED_READS_DIRECTORY

# Subset reads
cd $RAW_READS_DIRECTORY
for library in *.fastq
do
    echo "Subsetting " $library "..."
    head -n $NUMBER_OF_READS_PER_SUBSET $library > ../$SUBSET_DIRECTORY_BEFORE_TRIM/$library
done
cd ..

# Run fastqc
echo "Running Fastqc..."
fastqc -t $NUMBER_OF_THREADS -o $FASTQC_OUTPUT_DIRECTORY_BEFORE_TRIM $SUBSET_DIRECTORY_BEFORE_TRIM/*.fastq

# Generate summary of fastqc results
scrape_fastqc.py $FASTQC_OUTPUT_DIRECTORY_BEFORE_TRIM > $FASTQC_OUTPUT_DIRECTORY_BEFORE_TRIM/fastqc.summary.txt

# Run trimmomatic on each pair of reads
for library_name in `ls RawReads/ | sed 's/\.R[12].*//' | sort | uniq`
do
    echo "Running Trimmomatic on $library_name..."
    trimmomatic PE -threads $NUMBER_OF_THREADS -phred64 $RAW_READS_DIRECTORY/$library_name.R1.fastq $RAW_READS_DIRECTORY/$library_name.R2.fastq $TRIMMED_READS_DIRECTORY/$library_name.trimmed.R1.fastq $TRIMMED_READS_DIRECTORY/$library_name.single.R1.fastq $TRIMMED_READS_DIRECTORY/$library_name.trimmed.R2.fastq $TRIMMED_READS_DIRECTORY/$library_name.single.R2.fastq ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:10 TRAILING:15 SLIDINGWINDOW:4:15 MINLEN:36
done

# Subset trimmed reads
cd $TRIMMED_READS_DIRECTORY
for library in *.fastq
do
    echo "Subsetting " $library "..."
    head -n $NUMBER_OF_READS_PER_SUBSET $library > ../$SUBSET_DIRECTORY_AFTER_TRIM/$library
done
cd ..

# Run fastqc again
echo "Running Fastqc on trimmed reads..."
fastqc -t $NUMBER_OF_THREADS -o $FASTQC_OUTPUT_DIRECTORY_AFTER_TRIM $TRIMMED_READS_DIRECTORY/*.fastq

# Generate another summary
scrape_fastqc.py $FASTQC_OUTPUT_DIRECTORY_AFTER_TRIM > ../$FASTQC_OUTPUT_DIRECTORY_AFTER_TRIM/fastqc.summary.txt

# Write report or whatever
echo "Writing report..."
# TODO
