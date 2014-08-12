mkdir ../2_ErrorCorrect
cd ../2_ErrorCorrect
cp /data0/opt/AssemblySoftware/SOAPdenovo/SOAPdenovo2.01/SOAPec_bin_v2.03/bin/* . 
ls ../RawData/*/*fastq > reads.file.list
ln -s ../RawData/*/*fastq . 
echo KmerFreq_AR con
./KmerFreq_AR -k 17 -t 30 -p Bdor reads.file.list >conkmerfreq.log 2> conkmerfreq.err
#echo KmerFreq_AR space
#####./KmerFreq_AR -k 17 -s 6 -t 30 -p Bdor.space reads.file.list >spacekmerfreq.log 2> spacekmerfreq.err
echo Corrector
#######./Corrector_AR -k 17 -l 3 -K 17 -s 6 -L 3 -r 50 -t 30 Bdor.freq.cz Bdor.freq.cz.len Bdor.space.freq.cz Bdor.space.freq.cz.len reads.file.list >corr.log 2>corr.err
./Corrector_AR -k 17 -l 3  -r 50 -t 30 Bdor.freq.cz Bdor.freq.cz.len reads.file.list >corr.log 2>corr.err
ls ../RawData/*/*pair_*.fq.gz > reads.corr.list
./KmerFreq_AR -k 17 -t 30 -p Bdor_corrected reads.corr.list >correctedkmerfreq.log 2> correctedkmerfreq.err

