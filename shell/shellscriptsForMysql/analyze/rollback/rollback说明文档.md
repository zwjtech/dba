## 测试过程

```shell
mysql> flush logs;
Query OK, 0 rows affected (0.01 sec)

mysql> show tables;
+---------------------+
| Tables_in_uplooking |
+---------------------+
| binlogrollback      |
| binlogtosql         |
| booboo              |
| rollbacktable       |
| t1                  |
| testtime            |
+---------------------+
6 rows in set (0.00 sec)


mysql> create table gai (id int primary key auto_increment,name varchar(10),age int,updatetime datetime);
Query OK, 0 rows affected (0.03 sec)

mysql> begin;
Query OK, 0 rows affected (0.00 sec)

mysql> insert into gai values (null,'superman',18,sysdate()),(null,'batman',20,sysdate());
Query OK, 2 rows affected (0.00 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> commit;
Query OK, 0 rows affected (0.00 sec)

mysql> desc t1;
+-------+-------------+------+-----+---------+-------+
| Field | Type        | Null | Key | Default | Extra |
+-------+-------------+------+-----+---------+-------+
| id    | int(11)     | YES  |     | NULL    |       |
| name  | varchar(10) | YES  |     | NULL    |       |
| a1    | int(11)     | YES  |     | 0       |       |
| a2    | int(11)     | YES  |     | 0       |       |
| a3    | int(11)     | YES  |     | 0       |       |
+-------+-------------+------+-----+---------+-------+
5 rows in set (0.00 sec)

mysql> select * from t1;
+------+------+------+------+------+
| id   | name | a1   | a2   | a3   |
+------+------+------+------+------+
|    1 | a    |    0 |    0 |    0 |
|    2 | b    |    0 |    0 |    0 |
|    3 | c    |    0 |    0 |    0 |
|    4 | dad  |    0 |    0 |    0 |
+------+------+------+------+------+
4 rows in set (0.00 sec)

mysql> begin;
Query OK, 0 rows affected (0.00 sec)

mysql> update t1 set a1=100 where id=4;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> update gai set age=99 where name='superman';
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> commit;
Query OK, 0 rows affected (0.01 sec)

mysql> select * from gai;
+----+----------+------+---------------------+
| id | name     | age  | updatetime          |
+----+----------+------+---------------------+
|  1 | superman |   99 | 2017-08-23 19:24:56 |
|  2 | batman   |   20 | 2017-08-23 19:24:56 |
+----+----------+------+---------------------+
2 rows in set (0.00 sec)

mysql> update gai set age = 100;
Query OK, 2 rows affected (0.01 sec)
Rows matched: 2  Changed: 2  Warnings: 0
```

1. 此处模拟人为误操作，更新age时没有过滤，现在需要回滚。
2. 回滚的同时，gai表继续执行插入操作


