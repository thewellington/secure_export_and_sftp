#!/bin/bash
#
# A script to manage file rotation
#
# v1.0 2013-09-27 by Bill Wellington (bill@wellingtonnet.net)

DATADIR=/home/chroot/home/transfer/data/
ARCHIVEDIR=/home/chroot/home/transfer/archive/

## Find all files older than x days (-mmin +x) and move them to the archive
/bin/find $DATADIR -type f -mmin +60 -exec mv {} $ARCHIVEDIR \;

## Find all files in archive directory, older that x days (-mtime +x) and delete them
/bin/find $ARCHIVEDIR -type f -mtime +10 -delete