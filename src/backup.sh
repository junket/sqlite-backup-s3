#! /bin/bash

set -e
set -o pipefail

source ./env.sh

echo "Creating backup of .db files in $SQLITE_DATABASE_DIRECTORY..."

timestamp=$(date +"%Y-%m-%dT%H:%M:%S")

for file in "$SQLITE_DATABASE_DIRECTORY"/*.db; do
  database_file_name=$(basename -- "$file")
  database_name="${database_file_name%.*}"
  backup_name="$database_name-backup-$timestamp.db"
  temp_file="/tmp/$backup_name"

  sqlite3 "$file" ".backup $temp_file"
  gzip "$temp_file"

  if [ -n "$PASSPHRASE" ]; then
    gpg --yes --batch --passphrase="$PASSPHRASE" --output "$temp_file.gpg" -c "$temp_file.gz"
    file_name="$backup_name.gz.gpg"
  else
    file_name="$backup_name.gz"
  fi

  echo "Uploading backup to $S3_BUCKET..."

  date=$(date +"%a, %d %b %Y %T %z")
  content_type='application/tar+gzip'
  string="PUT\n\n$content_type\n$date\n/$S3_BUCKET/$S3_PREFIX/$file_name"
  signature=$(echo -en "$string" | openssl sha1 -hmac "$AWS_SECRET_ACCESS_KEY" -binary | base64)
  curl -X PUT -T "/tmp/$file_name" \
    -H "Host: $S3_BUCKET.s3.amazonaws.com" \
    -H "Date: $date" \
    -H "Content-Type: $content_type" \
    -H "Authorization: AWS $AWS_ACCESS_KEY_ID:$signature" \
    "https://$S3_BUCKET.s3.amazonaws.com/$S3_PREFIX/$file_name"

  echo "Backup complete."

  rm "/tmp/$file_name"

done
