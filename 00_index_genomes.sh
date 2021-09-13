#!/usr/bin/sh

wormcom=/fs/ess/PCON0160/wormcommon
org=ce
WSnum=WS279
bowtie_idx=${wormcom}/${org}_${WSnum}/bowtie_index
tailor_idx=${wormcom}/${org}_${WSnum}/tailor_index
logs=/fs/ess/PCON0160/projects/cel-cbr/logs
pipeline_directory=/fs/ess/PCON0160/script-repo

echo """#!/bin/bash

if [ ! -d "${bowtie_idx}" ]; then
mkdir ${bowtie_idx}
fi 

if [ ! -d "${tailor_idx}" ]; then
mkdir ${tailor_idx}
fi 

genomic_fa=${wormcom}/${org}_${WSnum}/${org}_${WSnum}.genomic.fa
gtf_file=${wormcom}/${org}_${WSnum}/${org}_${WSnum}.coding_transcript.gtf
knownrna_fa=${wormcom}/${org}_${WSnum}/${org}_${WSnum}.rna.knownRNA.fa
junc_fa=${wormcom}/${org}_${WSnum}/${org}_${WSnum}.coding_transcript.juncs.fa
mrna_fa=${wormcom}/${org}_${WSnum}/${org}_${WSnum}.mRNA_transcripts.fa

#bowtie
cd ${bowtie_idx}
bowtie-build --quiet \${genomic_fa} ${org}_${WSnum}.genomic
bowtie-build --quiet \${knownrna_fa} ${org}_${WSnum}.knownRNA
bowtie-build --quiet \${junc_fa} ${org}_${WSnum}.coding_transcript.juncs
bowtie-build --quiet \${mrna_fa} ${org}_${WSnum}.mRNA_transcripts

#tailor 
cd ${tailor_idx}
tailor build -f -i \${genomic_fa} -p ${org}_${WSnum}.genomic
tailor build -f -i \${junc_fa} -p ${org}_${WSnum}.juncs
""" > index_bowtie_tailor.sh

echo """#!/bin/bash

#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem=64gb
#SBATCH --account=PCON0160

singularity exec ${pipeline_directory}/singularity/rnaseq bash index_bowtie_tailor.sbatch

""" > index_bowtie_tailor.sbatch

#sbatch --job-name index_bowtie_tailor --output=${logs}/${org}_${WSnum}_bowtie_tailor_index.out index_bowtie_tailor.sbatch

##### ignore below ####
#star
#sjdbOverhang=49
#star_idx=${wormcom}/${org}_${WSnum}/${org}_${WSnum}_genomic_star_idx
#sbatch --job-name star_index_${org}_${WSnum} --output=${logs}/${org}_${WSnum}_STAR_index.out --export=star_idx=${star_idx},fasta=${genomic_fa},gtf=${gtf_file},sjdbOverhang=${sjdbOverhang} STAR_index.sh
