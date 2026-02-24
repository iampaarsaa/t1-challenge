#!/bin/bash

# Exit on errors, undefined variables, and fail on pipeline errors
#set -euo pipefail
IFS=$'\n\t'

# ---- ENV ----
source /home/debian/script/.rclone.env

# ---- CONFIG ----
REMOTE_USER="debian"
REMOTE_HOST="37.152.188.252"
REMOTE_PATH="/var/log/remote-*"

LOCAL_WORKDIR="/home/debian/script/.tmp"
ZIP_NAME="log_archive.zip"

RCLONE_REMOTE="Arvan"
RCLONE_BUCKET_PATH="parsa-challenge"

LOGFILE="/home/debian/script/backup.log"

# Ensure working directory exists
mkdir -p "$LOCAL_WORKDIR"

# Redirect stdout and stderr to log file
exec >> "$LOGFILE" 2>&1

echo "---------------------------------------"
echo "Job started at $(date)"

# ---- COPY FILES ----
echo "Copying files from remote server..."
if ! scp -r "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}" "$LOCAL_WORKDIR/"; then
    echo "ERROR: SCP failed!" >&2
    exit 1
fi

# ---- ZIP FILES ----
echo "Zipping files locally..."
cd "$LOCAL_WORKDIR"
if ! zip -r "$ZIP_NAME" .; then
    echo "ERROR: Zip failed!" >&2
    exit 1
fi

# Move zip to parent directory
mv "$ZIP_NAME" ..

# ---- UPLOAD VIA RCLONE ----
echo "Uploading to S3 via rclone..."
if ! rclone copy "../$ZIP_NAME" "${RCLONE_REMOTE}:${RCLONE_BUCKET_PATH}"; then
    echo "ERROR: rclone upload failed!" >&2
    exit 1
fi

# Optional: cleanup old temp files to avoid disk clutter
echo "Cleaning up local files..."
rm -rf "$LOCAL_WORKDIR"/*

echo "Job finished at $(date)"
echo "---------------------------------------"
