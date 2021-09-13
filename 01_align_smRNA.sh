#!/bin/bash

##############################
# Define pipeline variables
##############################
base=/fs/ess/PCON0160/workshop-913
datadir=${base}/data/smRNA
results=${base}/results/smRNA
logs=${base}/logs/smRNA

config=${base}/workshop/config
params=${config}/alignment_parameters.sh
normalization=genomic
scratch=/fs/scratch/PCON0160

##############################
# Check and make directories
##############################
if [ ! -d ${datadir} ]
then mkdir -p ${datadir}
fi

if [ ! -d "${logs}" ]
then mkdir -p ${logs}
fi 

if [ ! -d "${results}" ]
then mkdir -p ${results}
fi


##############################
# Copy data to working directory data directory
##############################
seq_data=/fs/ess/PCON0160/deep_sequencing/processed_data/Pearlly_GSL-PY-2242-transfer/smRNA/uniq-fasta
samples=(N2cul2RNAi_1 N2cul2RNAi_2 N2L4440_1 N2L4440_2)
for f in "${samples[@]}"; do
    cp ${seq_data}/${f}_uni_17.fa ${datadir}/
done

##############################
# Define pipeline variables ( dont need to change this )
##############################
pipeline_directory=/fs/ess/PCON0160/script-repo 
run_script=${pipeline_directory}/run_scripts/run_bowtie_align_2.sh

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