```shell
[root@ToBeRoot ~]# cat xx.sh
for i in `seq 1 10000`
do
	cat >> a.sql << ENDF
insert into gai values (null,'a$i',$i,sysdate());
ENDF
done

[root@ToBeRoot ~]# head a.sql
insert into gai values (null,'a1',1,sysdate());
insert into gai values (null,'a2',2,sysdate());
insert into gai values (null,'a3',3,sysdate());
insert into gai values (null,'a4',4,sysdate());
insert into gai values (null,'a5',5,sysdate());
insert into gai values (null,'a6',6,sysdate());
insert into gai values (null,'a7',7,sysdate());
insert into gai values (null,'a8',8,sysdate());
insert into gai values (null,'a9',9,sysdate());
insert into gai values (null,'a10',10,sysdate());

[root@ToBeRoot ~]# ls
a.sql  binlog_analyze_all.py  binlog_rollbacktest.py  CheckMetadataLock.sh  index.html  mastera.000046  xx.sh

[root@ToBeRoot ~]# booboo uplooking  < a.sql
mysql: [Warning] Using a password on the command line interface can be insecure.

[root@ToBeRoot ~]# python binlog_analyze_all.py mastera.000046 

mysql> select * from binlogtosql limit 20\G;
*************************** 1. row ***************************
     id: 1
  edate: 2017-08-23
  etime: 19:22:52
    pos: 123
  event: Start: binlog v 4, server v 5.7.18-log created 170823 19:22:52
   type: others
sqlinfo: others
*************************** 2. row ***************************
     id: 2
  edate: 2017-08-23
  etime: 19:22:52
    pos: 194
  event: Previous-GTIDs
   type: others
sqlinfo: others
*************************** 3. row ***************************
     id: 3
  edate: 2017-08-23
  etime: 19:24:19
    pos: 259
  event: Anonymous_GTID	last_committed=0	sequence_number=1
   type: others
sqlinfo: others
*************************** 4. row ***************************
     id: 4
  edate: 2017-08-23
  etime: 19:24:19
    pos: 440
  event: Query	thread_id=15692	exec_time=0	error_code=0
   type: others
sqlinfo: others
*************************** 5. row ***************************
     id: 5
  edate: 2017-08-23
  etime: 19:25:01
    pos: 505
  event: Anonymous_GTID	last_committed=1	sequence_number=2
   type: others
sqlinfo: others
*************************** 6. row ***************************
     id: 6
  edate: 2017-08-23
  etime: 19:24:56
    pos: 590
  event: Query	thread_id=15692	exec_time=0	error_code=0
   type: begin
sqlinfo: begin;
*************************** 7. row ***************************
     id: 7
  edate: 2017-08-23
  etime: 19:24:56
    pos: 647
  event: Table_map: `uplooking`.`gai` mapped to number 1345
   type: others
sqlinfo: others
*************************** 8. row ***************************
     id: 8
  edate: 2017-08-23
  etime: 19:24:56
    pos: 726
  event: Write_rows: table id 1345 flags: STMT_END_F
   type: insert
sqlinfo: INSERT INTO `uplooking`.`gai`  SET  id=1, name='superman', age=18, updatetime='2017-08-23 19:24:56', insert  INSERT INTO `uplooking`.`gai`  SET  id=2, name='batman', age=20, updatetime='2017-08-23 19:24:56';
*************************** 9. row ***************************
     id: 9
  edate: 2017-08-23
  etime: 19:25:01
    pos: 757
  event: Xid = 93983
   type: commit
sqlinfo: commit;
*************************** 10. row ***************************
     id: 10
  edate: 2017-08-23
  etime: 19:26:19
    pos: 822
  event: Anonymous_GTID	last_committed=2	sequence_number=3
   type: others
sqlinfo: others
*************************** 11. row ***************************
     id: 11
  edate: 2017-08-23
  etime: 19:25:58
    pos: 899
  event: Query	thread_id=15692	exec_time=0	error_code=0
   type: begin
sqlinfo: begin;
*************************** 12. row ***************************
     id: 12
  edate: 2017-08-23
  etime: 19:25:58
    pos: 955
  event: Table_map: `uplooking`.`t1` mapped to number 269
   type: others
sqlinfo: others
*************************** 13. row ***************************
     id: 13
  edate: 2017-08-23
  etime: 19:25:58
    pos: 1033
  event: Update_rows: table id 269 flags: STMT_END_F
   type: update
sqlinfo: UPDATE `uplooking`.`t1`  SET  id=4, name='dad', a1=100, a2=0, a3=0  WHERE  id=4 and  name='dad' and  a1=0 and  a2=0 and  a3=0;
*************************** 14. row ***************************
     id: 14
  edate: 2017-08-23
  etime: 19:26:17
    pos: 1090
  event: Table_map: `uplooking`.`gai` mapped to number 1345
   type: others
sqlinfo: others
*************************** 15. row ***************************
     id: 15
  edate: 2017-08-23
  etime: 19:26:17
    pos: 1172
  event: Update_rows: table id 1345 flags: STMT_END_F
   type: update
sqlinfo: UPDATE `uplooking`.`gai`  SET  id=1, name='superman', age=99, updatetime='2017-08-23 19:24:56'  WHERE  id=1 and  name='superman' and  age=18 and  updatetime='2017-08-23 19:24:56';
*************************** 16. row ***************************
     id: 16
  edate: 2017-08-23
  etime: 19:26:19
    pos: 1203
  event: Xid = 93988
   type: commit
sqlinfo: commit;
*************************** 17. row ***************************
     id: 17
  edate: 2017-08-23
  etime: 19:26:55
    pos: 1268
  event: Anonymous_GTID	last_committed=3	sequence_number=4
   type: others
sqlinfo: others
*************************** 18. row ***************************
     id: 18
  edate: 2017-08-23
  etime: 19:26:55
    pos: 1345
  event: Query	thread_id=15692	exec_time=0	error_code=0
   type: begin
sqlinfo: begin;
*************************** 19. row ***************************
     id: 19
  edate: 2017-08-23
  etime: 19:26:55
    pos: 1402
  event: Table_map: `uplooking`.`gai` mapped to number 1345
   type: others
sqlinfo: others
*************************** 20. row ***************************
     id: 20
  edate: 2017-08-23
  etime: 19:26:55
    pos: 1526
  event: Update_rows: table id 1345 flags: STMT_END_F
   type: update
sqlinfo: UPDATE `uplooking`.`gai`  WHERE  id=1  name='superman'  age=99  updatetime='2017-08-23 19:24:56'  SET  id=1  name='superman'  age=100  updatetime='2017-08-23 19:24:56'  update  UPDATE `uplooking`.`gai`  SET  id=2, name='batman', age=100, updatetime='2017-08-23 19:24:56'  WHERE  id=2 and  name='batman' and  age=20 and  updatetime='2017-08-23 19:24:56';
20 rows in set (0.00 sec)

ERROR: 
No query specified
```

