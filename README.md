# MediaWiki at Strato

# Manual Installation

1. `ssh eltern-sgh.de@ssh.strato.de` and

    - Create folder /mediawiki
    - Extract MediaWiki 1.28.1 into `mediawiki`

1. In [Strato's admin console](https://strato.de/apps/CustomerService):

    * Create a new SQL database and set a password. Store credentials in LastPass.
    * In _Domains / Domainverwaltung_, map domain `wiki.eltern-sgh.de` to `/mediawiki` (Strato lists this as "Umleitung: (Intern) /mediawiki/")
    * In _Datenbanken und Webspace / PHP-Version einstellen_, switch the PHP version to `7.1`

1. Generate and upload LocalSettings.php (see [ci](https://github.com/sgh-eltern/ci#deployment)).

1. Follow the [MediaWiki install wizard](http://wiki.eltern-sgh.de):

    - Create a MediaWiki admin account. Store credentials in LastPass.
    - Set User rights profile to Authorized editors only
    - Upload the [logo](assets/schickhardt.jpg)

# Restore

## Database

Pipe the most recent snapshot into the new DB that we use for restore. This is stored as script at `~/bin/restore-mediawiki-snapshot.sh`.

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

# Compatibility

## Force Cantao to PHP 5.6

The version of Cantao that is currently in use does not work with PHP 7. Work around this by prepending `geb3/.htaccess` with the following statement:

```php
# Force Strato's PHP to 5.6
AddType application/x-httpd-php56 .php
…
```
