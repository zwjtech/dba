```shell
# 查看当前的线程情况
show processlist;

# 查看当前线程中非系统用户且查询命令为select的线程id和执行时间
select id,time from information_schema.processlist where USER !='system user' and COMMAND='query';

# 查看当前线程中是innodb事务的线程情况
select * from information_schema.processlist where id in (select trx_mysql_thread_id from information_schema.innodb_trx)\G;

# 查看当前线程中存在metadata锁的线程id和执行时间
select id,time from information_schema.processlist where state='Waiting for table metadata lock';

# 查看有metalock锁的线程
# 查看未提交的事务运行时间，线程id，用户等信息
# 查看未提交的事务运行时间，线程id，用户，sql语句等信息
# 查看错误语句
# 根据错误语句的THREAD_ID，查看PROCESSLIST_ID

select id,State,command from information_schema.processlist where State="Waiting for table metadata lock";
select  timediff(sysdate(),trx_started) timediff,sysdate(),trx_started,id,USER,DB,COMMAND,STATE,trx_state,trx_query from information_schema.processlist,information_schema.innodb_trx  where trx_mysql_thread_id=id;
select  timediff(sysdate(),trx_started) timediff,sysdate(),trx_started,id,USER,DB,COMMAND,STATE,trx_state from information_schema.processlist,information_schema.innodb_trx where trx_mysql_thread_id=id\G;
select * from performance_schema.events_statements_current where SQL_TEXT like '%booboo%'\G;
select * from performance_schema.threads where thread_id=46052\G;
select * from information_schema.processlist where id=xxx\G;

select processlist_id from performance_schema.threads where thread_id==(select thread_id from performance_schema.events_statements_current where SQL_TEXT like '%booboo%');
```



