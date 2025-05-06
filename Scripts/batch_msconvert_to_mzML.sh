#!/bin/bash
#SBATCH --cpus-per-task=20
#SBATCH --mem=400G
#SBATCH --time=10-00:00:00
#SBATCH --output=/logs/%A_%a.out
#SBATCH --error=/logs/%A_%a.err

# This script will use msconvert to convert all different kinds of raw files into mzML format. This step is necessary as some raw file formats
# were not supported by FragPipe at the time

# For raw files that are not from Bruker ion mobility instruments, msconvert will call peaks in MS1
# Note: This will make quantification at MS1 impossible, so only MS2 quantification can be taken from the converted files

# For Bruker ion mobility .d folders, msconvert will call peaks in MS1 and process ion mobility with default values

# Set directory
DIR="/path/to/directory/"
cd "$DIR"

# Set variables for the configs
MSCONVERT="/opt/apps/dev/containers/msconvert/1.0/pwiz-skyline-i-agree-to-the-vendor-licenses_latest.sif"

# List all raw files to be converted
# Directory to search in (current directory by default)
DIR_RAW=${1:-"/path/to/raw/files/"}

# Singularity msconvert use
echo "Starting msconvert..."

# Find files with the following extensions: .t2d, .wiff, .wiff2, .lcd, .raw, .RAW
# Also include directories with .d suffix

find "$DIR_RAW" \( -name '*.raw' -o -name '*.RAW' -o -name '*.wiff' -o -name '*.wiff2' -o -type d -name '*.d' \) | while read -r f; do

  # Check if the file is a supported file format or a .d directory
  if [[ "$f" == *.raw || "$f" == *.RAW || "$f" == *.wiff || "$f" == *.wiff2 ]]; then
    # Change the extension to .mzML
    f2="${f%.*}.mzML"
    
    # Skip conversion if the .mzML file already exists
    if [ ! -f "$f2" ]; then
      outdir=$(dirname "$f2")

      # Ensure the output directory exists
      mkdir -p "$outdir"
    
      # Run msconvert with Singularity and Wine
      singularity exec -B /home/gd2417/mywineprefix:/mywineprefix /opt/apps/dev/containers/msconvert/1.0/pwiz-skyline-i-agree-to-the-vendor-licenses_latest.sif \
      mywine msconvert --64 --zlib --filter "peakPicking" --filter "zeroSamples removeExtra 1-" --outdir "$outdir" "$f"

      echo "Converted $f to $f2"
    else
      echo "Skipping $f as $f2 already exists"
    fi

  elif [[ "$f" == *.d ]]; then
    # For .d directories, just append .mzML
    f2="${f}.mzML"

    # Skip conversion if the .mzML file already exists
    if [ ! -f "$f2" ]; then
      outdir=$(dirname "$f2")

      # Ensure the output directory exists
      mkdir -p "$outdir"
    
      # Run msconvert with Singularity and Wine
      singularity exec -B /home/gd2417/mywineprefix:/mywineprefix /opt/apps/dev/containers/msconvert/1.0/pwiz-skyline-i-agree-to-the-vendor-licenses_latest.sif \
      mywine msconvert --64 --zlib --combineIonMobilitySpectra --filter "peakPicking" --filter "scanSumming precursorTol=0.05 scanTimeTol=5 ionMobilityTol=0.1" --outdir "$outdir" "$f"

      echo "Converted $f to $f2"
    else
      echo "Skipping $f as $f2 already exists"
    fi
  fi
done

echo "Done! Your files should be in $OUTPUT"