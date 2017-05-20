#!/usr/bin/env bash

# Generated from <%= template %>

mkdir -p backup/{daily,weekly,monthly,yearly}

echo Creating daily backup
echo
tar --create --exclude-vcs --gzip --file "backup/daily/mediawiki_$(date "+%Y-%m-%d_%H%M").tar.gz" mediawiki

echo Rotating backup files
echo
bin/rotate-backups

# Report
echo Available database snapshots:
echo
mysqlbackups "<%= config['source_db'] %>"
echo
echo Content of backup directory:
echo
ls -ltr backup/*
echo
