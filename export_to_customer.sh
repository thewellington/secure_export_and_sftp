#!/bin/bash
#
# A script to export a schema from an Oracle DB, archive the data to .tar.gz.
# The archive is then encrypted using GPG and uploaded to an SFTP server
#
# v1.1 2013-09-27 by Bill Wellington (bill@wellingtonnet.net)

NOW=$(date +"%FT%H%M%S%z")
WORKING_DIR="/data/oracle/u01/app/oracle/oradata/exports/CATS"

# Oracle Settings
TMP=/tmp; export TMP
TMPDIR=$TMP; export TMPDIR

ORACLE_HOSTNAME=db; export ORACLE_HOSTNAME
ORACLE_BASE=/data/oracle/u01/app/oracle; export ORACLE_BASE
ORACLE_HOME=$ORACLE_BASE/product/11.2.0.3/dbhome_1; export ORACLE_HOME
ORACLE_SID=orcl; export ORACLE_SID
ORACLE_TERM=xterm; export ORACLE_TERM

PATH=/usr/sbin:$PATH; export PATH
PATH=/$ORACLE_HOME/bin:$PATH; export PATH

LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib; export CLASSPATH




# export data
echo "Begin Export Datapump."
expdp CATS/CATS DIRECTORY=CATS DUMPFILE=CATS.dmp SCHEMAS=CATS LOGFILE=CATS.log REUSE_DUMPFILES=Y COMPRESSION=ALL

# archive data
echo "Archive .dmp and .log files."
tar -czf $WORKING_DIR/CATS.tgz $WORKING_DIR/CATS.dmp $WORKING_DIR/CATS.log

# encrypt data
echo "Encrypt .tgz file."
gpg -es -u 615FE11A -r 3BC928BF $WORKING_DIR/CATS.tgz
mv $WORKING_DIR/CATS.tgz.gpg $WORKING_DIR/$NOW-CATS.tgz.gpg

# upload encrypted data
echo "Upload .tgz.gpg file to SFTP server."
sftp transfer@10.15.204.12 <<END
lcd $WORKING_DIR
cd /data
put $NOW-CATS.tgz.gpg /data/$NOW-CATS.tgz.gpg
END

# cleanup
echo "Cleaning up files."
rm -f $WORKING_DIR/CATS.tgz
rm -f $WORKING_DIR/$NOW-CATS.tgz.gpg
~                                         