#!/bin/bash
#SBATCH --cpus-per-task=20
#SBATCH --mem=400G
#SBATCH --time=01-00:00:00
#SBATCH --output=/logs/%A_%a.out
#SBATCH --error=/logs/%A_%a.err

# This script will run FragPipe in headless mode for each dataset individually

# Set dataset ID
ID="PXD000145" # example ID
# Set manifest and workflow files directory
DIR="/ProcessingFiles/"

cd "$DIR"
OUTPUT="/SearchResults/"

mkdir -p "$OUTPUT"

# Set temporary directory for fragpipe
# This was necessary to prevent errors when running headless fragpipe
XDG_CONFIG_HOME="/scratch/gd2417/temp"
export XDG_CONFIG_HOME

# Set path to fragpipe V22.0
FRAGPIPE="/path/to/fragpipe/executable/bin/fragpipe"

# Set variables for the configs
TOOLS="/path/to/fragpipe/tools"
DIANN="/path/to/fragpipe/tools/diann/1.8.2_beta_8/linux/diann-1.8.1.8"
PYTHON="/home/gd2417/miniconda3/envs/FragPipe2/bin/python3.10" #path to python environment

# Path to workflow and manifest
# Both were manually set with Fragpipe GUI
WORKFLOW="/${DIR}/${ID}_workflow.workflow"
MANIFEST="/path/to/${ID}_manifest.fp-manifest"

echo "Starting FragPipe..."

bash "$FRAGPIPE" --headless --workflow "$WORKFLOW" \
         --manifest "$MANIFEST" \
         --workdir "$OUTPUT" \
         --ram 300 \
         --threads 18 \
         --config-tools-folder "$TOOLS" \
         --config-diann "$DIANN" \
         --config-python "$PYTHON"

echo "Done! Your results should be in $OUTPUT"