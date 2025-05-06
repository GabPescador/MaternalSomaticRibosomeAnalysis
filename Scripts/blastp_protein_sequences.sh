#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=100G
#SBATCH --time=01-00:00:00
#SBATCH --output=/logs/%A_%a.out
#SBATCH --error=/logs/%A_%a.err

# This script will blast 2 protein FASTA sequences with multiple entries for similarity

# set diretory
cd /OutputTables/

# Set variables
ZF="./Danio_rerio_output.fasta"
RB="./Rabbit_output.fasta"

makeblastdb -in $RB -dbtype prot -out ./RB_db

blastp -query $ZF \
  -db ./RB_db \
  -outfmt "6 qseqid sseqid pident length evalue bitscore" \
  -evalue 1e-5 \
  -out ./ZF_vs_RB.tsv