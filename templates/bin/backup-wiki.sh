#!/usr/bin/env bash

# Generated from <%= template %>

mkdir -p backup/{daily,weekly,monthly,yearly}
tar --create --exclude-vcs --gzip --file "backup/daily/mediawiki_$(date "+%Y-%m-%d_%H%M").tar.gz" mediawiki

# Report
echo Available database snapshots:
echo
mysqlbackups "<%= config['source_db'] %>"
echo
echo Content of backup directory:
echo
ls -ltr backup/*
echo
