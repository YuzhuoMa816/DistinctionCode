#!/bin/bash

# ==============================
# Configurable variables
# ==============================


COMPRESS_DATE_THRESHOLD=7
DELETE_DATE_THRESHOLD=30
WORK_DIR="/var/log/deployments"
ARCHIVE_DIR="/var/log/deployments/archive"
LOG_FILE="/var/log/archive_deploys.log"

compressed_file_count=0
deleted_file_count=0


# ==============================
# create archive directory if not exists
# ==============================

mkdir -p  "$ARCHIVE_DIR"

# ==============================
# compress over 7 days files to archive path
# ==============================

while IFS= read -r -d '' file; do
    gzip "$file"
    gz_file="${file}.gz"
    mv "$gz_file" "$ARCHIVE_DIR/"
    compressed_file_count=$((compressed_file_count + 1))

done < <(find "$WORK_DIR" -maxdepth 1 -type f -name "*.log" -mtime +"$COMPRESS_DATE_THRESHOLD" -print0)


# ==============================
# Find all .gz files in the archive directory that are older than 30 days and delete them
# ==============================

while IFS= read -r -d '' gz_file; do
    rm "$gz_file"
    deleted_file_count=$((deleted_file_count + 1))
done < <(find "$ARCHIVE_DIR" -maxdepth 1 -type f -name "*.gz" -mtime +"$DELETE_DATE_THRESHOLD" -print0)

# ==============================
#  disk usage check
# ==============================

disk_usage=$(du -sh "$WORK_DIR" | awk '{print $1}')


# ==============================
#  Summary
# ==============================

summary="compressed=${compressed_file_count}, deleted=${deleted_file_count}, disk_usage=${disk_usage}"

echo "Archive deploy summary:"
echo "Number of compressed files: $compressed_file_count"
echo "Number of deleted files: $deleted_file_count"
echo "Current disk usage of $WORK_DIR: $disk_usage"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] $summary" >> "$LOG_FILE"

exit 0