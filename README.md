# Backing up a MediaWiki instance at Strato

# Backup

## Database

Strato does this for us; use `mysqlbackups "${source_db}"` to see a list.

## Filesystem

`~/bin/backup-wiki` is scheduled as cron job via the web interface

# Restore

## Database

Pipe the most recent snapshot into the new DB that we use for restore. This is stored as script at `~/bin/restore-mediawiki-snapshot`.

## Filesystem

1. Untar the backup file (grab the latest from `~/backup/mediawiki_*.tar.gz`) to `restored-mediawiki`
1. Edit `restored-mediawiki/LocalSettings.php`:
  * Change database settings `$wgDBname`, `$wgDBuser` and `$wgDBpassword` to point to the restored DB
  * Change `$wgSitename` to something like "Restored Copy"
  * Change `$wgServer` to "http://restored-wiki.eltern-sgh.de";`
  * Set the wiki to read-only with this message:

    ```php
    $wgReadOnly = 'Restore-Test; nur Lesen möglich';
    ```

If this is a real disaster recovery and not just a fire drill, just restore to the original database credentials and do not modify the `LocalSettings.php` after untaring it.

# Deployment

Variables are in `.envrc` and git-ignored. Check Lastpass for the values. Use `scripts/generate-scripts` to generate the scripts into `bin` using environment variables and deploy them with `scp -r bin eltern-sgh.de@ssh.strato.de:`.
