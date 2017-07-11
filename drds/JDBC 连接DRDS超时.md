# JDBC 连接DRDS超时

## 故障描述

DRDS经常通过JDBC会连接超时，但是当时DRDS负载及连接数都不高。

2017年7月8日下午2点到4点之间又出现连接超时现象。

* 联系人：曾宇睿
* 联系方式：13816812693

![JDBC报错1](https://files.cloudcare.cn/crm/B4aiJQcAekPKUN2W8uQvPP/fe7a7d0f-fb8e-491b-9488-bbb60237e358.png)

![JDBC报错2](https://files.cloudcare.cn/crm/B4aiJQcAekPKUN2W8uQvPP/a1bdd3f6-581e-48df-b813-eabecad174d3.png)

![JDBC报错3](https://files.cloudcare.cn/crm/B4aiJQcAekPKUN2W8uQvPP/b242e4d3-f11e-494a-8270-2e09b749bbf2.png)

![DRDSCPU状态](https://files.cloudcare.cn/crm/B4aiJQcAekPKUN2W8uQvPP/b2106024-1dec-461f-83e8-6b60f3f2bff5.jpg)

![DRDS连接数14点20到14点50间](https://files.cloudcare.cn/crm/B4aiJQcAekPKUN2W8uQvPP/1e2ea52a-5de6-47da-bf09-bb06c3e216fd.jpg)



## 故障分析

1. 客户截图中的两个报错信息

| id   | 时间                  | 报错信息                                     | 详细内容                         | drds cpu | drds 连接数 |
| ---- | ------------------- | ---------------------------------------- | ---------------------------- | -------- | -------- |
| 1    | 2017-07-08 14:44:52 | mysql.jdbc.exceptions.jdbc4.ConnectionException | conmunication link fail      | 大约50%    | 大约50     |
| 2    | 2017-07-08 15:51:08 | mysql.jdbc.exceptions.jdbc4.MysqlNonTransientConnectionException | the server has been shutdown |          |          |



故障可能原因

1. mysql设置的连接超时时间偏短

   阿里云官方文档https://help.aliyun.com/knowledge_detail/41728.html?spm=5176.7841698.2.15.pe6TIV

   ​

| 参数                  | 说明                                       |
| ------------------- | ---------------------------------------- |
| wait_timeout        | mysql在关闭一个交互式/非交互式的连接之前所要等待的时间。建议不需要设置太长的时候，否则会占用实例的连接数资源。 |
| interactive_timeout |                                          |

mysq将其连接的等待时间(wait_timeout)缺省为8小时，可以调高。

客户反馈信息为：

1. 后端mysql数据库中确实有部分连接是sleep状态，但是不多。
2. 当连接不上数据库中间件DRDS时，用户尝试直接连接后端mysql数据库，也会出现连接不上的问题，客户后端数据库是本地和阿里云rds用光纤连接。

**【希望驻云做什么】** 希望驻云排查一下光纤网络是否有问题。



20170710

【客户情况】

1. 权限http://signin.aliyun.com/1265697342951663/login.htm
   子账号的账号密码：drds / drds6666
2. 架构