根据人为误操作为update，缩小范围

```shell
mysql> select pos,sqlinfo from binlogtosql where sqlinfo regexp '^update' ;
+------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| pos  | sqlinfo                                                                                                                                                                                                                                                                                                                                                           |
+------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 1033 | UPDATE `uplooking`.`t1`  SET  id=4, name='dad', a1=100, a2=0, a3=0  WHERE  id=4 and  name='dad' and  a1=0 and  a2=0 and  a3=0;                                                                                                                                                                                                                                    |
| 1172 | UPDATE `uplooking`.`gai`  SET  id=1, name='superman', age=99, updatetime='2017-08-23 19:24:56'  WHERE  id=1 and  name='superman' and  age=18 and  updatetime='2017-08-23 19:24:56';                                                                                                                                                                               |
| 1526 | UPDATE `uplooking`.`gai`  WHERE  id=1  name='superman'  age=99  updatetime='2017-08-23 19:24:56'  SET  id=1  name='superman'  age=100  updatetime='2017-08-23 19:24:56'  update  UPDATE `uplooking`.`gai`  SET  id=2, name='batman', age=100, updatetime='2017-08-23 19:24:56'  WHERE  id=2 and  name='batman' and  age=20 and  updatetime='2017-08-23 19:24:56'; |
+------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
3 rows in set (0.04 sec)

mysql> select * from binlogtosql where sqlinfo regexp '^update' \G;
*************************** 1. row ***************************
     id: 13
  edate: 2017-08-23
  etime: 19:25:58
    pos: 1033
  event: Update_rows: table id 269 flags: STMT_END_F
   type: update
sqlinfo: UPDATE `uplooking`.`t1`  SET  id=4, name='dad', a1=100, a2=0, a3=0  WHERE  id=4 and  name='dad' and  a1=0 and  a2=0 and  a3=0;
*************************** 2. row ***************************
     id: 15
  edate: 2017-08-23
  etime: 19:26:17
    pos: 1172
  event: Update_rows: table id 1345 flags: STMT_END_F
   type: update
sqlinfo: UPDATE `uplooking`.`gai`  SET  id=1, name='superman', age=99, updatetime='2017-08-23 19:24:56'  WHERE  id=1 and  name='superman' and  age=18 and  updatetime='2017-08-23 19:24:56';
*************************** 3. row ***************************
     id: 20
  edate: 2017-08-23
  etime: 19:26:55
    pos: 1526
  event: Update_rows: table id 1345 flags: STMT_END_F
   type: update
sqlinfo: UPDATE `uplooking`.`gai`  WHERE  id=1  name='superman'  age=99  updatetime='2017-08-23 19:24:56'  SET  id=1  name='superman'  age=100  updatetime='2017-08-23 19:24:56'  update  UPDATE `uplooking`.`gai`  SET  id=2, name='batman', age=100, updatetime='2017-08-23 19:24:56'  WHERE  id=2 and  name='batman' and  age=20 and  updatetime='2017-08-23 19:24:56';
3 rows in set (0.04 sec)

ERROR: 
No query specified

```

定位到误操作是1526，看上下文

