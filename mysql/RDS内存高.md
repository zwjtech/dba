## 背景
漳州教育是一家做教育直播的客户

RDS数据库内存使用率一直处于90%以上，原来是8G内存的配置，增加8G之后，刚开始几天是正常的，后面内存使用率还是逐步上升到90%,一直居高不下，查看日志也没有明显的异常错误，也没有很大的连结数。 希望我们给到故障排查

## 故障排查

如何查看内存使用分配情况，详情见：https://help.aliyun.com/knowledge_detail/41729.html

```
共享内存

mysql>show variables where variable_name in (
'innodb_buffer_pool_size','innodb_log_buffer_size','innodb_additional_mem_pool_size','key_buffer_size','query_cache_size'
);

+---------------------------------+-----------------+
| Variable_name                   | Value           |
+---------------------------------+-----------------+
| innodb_additional_mem_pool_size | 2097152         |
| innodb_buffer_pool_size         | 12884901888     |
| innodb_log_buffer_size          | 8388608         |
| key_buffer_size                 | 16777216        |
| query_cache_size                | 3145728         |
+---------------------------------+-----------------+

session私有内存
mysql>show variables where variable_name in (
'read_buffer_size','read_rnd_buffer_size','sort_buffer_size','join_buffer_size','binlog_cache_size','tmp_table_size'
);

+-------------------------+-----------------+
| Variable_name           | Value           |
+-------------------------+-----------------+
| binlog_cache_size       | 2097152         |
| join_buffer_size        | 442368          |
| read_buffer_size        | 868352          |
| read_rnd_buffer_size    | 442368          |
| sort_buffer_size        | 868352          |
| tmp_table_size          | 2097152         |
+-------------------------+-----------------+
共返回 6 行记录,花费 2 ms.
```

使用RDS需要注意的地方：备份策略 设置好 / 监控阈值，监控提醒设置好。/ 注意查看 慢日志和诊断报告/ 做操作前查看帮助文档是否有注意的地方