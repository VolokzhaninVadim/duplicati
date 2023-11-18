#!/bin/bash

echo $(date '+%Y-%m-%d %H %M %S') 'Create variables'
FILE=$(date '+%Y-%m-%d_%H_%M_%S')
ARCHIVE_TYPE='zst'
GPG_TYPE='gpg'
PROJECT='system'
DIRECTORY_TARGET='/mnt/backup/backup/backup'
DIRECTORY_SOURCE="${DIRECTORY_TARGET}/packages.txt $DIRECTORY_TARGET/test $DIRECTORY_TARGET/crontab /home/volokzhanin/.ssh /home/volokzhanin/.gnupg /mnt/backup/backup/vvy_router /mnt/backup/backup/vvy_nas /mnt/backup/backup/gpg /mnt/backup/backup/vvy_evolution"
DIRECTORY_S3='/mnt/s3/backup/'$PROJECT
GPG_KEY=634064C6
GPG_PASSPHRASE=/home/volokzhanin/.gnupg/backup_passphrase

echo $(date '+%Y-%m-%d %H %M %S') 'Create list of packages'
dpkg --get-selections | grep -v deinstall > $DIRECTORY_TARGET/packages.txt

echo $(date '+%Y-%m-%d %H %M %S') 'Create list of environment variables'
printenv > $DIRECTORY_TARGET/test

echo $(date '+%Y-%m-%d %H %M %S') 'Create crontab tasks'
crontab -l > $DIRECTORY_TARGET/crontab

echo $(date '+%Y-%m-%d %H %M %S') 'Create archive'
tar --create \
    --zstd \
    --file=$DIRECTORY_TARGET/$FILE'_'$PROJECT'_''.'$ARCHIVE_TYPE \
    --ignore-failed-read \
    --preserve-permissions \
    --verbose \
$DIRECTORY_SOURCE
rm $DIRECTORY_TARGET/packages.txt
rm $DIRECTORY_TARGET/crontab
rm $DIRECTORY_TARGET/test

echo $(date '+%Y-%m-%d %H %M %S') 'Create encrypted archive'
gpg --recipient $GPG_KEY \
    --symmetric \
    --batch \
    --passphrase-file $GPG_PASSPHRASE \
    --no-tty \
    --encrypt $DIRECTORY_TARGET/$FILE'_'$PROJECT'_''.'$ARCHIVE_TYPE

echo $(date '+%Y-%m-%d %H %M %S') 'Remove archive'
rm $DIRECTORY_TARGET/$FILE'_'$PROJECT'_''.'$ARCHIVE_TYPE

echo $(date '+%Y-%m-%d %H %M %S') 'Move file'
rsync --partial --progress $DIRECTORY_TARGET/$FILE'_'$PROJECT'_''.'$ARCHIVE_TYPE'.'$GPG_TYPE $DIRECTORY_S3
rm $DIRECTORY_TARGET/$FILE'_'$PROJECT'_''.'$ARCHIVE_TYPE'.'$GPG_TYPE

echo $(date '+%Y-%m-%d %H %M %S') 'Delete files older than n days'
find $DIRECTORY_S3 -mtime +14 \
    -type f \
    -delete
