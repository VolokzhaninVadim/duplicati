#!/bin/bash

echo $(date '+%Y-%m-%d %H %M %S') 'Start load data'
rsync -ave \
ssh -p 42424\
--partial \
--progress \
--delete \
--times \
--archive \
--exclude-from='/home/volokzhanin/Загрузки/backup/exclude_list_notebook.txt' \
/ \
$USER@$CLOUD_DOMEN:/mnt/backup/backup/vvy_notebook/

echo $(date '+%Y-%m-%d %H %M %S') 'Stop load data'
