# MediaWiki at Strato

# Manual Installation

1. `ssh eltern-sgh.de@ssh.strato.de` and

    - Create folder /mediawiki
    - Extract MediaWiki 1.28.1 into `mediawiki`

1. In [Strato's admin console](https://strato.de/apps/CustomerService):

    * Create a new SQL database and set a password. Store credentials in LastPass.
    * In _Domains / Domainverwaltung_, map domain `wiki.eltern-sgh.de` to `/mediawiki` (Strato lists this as "Umleitung: (Intern) /mediawiki/")
    * In _Datenbanken und Webspace / PHP-Version einstellen_, switch the PHP version to `7.1`

1. Generate and upload LocalSettings.php (see [Deployment](#deployment) below).

1. Follow the [MediaWiki install wizard](http://wiki.eltern-sgh.de):

    - Create a MediaWiki admin account. Store credentials in LastPass.
    - Set User rights profile to Authorized editors only
    - Upload the [logo](assets/schickhardt.jpg)

# Deployment

* `git clone` this repository
* Copy `sample-config.yml` to `config.yml` and fill in the values (check Lastpass)
* Get a recent Ruby and install bundler in it
* Run `bundle exec rake` to generate the scripts and config into the `deployment` folder
* Deploy the generated files with `scp -r deployment/* eltern-sgh.de@ssh.strato.de:`.

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

# TODO: Backup Rotation

Strategy:

1. if there is no backup for today yet, create it and put it into backup/daily
1. delete files older than 7 days from backup/daily, so that we keep daily backups of the last seven days

1. if it is the last day of the week, copy the backup into backup/weekly, too
1. delete files older than one month from backup/weekly, so that we keep weekly backups of the last month

1. if it is the last day of the month, copy the backup into backup/monthly, too
1. delete files older than three months from backup/monthly, so that we keep monthly backups of the last three months

1. if it is the last day of the year, copy the backup into backup/yearly, too
1. delete files older than 10 years from backup/yearly, so that we keep yearly backups of the last ten years

In bash, deletion would be something like this:

```bash
find backup/monthly/*.gz -maxdepth 1 -type f -mtime +92 -delete
```

# Compatibility

## Force Cantao to PHP 5.6

The version of Cantao that is currently in use does not work with PHP 7. Work around this by prepending `geb3/.htaccess` with the following statement:

```php
# Force Strato's PHP to 5.6
AddType application/x-httpd-php56 .php
…
```
