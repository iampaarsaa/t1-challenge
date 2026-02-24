#!/bin/bash

# Exit on errors, undefined variables, and fail on pipeline errors
# set -euo pipefail
IFS=$'\n\t'

# ---- ENV ----
source /home/debian/script/.db.env        # contains DB_USER, DB_PASSWORD, DB_NAME, DB_HOST
source /home/debian/script/.rclone.env
# ---- CONFIG ----
LOCAL_WORKDIR="/home/debian/script/.tmp"
mkdir -p "$LOCAL_WORKDIR"

SQL_FILE="db_backup.sql"
ZIP_FILE="db_backup.zip"

RCLONE_REMOTE="Arvan"
RCLONE_BUCKET_PATH="parsa-challenge"

LOGFILE="/home/debian/script/db_backup.log"
exec >> "$LOGFILE" 2>&1
echo "---------------------------------------"
echo "MySQL backup job started at $(date)"

# ---- MYSQL DUMP ----
echo "Dumping MySQL database..."
mysqldump -u "$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" -P "$DB_PORT" "$DB_NAME" > "$LOCAL_WORKDIR/$SQL_FILE"

# ---- ZIP THE DUMP ----
echo "Zipping the SQL dump..."
cd "$LOCAL_WORKDIR"
zip "$ZIP_FILE" "$SQL_FILE"

mv "$ZIP_FILE" ..

# Remove raw SQL after zipping
rm "$SQL_FILE"

# ---- UPLOAD VIA RCLONE ----
echo "Uploading to S3 via rclone..."
if ! rclone copy "../$ZIP_FILE" "${RCLONE_REMOTE}:${RCLONE_BUCKET_PATH}"; then
    echo "ERROR: rclone upload failed!" >&2
    exit 1
fi

echo "MySQL backup job finished at $(date)"
echo "---------------------------------------"
