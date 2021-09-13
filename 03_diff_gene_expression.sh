#!/bin/bash

logs=/fs/ess/PCON0160/projects/eggd1-eggd2/logs/smRNA
base=/fs/ess/PCON0160/projects/eggd1-eggd2/results/smRNA
bin=/fs/ess/PCON0160/script-repo/bin
tables=${base}/counts
pdfs=${base}/pdfs

module load R/3.6.3-gnu9.1

##############################
# Differential gene expression
##############################
cat ${tables}/coding-transcript-exon-26G.txt |\
    head -1 |\
    cut -f 2- |\
    awk -F"_x" '{
        split($1,a,"\t")

        print "sample""\t""condition"
        
        for(i=1; i<=length(a); i++)
        {   

            if ( match( a[i], "RFP") )
            {
                print a[i]"\t""control"
            }
            else if ( match( a[i], "eggd1_" ))
            {
                print a[i]"\t""eggd1"
            }
            else if ( match( a[i], "eggd2_" ))
            {
                print a[i]"\t""eggd2"
            }
            else
            {
                print a[i]"\t""eggd12"
            }
        }
    }' > ${tables}/smRNA-seq-counts.coldata

# in the form wildtype vs mutant 
echo -e "control\teggd1" > ${tables}/smRNA-seq-counts.comparisons
echo -e "control\teggd2" >> ${tables}/smRNA-seq-counts.comparisons
echo -e "control\teggd12" >> ${tables}/smRNA-seq-counts.comparisons
echo -e "eggd12\teggd1" >> ${tables}/smRNA-seq-counts.comparisons
echo -e "eggd12\teggd2" >> ${tables}/smRNA-seq-counts.comparisons

quantifications=(transcriptome-anti-22G.txt transcriptome-anti-26G.txt piRNA-sense.txt transcriptome-anti-26G-alg-targets.txt)
for f in "${quantifications[@]}"; do
    ou_name=`basename ${f} .txt`
    Rscript ${bin}/smRNA_seq.R ${tables}/${f} ${tables}/smRNA-seq-counts.coldata ${tables}/smRNA-seq-counts.comparisons ${ou_name}
    mv ${tables}/*.pdf ${pdfs}
done
