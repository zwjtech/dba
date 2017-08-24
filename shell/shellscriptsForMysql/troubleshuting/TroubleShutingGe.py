#/usr/local/env python
#coding:utf8
import sys
import os
import mysqlbala
import psutil
import datetime
import time


def info_hardware():
	'''
	硬件规格信息:cpu mem disk
	系统发行版本和内核信息:release kernel
	'''
	hw_info_dict = {}
	cpu = psutil.cpu_count(logical=True)
	mem = psutil.virtual_memory()
	disk = psutil.disk_usage('/')
	release=os.popen('cat /etc/redhat-release').read().strip()
	kernel=os.popen('uname -r').read().strip()

	hw_info_dict['cpu']=cpu
	hw_info_dict['mem']='%.2f'%(mem.total/1024/1024/1024.0)+'G'
	hw_info_dict['disk']='%.2f'%(disk[0]/1024/1024/1024.0)+'G'
	hw_info_dict['rele']=release
	hw_info_dict['kernel']=kernel
	print '\033[1;34;47m'
	print "\n=============硬件规格信息:cpu mem disk====================="	
	print '\033[0m'
	for i in hw_info_dict:
		print '%-30s%-30s'%(i+':',hw_info_dict[i])
	
	with open('hardware.info','w') as f:
		for i in hw_info_dict:
			line_str = '%-30s%-30s'%(i+':',hw_info_dict[i])+'\n'
			f.write(line_str)
	


def info_sysres():
	'''
	系统资源使用信息：cpu mem disk io net process
	'''
	sr_info_dict = {}
	cpu = os.popen('uptime').read().strip()
	mem = psutil.virtual_memory().percent
	disk = psutil.disk_usage('/').percent
	io = os.popen('iostat -kx 1 -c 3').read()
	net = psutil.net_io_counters()
	cputop5 = os.popen('ps aux | sort -k3rn | head -5').read()
	memtop5 = os.popen('ps aux | sort -k4rn | head -5').read()
	

	sr_info_dict[cpu] = '\033[1;34;47mcpu使用情况:\033[0m\n' + cpu
	sr_info_dict[mem] = '\033[1;34;47mmem使用情况:\033[0m\t\t\t\t' + str(mem) + '%'
	sr_info_dict[disk] = '\033[1;34;47mdisk使用情况:\033[0m\t\t\t\t' + str(disk) + '%'
	sr_info_dict[io] = '\033[1;34;47mio使用情况:\033[0m\n' + io
	sr_info_dict[net] = '\033[1;34;47mnet使用情况:\033[0m\n' + str(net) 
	sr_info_dict[cputop5] = '\033[1;34;47m占用CPU最高的5个进程:\033[0m\n' + cputop5
	sr_info_dict[memtop5] = '\033[1;34;47m占用mem最高的5个进程:\033[0m\n' + memtop5

	psinfo={}
	for i in psutil.pids():
    		p=psutil.Process(i)
    		if p.name() == 'mysqld':
        		psinfo['MySQL进程名'] = p.name()
        		psinfo['进程bin路径'] = p.exe()
        		psinfo['进程状态'] = p.status()
        		psinfo['进程创建时间'] = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(p.create_time()))
        		psinfo['进程uid信息'] = p.uids()
        		psinfo['进程gid信息'] = p.gids()
        		psinfo['进程CPU时间信息'] = p.cpu_affinity()
        		psinfo['进程内存利用率'] = p.memory_percent()
        		psinfo['进程内存信息'] = p.memory_info()
        		psinfo['进程IO信息'] = p.io_counters()
        		psinfo['进程socket列表'] = p.connections()
        		psinfo['进程开启线程数'] = p.num_threads()	
	
	print '\033[1;34;47m'
	print "\n=============系统资源使用信息:cpu mem disk io net process====================="
	print '\033[0m'
        for i in sr_info_dict:
                print '{0}'.format(sr_info_dict[i])

        with open('sysres.info','w') as f:
                for i in sr_info_dict:
                        line_str = '{0}\n'.format(sr_info_dict[i])
                        f.write(line_str)

	print '\033[1;34;47m'
	print "\n=============Mysqld进程的详细信息====================="
	print '\033[0m'
	for i in psinfo:
		print '{0}\t\t\t\t{1}'.format(i,psinfo[i])

	with open('mysqlps.info','w') as f:
                for i in psinfo:
                        line_str = '{0}\n'.format(psinfo[i])
                        f.write(line_str)

def info_mysql_variables(host,user,password,dbname):
	p = mysqlbala.mysqlhelper(host,user,password,dbname)
	my = p.queryAll('show variables')	
	print '\033[1;34;47m'
	print "\n=============Mysqld变量的详细信息====================="
	print '\033[0m'
	print "变量信息保存至mysqlvariables.info文件中"
        with open('mysqlvariables.info','w') as f:
                for i in my:
                        line_str = '{0}={1}\n'.format(i[0],i[1])
                        f.write(line_str)
		

def info_logs(host,user,password,dbname):
	'''
	系统和服务的日志信息{
		/*复制一份至/tmp/mysqlTroubleShooting/info_dir/*/
		/var/log/messages
		error-log
		bin-log
		slow-log
	'''
	p = mysqlbala.mysqlhelper(host,user,password,dbname)
        my = p.queryAll('show variables')
	for i in my:
		if i[0] == "datadir":
			datadir=i[1]
		elif i[0] == "log_bin_basename":
			binlogdir=i[1]
		elif i[0] == "log_error":
			errorlogdir=i[1]
		elif i[0] == "slow_query_log_file":
			slowlogdir=i[1]

	os.popen('rm -rf info_dir;mkdir info_dir')
	os.popen('cp /var/log/messages info_dir')
	os.popen('cp /etc/my.cnf info_dir')
	
	print '\033[1;34;47m'
	print "\n=============Mysqld重要路径信息====================="
	print '\033[0m'
	print '%-30s%-30s'%('datadir:',datadir)
	print '%-30s%-30s'%('binlog:',binlogdir)
	print '%-30s%-30s'%('errorlog:',errorlogdir)
	print '%-30s%-30s'%('slowlog:',slowlogdir)
	








host='localhost'
user='root'
password='(Uploo00king)'
dbname='uplooking'

if __name__ == "__main__": 
	info_hardware()
	info_mysql_variables(host,user,password,dbname)
	info_logs(host,user,password,dbname)
	info_sysres()

