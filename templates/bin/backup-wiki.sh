#!/usr/bin/env bash

# Generated from <%= template %>

## mediawiki files

ROOT=backup/mediawiki-files
mkdir -p "${ROOT}"/{daily,weekly,monthly,yearly}

MEDIAWIKI_BACKUP_FILE="${ROOT}"/daily/mediawiki_$(date "+%Y-%m-%d_%H%M").tar.gz

echo
echo "Creating daily backup as ${MEDIAWIKI_BACKUP_FILE} ..."
tar --create --exclude-vcs --gzip --file "${MEDIAWIKI_BACKUP_FILE}" mediawiki
echo ...done.

echo
echo Rotating backup files...
bin/rotate-backups "${ROOT}"
echo ...done.

echo
echo "Contents of backup directory ${ROOT}:"
echo
ls -ltr "${ROOT}"/*
echo

## Database

ROOT=backup/mediawiki-db
mkdir -p "${ROOT}"/{daily,weekly,monthly,yearly}

DB_BACKUP_LATEST=$(mysqlbackups "<%= config['source_db'] %>" | head -1)
MEDIAWIKI_DB_BACKUP_FILE="${ROOT}"/daily/mediawiki-db_$(date "+%Y-%m-%d_%H%M").sql.gz

echo
echo "Saving latest database snapshot ${DB_BACKUP_LATEST} to ${MEDIAWIKI_DB_BACKUP_FILE}:"
mysqldump \
    --add-drop-table \
    --host="${DB_BACKUP_LATEST}" \
    --user="<%= config['source_user'] %>" \
    --password="<%= config['source_password'] %>" \
  "<%= config['source_db'] %>" \
| gzip \
> "${MEDIAWIKI_DB_BACKUP_FILE}"
echo ...done.

echo
echo Rotating backup files...
bin/rotate-backups "${ROOT}"
echo ...done.

echo
echo "Contents of backup directory ${ROOT}:"
echo
ls -ltr "${ROOT}"/*
echo
