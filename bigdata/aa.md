# 安装kettle|pentaho7.1

## 官网

http://www.pentaho.com/download

## 安装步骤

1. 安装图形化界面
2. 安装依赖包jdk 1.8
3. 安装pentaho 7.1


```shell
# 查看系统操作系统发行版和内核版本
[root@ToBeRoot opt]# cat /etc/redhat-release 
CentOS release 6.8 (Final)
[root@ToBeRoot opt]# uname -r
2.6.32-642.13.1.el6.i686

# 安装图形化界面
[root@ToBeRoot opt]# yum -y groupinstall "X Window System"

# 安装lib库
[root@ToBeRoot opt]# yum install -y gtk2* PackageKit-gtk* libcanberra-gtk2

# 安装jdk，宣告java家目录

# 安装pentaho7.1

下载解压即可，已经编译过了





```
