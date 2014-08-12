mkdir ../3_Fastqc_ErrorCorrectedData
cd ../RawData/  
/data0/opt/SequenceHandling/fastqc/FastQC/fastqc -t 32 -o ../3_Fastqc_ErrorCorrectedData */*fq.gz
cd ../Scripts
./scrape_fastqc.py ../3_Fastqc_ErrorCorrectedData > ../3_Fastqc_ErrorCorrectedData/fastqc.summary.txt

