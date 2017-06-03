#!/usr/bin/env bash

# Generated from <%= template %>

create_folders() {
  local root=${1?Missing argument for root folder}
  mkdir -p "${root}"/{daily,weekly,monthly,yearly}
}

rotate_backups() {
  local root=${1?Missing argument for root folder}

  echo
  echo Rotating backup files...
  bin/rotate-backups "${root}"
  echo ...done.
}

list_backups() {
  local root=${1?Missing argument for root folder}

  echo
  echo "Contents of backup directory ${root}:"
  echo
  ls -ltr "${root}"/*
  echo
}

register_latest(){
  local registrant=${1?Missing argument for file to register}
  local registry=${2?Missing argument for registry folder}

  # At Strato, scp doesn't seem to follow symlinks, so we write the file path
  # to a file which can then be read to find out the latest backup
  echo "Registering ${registrant} as latest in ${registry}/latest"
  echo "${registrant}" > "${registry}"/latest
}

dump_files(){
  local root=${1?Missing argument for root folder}

  MEDIAWIKI_BACKUP_FILE="${root}"/daily/mediawiki_$(date "+%Y-%m-%d_%H%M").tar.gz

  echo
  echo "Creating daily backup as ${MEDIAWIKI_BACKUP_FILE} ..."
  tar --create --exclude-vcs --gzip --file "${MEDIAWIKI_BACKUP_FILE}" mediawiki

  register_latest "${MEDIAWIKI_BACKUP_FILE}" "${root}"
  echo ...done.
}

dump_database(){
  local root=${1?Missing argument for root folder}

  DB_BACKUP_LATEST=$(mysqlbackups "<%= config['source_db'] %>" | head -1)
  MEDIAWIKI_DB_BACKUP_FILE="${root}"/daily/mediawiki-db_$(date "+%Y-%m-%d_%H%M").sql.gz

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

  register_latest "${MEDIAWIKI_DB_BACKUP_FILE}" "${root}"
  echo ...done.
}

backup_files() {
  local root=${1?Missing argument for root folder}

  create_folders "${root}"
  dump_files "${root}"
  rotate_backups "${root}"
  list_backups "${root}"
}

backup_db(){
  local root=${1?Missing argument for root folder}

  create_folders "${root}"
  dump_database "${root}"
  rotate_backups "${root}"
  list_backups "${root}"
}

backup_files backup/mediawiki-files
backup_db backup/mediawiki-db