```shell
mysql> select * from binlogtosql where pos > 1200  and pos< 1700 ;
+----+------------+----------+------+----------------------------------------------------+--------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| id | edate      | etime    | pos  | event                                              | type   | sqlinfo                                                                                                                                                                                                                                                                                                                                                           |
+----+------------+----------+------+----------------------------------------------------+--------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| 16 | 2017-08-23 | 19:26:19 | 1203 | Xid = 93988                                        | commit | commit;                                                                                                                                                                                                                                                                                                                                                           |
| 17 | 2017-08-23 | 19:26:55 | 1268 | Anonymous_GTID	last_committed=3	sequence_number=4  | others | others                                                                                                                                                                                                                                                                                                                                                            |
| 18 | 2017-08-23 | 19:26:55 | 1345 | Query	thread_id=15692	exec_time=0	error_code=0     | begin  | begin;                                                                                                                                                                                                                                                                                                                                                            |
| 19 | 2017-08-23 | 19:26:55 | 1402 | Table_map: `uplooking`.`gai` mapped to number 1345 | others | others                                                                                                                                                                                                                                                                                                                                                            |
| 20 | 2017-08-23 | 19:26:55 | 1526 | Update_rows: table id 1345 flags: STMT_END_F       | update | UPDATE `uplooking`.`gai`  WHERE  id=1  name='superman'  age=99  updatetime='2017-08-23 19:24:56'  SET  id=1  name='superman'  age=100  updatetime='2017-08-23 19:24:56'  update  UPDATE `uplooking`.`gai`  SET  id=2, name='batman', age=100, updatetime='2017-08-23 19:24:56'  WHERE  id=2 and  name='batman' and  age=20 and  updatetime='2017-08-23 19:24:56'; |
| 21 | 2017-08-23 | 19:26:55 | 1557 | Xid = 93992                                        | commit | commit;                                                                                                                                                                                                                                                                                                                                                           |
| 22 | 2017-08-23 | 19:32:01 | 1622 | Anonymous_GTID	last_committed=4	sequence_number=5  | others | others                                                                                                                                                                                                                                                                                                                                                            |
+----+------------+----------+------+----------------------------------------------------+--------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
7 rows in set (0.02 sec)


```

确认误操作事务的范围为1345，1622

接下来过滤文本并生成回滚sql脚本



UPDATE `uplooking`.`gai`  
WHERE  id=1  name='superman'  age=99  updatetime='2017-08-23 19:24:56'  
SET  id=1  name='superman'  age=100  updatetime='2017-08-23 19:24:56'  

update  

UPDATE `uplooking`.`gai`  
SET  id=2, name='batman', age=100, updatetim-08-23 19:24:56'  
WHERE  id=2 and  name='batman' and  age=20 and  updatetime='2017-08-23 19:24:56';

```shell
[root@ToBeRoot ~]# python binlog_rollbacktest.py mastera.000046 
plz input start_postion:1345
plz input end_postion:1622
============================================输出回滚语句===========================================================
begin;
UPDATE `uplooking`.`gai`  WHERE  id=1  name='superman'  age=99  updatetime='2017-08-23 19:24:56'  SET  id=1  name='superman'  age=100  updatetime='2017-08-23 19:24:56'  update  UPDATE `uplooking`.`gai`  set    id=2 
,   name='batman' 
,   age=20 
, updatetime='2017-08-23 19:24:56'  where  id=2 and  name='batman' and  age=100 and    updatetime='2017-08-23 19:24:56' 
;
==========================================END=========================================================================
```

bug出现了
```shell
[root@ToBeRoot ~]# python binlog_rollbacktest.py mastera.000046 
plz input start_postion:1
plz input end_postion:2000
mysqlbinlog: [Warning] option 'start-position': unsigned value 1 adjusted to 4
WARNING: The range of printed events ends with a row event or a table map event that does not have the STMT_END_F flag set. This might be because the last statement was not fully written to the log, or because you are using a --stop-position or --stop-datetime that refers to an event in the middle of a statement. The event(s) from the partial statement have not been written to output.
============================================输出回滚语句===========================================================
commit;
begin;
DELETE FROM `uplooking`.`gai`  WHERE  id=3 and  name='a1' and  age=1 and  updatetime='2017-08-23 19:32:01';
commit;
begin;
UPDATE `uplooking`.`gai`  WHERE  id=1  name='superman'  age=99  updatetime='2017-08-23 19:24:56'  SET  id=1  name='superman'  age=100  updatetime='2017-08-23 19:24:56'  update  UPDATE `uplooking`.`gai`  set    id=2 
,   name='batman' 
,   age=20 
, updatetime='2017-08-23 19:24:56'  where  id=2 and  name='batman' and  age=100 and    updatetime='2017-08-23 19:24:56' 
;
commit;
begin;
UPDATE `uplooking`.`gai`  set    id=1 
,   name='superman' 
,   age=18 
, updatetime='2017-08-23 19:24:56'  where  id=1 and  name='superman' and  age=99 and    updatetime='2017-08-23 19:24:56' 
;
UPDATE `uplooking`.`t1`  set    id=4 
,   name='dad' 
,   a1=0 
,   a2=0 
, a3=0  where  id=4 and  name='dad' and  a1=100 and  a2=0 and    a3=0 
;
commit;
begin;
DELETE FROM `uplooking`.`gai`  WHERE  id=1 and  name='superman' and  age=18 and  updatetime='2017-08-23 19:24:56' and  insert and  INSERT INTO `uplooking`.`gai` and  SET and  id=2 and  name='batman' and  age=20 and  updatetime='2017-08-23 19:24:56';
commit;
==========================================END=========================================================================

```

