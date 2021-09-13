# workshop
smRNA sequencing analysis workshop

# STEPS 

1. Generate genome indicies. Run *bash 00_index_genomes.sh* **takes about 30 minutes, only run if index is not already present**
2. Align reads to references. Run *bash 01_align_smRNA.sh* **takes ~1.5 hours~
3. Proceess alignments by running: *bash 02_process_smRNA_alignment.sh* 
4. Basic differential gene expression analysis: *bash 03_diff_gene_expression.sh*
