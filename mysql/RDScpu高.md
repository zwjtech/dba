```shell
# 查看当前的线程情况
show processlist;

# 查看当前线程中非系统用户且查询命令为select的线程id和执行时间
select id,time from information_schema.processlist where USER !='system user' and COMMAND='query';

# 查看当前线程中是innodb事务的线程情况
select * from information_schema.processlist where id in (select trx_mysql_thread_id from information_schema.innodb_trx)\G;

# 查看当前线程中存在metadata锁的线程id和执行时间
select id,time from information_schema.processlist where state='Waiting for table metadata lock';

```



