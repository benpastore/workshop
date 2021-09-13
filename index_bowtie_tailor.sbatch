#!/bin/bash

if [ ! -d /fs/ess/PCON0160/wormcommon/ce_WS279/bowtie_index ]; then
mkdir /fs/ess/PCON0160/wormcommon/ce_WS279/bowtie_index
fi 

if [ ! -d /fs/ess/PCON0160/wormcommon/ce_WS279/tailor_index ]; then
mkdir /fs/ess/PCON0160/wormcommon/ce_WS279/tailor_index
fi 

genomic_fa=/fs/ess/PCON0160/wormcommon/ce_WS279/ce_WS279.genomic.fa
gtf_file=/fs/ess/PCON0160/wormcommon/ce_WS279/ce_WS279.coding_transcript.gtf
knownrna_fa=/fs/ess/PCON0160/wormcommon/ce_WS279/ce_WS279.rna.knownRNA.fa
junc_fa=/fs/ess/PCON0160/wormcommon/ce_WS279/ce_WS279.coding_transcript.juncs.fa
mrna_fa=/fs/ess/PCON0160/wormcommon/ce_WS279/ce_WS279.mRNA_transcripts.fa

#bowtie
cd /fs/ess/PCON0160/wormcommon/ce_WS279/bowtie_index
bowtie-build --quiet ${genomic_fa} ce_WS279.genomic
bowtie-build --quiet ${knownrna_fa} ce_WS279.knownRNA
bowtie-build --quiet ${junc_fa} ce_WS279.coding_transcript.juncs
bowtie-build --quiet ${mrna_fa} ce_WS279.mRNA_transcripts

#tailor 
cd /fs/ess/PCON0160/wormcommon/ce_WS279/tailor_index
tailor build -f -i ${genomic_fa} -p ce_WS279.genomic
tailor build -f -i ${junc_fa} -p ce_WS279.juncs