## bug具体情况

1. 无法解决事务内部同时出现多条sql的情况
2. 无法解决多是更新多行
3. 无法解决同时删除多行


### 源sql VS binlog

```shell
mysqlbinlog -vv --base64-output=DECODE-ROWS $1 | awk  '$0~/^###/ || $0~/end_log_pos/ || $0~/BEGIN/ || $0~/COMMIT/ {print $0}' |sed 's/^### //;s@\/\*.*\*\/@@' > ${1}.new
```

#### 事务内部一条sql同时插入多行

```shell 
#源sql
insert into gai values (null,'superman',18,sysdate()),(null,'batman',20,sysdate());

# binlog

#170823 19:24:56 server id 1  end_log_pos 590 CRC32 0xc712d082 	Query	thread_id=15692	exec_time=0	error_code=0
BEGIN
#170823 19:24:56 server id 1  end_log_pos 647 CRC32 0xb0b28655 	Table_map: `uplooking`.`gai` mapped to number 1345
#170823 19:24:56 server id 1  end_log_pos 726 CRC32 0xeb864b6c 	Write_rows: table id 1345 flags: STMT_END_F
INSERT INTO `uplooking`.`gai`
SET
  @1=1 
  @2='superman' 
  @3=18 
  @4='2017-08-23 19:24:56' 
INSERT INTO `uplooking`.`gai`
SET
  @1=2 
  @2='batman' 
  @3=20 
  @4='2017-08-23 19:24:56' 
#170823 19:25:01 server id 1  end_log_pos 757 CRC32 0x7e272cc3 	Xid = 93983
COMMIT;
```

#### 事务内部多条sql

```shell
#源sql
begin;
update t1 set a1=100 where id=4;
update gai set age=99 where name='superman';
commit;


#binlog

#170823 19:25:58 server id 1  end_log_pos 899 CRC32 0xe26549aa 	Query	thread_id=15692	exec_time=0	error_code=0
BEGIN
#170823 19:25:58 server id 1  end_log_pos 955 CRC32 0x1b37107c 	Table_map: `uplooking`.`t1` mapped to number 269
#170823 19:25:58 server id 1  end_log_pos 1033 CRC32 0xe07707f7 	Update_rows: table id 269 flags: STMT_END_F
UPDATE `uplooking`.`t1`
WHERE
  @1=4 
  @2='dad' 
  @3=0 
  @4=0 
  @5=0 
SET
  @1=4 
  @2='dad' 
  @3=100 
  @4=0 
  @5=0 
#170823 19:26:17 server id 1  end_log_pos 1090 CRC32 0x8e8abe32 	Table_map: `uplooking`.`gai` mapped to number 1345
#170823 19:26:17 server id 1  end_log_pos 1172 CRC32 0x373bfacd 	Update_rows: table id 1345 flags: STMT_END_F
UPDATE `uplooking`.`gai`
WHERE
  @1=1 
  @2='superman' 
  @3=18 
  @4='2017-08-23 19:24:56' 
SET
  @1=1 
  @2='superman' 
  @3=99 
  @4='2017-08-23 19:24:56' 
#170823 19:26:19 server id 1  end_log_pos 1203 CRC32 0xff905df5 	Xid = 93988
COMMIT;
#170823 19:26:55 server id 1  end_log_pos 1268 CRC32 0x1b5c177d 	Anonymous_GTID	last_committed=3	sequence_number=4
```

#### 事务内部一条update未过滤

