#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=220G
#SBATCH --time=03-00:00:00
#SBATCH --output=/logs/%A_%a.out
#SBATCH --error=/logs/%A_%a.err

# This script will use a .csv file with dataset IDs from ProteomeXchange or Pride and download all the raw files associated with the ID.

# Don't forget to have a conda environment with FTP

# Set directory
cd /path/to/directory/

# Path to your CSV file with identifiers
CSV_FILE="/ProcessingFiles/Datasets.csv"

# Directory to store downloaded files
DOWNLOAD_DIR="/path/to/directory/to/download/"

# Check if download directory exists, create if not
mkdir -p "$DOWNLOAD_DIR"

# Define the base URL for ProteomeXchange data
BASE_URL="ftp://ftp.pride.ebi.ac.uk/pride/data/archive"

# Read the CSV file (skipping the header)
tail -n +2 "$CSV_FILE" | while IFS=, read -r identifier announce_date; do
  # Create a directory for the accession ID
  accession_dir="${DOWNLOAD_DIR}/${identifier}"
  mkdir -p "$accession_dir"

  YEAR=$(echo "$announce_date" | cut -d'/' -f3 | tr -d '\r')
  MONTH=$(echo "$announce_date" | cut -d'/' -f1 | tr -d '\r')

  # Add leading zero to month if necessary (i.e., if the month is a single digit)
  if [ "$MONTH" -lt 10 ]; then
    MONTH="0$MONTH"
  fi

  # Construct the full URL to the series matrix file (you can modify this as needed)
  SERIES_URL="ftp://ftp.pride.ebi.ac.uk/pride/data/archive/20${YEAR}/${MONTH}/${identifier}/"

  echo "Constructed URL: $SERIES_URL"

  # How links are constructed: ftp://ftp.pride.ebi.ac.uk/pride/data/archive/YEAR/MONTH/identifier

  # Download the file into the new directory (change this based on actual download source)
  # Using wget/curl since fasterq-dump did not work

  # Example with wget (if you have URLs):
  wget -r --no-parent -nH --cut-dirs=6 -P "$accession_dir" -v "${SERIES_URL}"

  # -q will run quietly and --show-progress will give simplified progress bars
  # -v will give more detailed information about the download progress

  echo "Downloaded $identifier to $accession_dir"
done

echo "Download completed. raw files are saved in ${DOWNLOAD_DIR}"
