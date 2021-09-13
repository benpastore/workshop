#!/usr/bin/bash

##############################
# Define pipeline variables
##############################
base=/fs/ess/PCON0160/projects/eggd1-eggd2
datadir=${base}/data/smRNA
results=${base}/results/smRNA
logs=${base}/logs/smRNA_test
config=${base}/eggd1-eggd2-git-repo/config
params=${config}/alignment_parameters.sh
normalization=genomic
scratch=/fs/scratch/PCON0160

##############################
# Copy data to working directory data directory
##############################
seq_data=/fs/ess/PCON0160/deep_sequencing/processed_data/Pearlly_GSL-PY-1895-transfer/uniq-fasta
samples=(eggd2_1 eggd2_2 RFPPGL1_1 RFPPGL1_2)
for f in "${samples[@]}"; do
    cp ${seq_data}/${f}_uni_17.fa ${datadir}/
done

##############################
# Define pipeline variables ( dont need to change this )
##############################
pipeline_directory=/fs/ess/PCON0160/script-repo 
run_script=${pipeline_directory}/run_scripts/run_bowtie_align.sh

##############################
# Check and make directories
##############################
if [ ! -d ${datadir} ]
then mkdir ${datadir}
fi

if [ ! -d "${logs}" ]
then mkdir ${logs}
fi 

if [ ! -d "${results}" ]
then mkdir ${results}
fi

##############################
# Submit jobs to HPC
##############################
for f in `ls ${datadir}/*_uni_17.fa`; do 

    refs=${config}/reference_paths_ce.txt
    name=`basename ${f} _uni_17.fa`
    echo -e "-- Processing ${name} --"
    sbatch --job-name ${name}\_bowtie_align --output=${logs}/${name}\_bowtie_align.out --export=F=${f},name=${name},scratch=${scratch},logs=${logs},results=${results},norm=${normalization},refpaths=${refs},params=${params},pipeline_directory=${pipeline_directory} ${run_script}
    sleep 0.25s
    echo ""
    
done