```shell
# 源sql
update gai set age = 100;


# binlog
#170823 19:26:55 server id 1  end_log_pos 1345 CRC32 0x15d43127 	Query	thread_id=15692	exec_time=0	error_code=0
BEGIN
#170823 19:26:55 server id 1  end_log_pos 1402 CRC32 0x7a65ad89 	Table_map: `uplooking`.`gai` mapped to number 1345
#170823 19:26:55 server id 1  end_log_pos 1526 CRC32 0x07756f9c 	Update_rows: table id 1345 flags: STMT_END_F
UPDATE `uplooking`.`gai`
WHERE
  @1=1 
  @2='superman' 
  @3=99 
  @4='2017-08-23 19:24:56' 
SET
  @1=1 
  @2='superman' 
  @3=100 
  @4='2017-08-23 19:24:56' 
UPDATE `uplooking`.`gai`
WHERE
  @1=2 
  @2='batman' 
  @3=20 
  @4='2017-08-23 19:24:56' 
SET
  @1=2 
  @2='batman' 
  @3=100 
  @4='2017-08-23 19:24:56' 
#170823 19:26:55 server id 1  end_log_pos 1557 CRC32 0xa31e1c92 	Xid = 93992
COMMIT;
#170823 19:32:01 server id 1  end_log_pos 1622 CRC32 0xe5e782b0 	Anonymous_GTID	last_committed=4	sequence_number=5
```

## 修改代码

```shell
num=0
names=locals()
for a_str in a_list:
        if n.match(a_str):
                num=num+1
                sql_num=0
                names['b_list%d'%num]=[]
                time_str=a_str[1:16]
                s_num=a_str.index('end_log_pos')+11
                e_num=a_str.index('CRC')
                pos_str=a_str[s_num:e_num]
                # new event
                event_num=e_num+18
                # new event
                event_str=a_str[event_num:]
                names['b_list%d'%num].append(time_str)
                names['b_list%d'%num].append(pos_str)
                names['b_list%d'%num].append(event_str.strip())
                
                 if not flag.match(a_str) and not thread.match(a_str) and not xid.match(a_str):
                        sql_type_str='others'
                        names['b_list%d'%num].append(sql_type_str)

        if r.match(a_str):
                sql_num=sql_num+1
                if sql_num != 1:
                        num=num+1
                        names['b_list%d'%num]= names['b_list%d'%(num-1)][:3]
                if begin.match(a_str):
                        sql_type_str='begin'
                elif commit.match(a_str):
                        sql_type_str='commit'
                elif insert.match(a_str):
                        sql_type_str='insert'
                elif delete.match(a_str):
                        sql_type_str='delete'
                elif update.match(a_str):
                        sql_type_str='update'

                names['b_list%d'%num].append(sql_type_str)
                names['b_list%d'%num].append(a_str)
```

## 测试成功

```shell
[root@ToBeRoot ~]# python binlog_rollbacktest.py mastera.000046
plz input start_postion:505
plz input end_postion:1622
============================================输出回滚语句===========================================================
begin;
UPDATE `uplooking`.`gai`  set    id=2 
,   name='batman' 
,   age=20 
, updatetime='2017-08-23 19:24:56'  where  id=2 and  name='batman' and  age=100 and    updatetime='2017-08-23 19:24:56' 
;
UPDATE `uplooking`.`gai`  set    id=1 
,   name='superman' 
,   age=99 
, updatetime='2017-08-23 19:24:56'  where  id=1 and  name='superman' and  age=100 and    updatetime='2017-08-23 19:24:56' 
;
commit;
begin;
UPDATE `uplooking`.`gai`  set    id=1 
,   name='superman' 
,   age=18 
, updatetime='2017-08-23 19:24:56'  where  id=1 and  name='superman' and  age=99 and    updatetime='2017-08-23 19:24:56' 
;
UPDATE `uplooking`.`t1`  set    id=4 
,   name='dad' 
,   a1=0 
,   a2=0 
, a3=0  where  id=4 and  name='dad' and  a1=100 and  a2=0 and    a3=0 
;
commit;
begin;
DELETE FROM `uplooking`.`gai`  WHERE  id=2 and  name='batman' and  age=20 and  updatetime='2017-08-23 19:24:56';
DELETE FROM `uplooking`.`gai`  WHERE  id=1 and  name='superman' and  age=18 and  updatetime='2017-08-23 19:24:56';
commit;
```