#!/bin/bash

##############################
# Set paths
##############################
logs=/fs/ess/PCON0160/projects/eggd1-eggd2/logs/smRNA
base=/fs/ess/PCON0160/projects/eggd1-eggd2/results/smRNA
bin=/fs/ess/PCON0160/script-repo/bin

##############################
# Load modules
##############################
source activate rnaseq

##############################
# Make out directories
##############################
tables=${base}/counts
pdfs=${base}/pdfs

if [ ! -d "${tables}" ]
then mkdir ${tables}
fi

if [ ! -d "${pdfs}" ]
then mkdir ${pdfs}
fi

##############################
# Alignment summary
##############################
echo "" > ${base}/alignment_summary.txt
for f in `ls ${logs}/*_bowtie_align.out`; do 
    
    name=`basename $f _bowtie_align.out`
    echo -e "=======================================" >> ${base}/alignment_summary.txt
    echo ${name} >> ${base}/alignment_summary.txt
    cat ${f} | grep ">>" >> ${base}/alignment_summary.txt
    echo -e "=======================================" >> ${base}/alignment_summary.txt
    echo "" >> ${base}/alignment_summary.txt

done

##############################
# counts tables
##############################
python3 ${bin}/combine_gene_counts.py ${base}/ppm .coding_transcript.exon.anti.26G.ppm ${tables}/coding-transcript-exon-26G.txt
python3 ${bin}/combine_gene_counts.py ${base}/ppm .coding_transcript.exon.anti.22G.ppm ${tables}/coding-transcript-exon-22G.txt
python3 ${bin}/combine_gene_counts.py ${base}/ppm .coding_transcript.exon.sense.ppm ${tables}/coding-transcript-exon-sense.txt
python3 ${bin}/combine_gene_counts.py ${base}/ppm .pseudogene.anti.ppm ${tables}/pseudogene-anti.txt
python3 ${bin}/combine_gene_counts.py ${base}/ppm .piRNA.sense.ppm ${tables}/piRNA-sense.txt
python3 ${bin}/combine_gene_counts.py ${base}/ppm .gpltx.anti.22G.ppm ${tables}/transcriptome-anti-22G.txt
python3 ${bin}/combine_gene_counts.py ${base}/ppm .gpltx.anti.26G.ppm ${tables}/transcriptome-anti-26G.txt
python3 ${bin}/combine_gene_counts.py ${base}/ppm .gpltx.sense.ppm ${tables}/transcriptome-sense.txt

##############################
# Differential gene expression
##############################
cat ${tables}/coding-transcript-exon-22G.txt |\
    head -1 |\
    cut -f 2- |\
    awk -F"_x" '{
        split($1,a,"\t")

        print "sample""\t""condition"
        
        for(i=1; i<=length(a); i++)
        {   

            if ( match( a[i], "N2cul2RNAi") )
            {
                print a[i]"\t""RNAi"
            }
            else
            {
                print a[i]"\t""L4440"
            }
        }
    }' > ${tables}/smRNA-seq-counts.coldata

# in the form wildtype vs mutant 
echo -e "L4440\tRNAi" > ${tables}/smRNA-seq-counts.comparisons

quantifications=(transcriptome-anti-22G.txt piRNA-sense.txt)
for f in "${quantifications[@]}"; do
    ou_name=`basename ${f} .txt`
    Rscript ${bin}/smRNA_seq.R ${tables}/${f} ${tables}/smRNA-seq-counts.coldata ${tables}/smRNA-seq-counts.comparisons ${ou_name}
    mv ${tables}/*.pdf ${pdfs}
done

