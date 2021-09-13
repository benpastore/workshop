#!/bin/bash

#SBATCH --time=01:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem=64gb
#SBATCH --account=PCON0160


singularity exec /fs/ess/PCON0160/script-repo/singularity/rnaseq bash index_bowtie_tailor.sbatch


