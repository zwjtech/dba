#!/bin/bash
. abc.sh
source /home/oracle/.bash_profile
mkdir -p $ORACLE_BASE/admin/$ORACLE_SID/adump
mkdir -p $ORACLE_BASE/oradata/$ORACLE_SID
mkdir -p $ORACLE_BASE/fast_recovery_area

orapwd  file=$ORACLE_HOME/dbs/orapw$ORACLE_SID  password=oracle force=y

#cat > $ORACLE_HOME/dbs/init$ORACLE_SID << EOF
cat > $ORACLE_HOME/dbs/init${ORACLE_SID}.ora << EOF
db_name=$ORACLE_SID
memory_target=$memory_target
processes=$processes
audit_file_dest=$ORACLE_BASE/admin/$ORACLE_SID/adump
audit_trail ='db'
db_block_size=8192
db_domain=''
db_recovery_file_dest=$ORACLE_BASE/fast_recovery_area
db_recovery_file_dest_size=$db_recovery_file_dest_size
open_cursors=2000
undo_tablespace=undotbs1
control_files = ('$ORACLE_BASE/oradata/$ORACLE_SID/control01.ctl','$ORACLE_BASE/oradata/$ORACLE_SID/control02.ctl','$ORACLE_BASE/oradata/$ORACLE_SID/control03.ctl')
compatible ='11.2.0'
EOF

cat > /home/oracle/createDB.sql << EOF
CREATE DATABASE CL
   USER SYS IDENTIFIED BY oracle
   USER SYSTEM IDENTIFIED BY oracle
   LOGFILE  GROUP 1 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo01a.log','$ORACLE_BASE/oradata/$ORACLE_SID/redo01b.log') SIZE 500M,
            GROUP 2 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo02a.log','$ORACLE_BASE/oradata/$ORACLE_SID/redo02b.log') SIZE 500M,
            GROUP 3 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo03a.log','$ORACLE_BASE/oradata/$ORACLE_SID/redo03b.log') SIZE 500M
   MAXLOGFILES 32
   MAXLOGMEMBERS 5
   MAXLOGHISTORY 100
   MAXDATAFILES 100
   MAXINSTANCES 8
   CHARACTER SET $CHARACTER
   NATIONAL CHARACTER SET AL16UTF16
   DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/system01.dbf' SIZE 2000M autoextend on
   SYSAUX DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/sysaux01.dbf' SIZE 2000M autoextend on
   DEFAULT TEMPORARY TABLESPACE TEMP
      TEMPFILE '$ORACLE_BASE/oradata/$ORACLE_SID/temp01.dbf' 
      SIZE 5000M autoextend on
   UNDO TABLESPACE undotbs1
      DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/undotbs01.dbf'
      SIZE 10000M  AUTOEXTEND ON;
EOF


sqlplus / as sysdba << ENDF
create spfile from pfile;
startup nomount;
@/home/oracle/createDB.sql
connect sys/oracle as sysdba
@?/rdbms/admin/catalog.sql;
@?/rdbms/admin/catproc.sql;
@?/rdbms/admin/catblock.sql;
@?/rdbms/admin/catoctk.sql;
@?/rdbms/admin/owminst.plb;
conn system/oracle
@?/sqlplus/admin/pupbld.sql;
@?/sqlplus/admin/help/hlpbld.sql helpus.sql
create tablespace users datafile '$ORACLE_BASE/oradata/$ORACLE_SID/users01.dbf' size 1g reuse autoextend on next 10m maxsize unlimited extent management local;
alter database default tablespace users;
!mkdir -p $ORACLE_BASE/archivelog
alter system set log_archive_dest_1='location=$ORACLE_BASE/archivelog' scope =both;
shutdown immediate
startup mount
alter database archivelog;
alter database open;
archive log list;
alter system switch logfile;
execute utl_recomp.recomp_serial();
ENDF
# 之前少了一个ENDF

# cat >> $ORACLE_HOME/sqlplus/admin/glogin.sql << ENDFO
cat > $ORACLE_HOME/sqlplus/admin/glogin.sql << ENDFO
set linesize 500;
col tablespace_name for a30;
col file_name for a60;
col member for a80;
col name for a70;
col property_name for a50;
col property_value for a50;
col open_mode for a20;
col database_role for a20
col protection_mode for a20
col switchover_status for a20 
col PARAMETER for a30
col VALUE for a30
col status for a20
col property_name for a30;
col property_value for a50;
col INSTANCE_NAME for a15;
col HOST_NAME for a20;
col STARTUP_TIME for a20;
col DATABASE_STATUS for a20;
col table_name for a30;
col trigger_name for a30;
col owner for a20;
col granted_role for a30;
col grantee for a30;
col segment_name for a30;
col segment_type for a20;
col object_name format a20;
col object_type format a20;
col description for a80;
col APPLIED for a10;
col STATUS for a10;
col path for a30;
col index_name for a30;
ENDFO
