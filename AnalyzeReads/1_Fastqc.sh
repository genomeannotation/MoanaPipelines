#!/bin/bash

module load fastq_tools

mkdir 1_Fastqc
fastqc -t 20 -o 1_Fastqc SubsetData/*.fastq

