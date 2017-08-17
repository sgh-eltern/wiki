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
  local src=${1?Missing argument for src folder}
  local root=${2?Missing argument for root folder}

  BACKUP_FILE="${root}"/daily/"${src}"_$(date "+%Y-%m-%d_%H%M").tar.gz

  echo
  echo "Creating daily backup as ${BACKUP_FILE} ..."
  tar --create --exclude-vcs --gzip --file "${BACKUP_FILE}" "${src}"

  register_latest "${BACKUP_FILE}" "${root}"
  echo ...done.
}

dump_eltern-wp_database(){
  local root=${1?Missing argument for root folder}

  DB_BACKUP_LATEST=$(mysqlbackups "<%= config['eltern-wp']['source_db'] %>" | head -1)
  DB_BACKUP_FILE="${root}"/daily/eltern-wp-db_$(date "+%Y-%m-%d_%H%M").sql.gz

  echo
  echo "Saving latest database snapshot ${DB_BACKUP_LATEST} to ${DB_BACKUP_FILE}:"
  mysqldump \
      --add-drop-table \
      --host="${DB_BACKUP_LATEST}" \
      --user="<%= config['eltern-wp']['source_user'] %>" \
      --password="<%= config['eltern-wp']['source_password'] %>" \
    "<%= config['eltern-wp']['source_db'] %>" \
  | gzip \
  > "${DB_BACKUP_FILE}"

  register_latest "${DB_BACKUP_FILE}" "${root}"
  echo ...done.
}

dump_mediawiki_database(){
  local root=${1?Missing argument for root folder}

  DB_BACKUP_LATEST=$(mysqlbackups "<%= config['mediawiki']['source_db'] %>" | head -1)
  DB_BACKUP_FILE="${root}"/daily/mediawiki-db_$(date "+%Y-%m-%d_%H%M").sql.gz

  echo
  echo "Saving latest database snapshot ${DB_BACKUP_LATEST} to ${DB_BACKUP_FILE}:"
  mysqldump \
      --add-drop-table \
      --host="${DB_BACKUP_LATEST}" \
      --user="<%= config['mediawiki']['source_user'] %>" \
      --password="<%= config['mediawiki']['source_password'] %>" \
    "<%= config['mediawiki']['source_db'] %>" \
  | gzip \
  > "${DB_BACKUP_FILE}"

  register_latest "${DB_BACKUP_FILE}" "${root}"
  echo ...done.
}

backup_files() {
  local src=${1?Missing argument for src folder}
  local root=${2?Missing argument for root folder}

  create_folders "${root}"
  dump_files "${src}" "${root}"
  rotate_backups "${root}"
  list_backups "${root}"
}

backup_db(){
  local key=${1?Missing argument for config key}
  local root=${2?Missing argument for root folder}

  create_folders "${root}"
  dump_"$key"_database "${root}"
  rotate_backups "${root}"
  list_backups "${root}"
}

backup_files mediawiki backup/mediawiki-files
backup_db mediawiki backup/mediawiki-db

backup_files eltern-wp backup/eltern-wp-files
backup_db eltern-wp backup/eltern-wp-db
