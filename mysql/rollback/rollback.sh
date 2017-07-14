#!/bin/bash
#--help	#帮助
#-f	#日志文件名
#-o	#输出文件名
#将row格式的日志sql语句进行反向输出




#函数部分

help () {
if [ $1 = --help ] 
then 
	echo -e "###############################################
rollback将row格式的日志sql语句进行反向输出	
	--help #查看帮助
	-f     #日志文件名
	-o     #输出文件名
	eg.	rollback --help
	eg.	rollback -f /var/lib/mysql/mastera.000001 -o /tmp/recovery.sql
###############################################"
fi
}

#get获取row日志有用信息
get () {
mysqlbinlog -v -v --base64-output=DECODE-ROWS $1 > /tmp/get.sql
sed -n '/^###/p' /tmp/get.sql > /tmp/sed.sql
sed -i '1,$s/###//g' /tmp/sed.sql
}

#change转换成回滚语句
change () {
#先做一个库一个表的情况，且只有update语句（以后再更新）
#将列名更换@1 @2
cp /tmp/sed.sql /tmp/sed.sql.back
sed -i 's#/\*.*\*/# #g' /tmp/sed.sql.back
sed -r ':1;N;s#(.*)\n(.*)#\1 \2#;/@2/!b1' /tmp/sed.sql.back|sed -r ':1;N;s#(.*)\n(.*)#\1 \2#;/@2/!b1' >/tmp/kk1
awk '{$4=$4",";$7=$7" and ";$NF=$NF";";print}' /tmp/kk1 > /tmp/kk2
sed -i "s/SET/where/g" /tmp/kk2
sed -i "s/WHERE/set/g" /tmp/kk2

k=1
while read col
do
        sed -i "s/@${k}/${col}/g" /tmp/kk2
        k=$((${k}+1))
done < /tmp/${DESC}.${MM}.col


}

#desc获取表的列名信息

desc () {
grep UPDATE /tmp/sed.sql|cut -d" " -f3|sort -u > /tmp/update
grep "INSERT INTO" /tmp/sed.sql|cut -d" " -f4|sort -u > /tmp/insert-into
grep "DELETE FROM" /tmp/sed.sql|cut -d" " -f4|sort -u > /tmp/delete-from

for i in `seq 1 3`
do 
        if [ $i -eq 1 ];then DESC="update";fi
        if [ $i -eq 2 ];then DESC="insert-into";fi
        if [ $i -eq 3 ];then DESC="delete-from";fi

	if [ -z `cat /tmp/${DESC}` ]
	then
        	echo "no ${DESC}"
	else
		while read MM
		do
			echo "desc ${MM};"|mysql -uroot -p'(Uploo00king)' > /tmp/${DESC}.${MM}.desc
			sed -n '2,$p' /tmp/${DESC}.${MM}.desc |awk '{print $1}' > /tmp/${DESC}.${MM}.col
			change 
		done < /tmp/${DESC}
	fi
done
}




#正文部分

if [ $1 = -f ] && [ -f $2 ] && [ $3 = -o ] && [ -n $4 ]
then
	get $2
	desc
	echo "回滚语句已经输出至$4中"
	cp /tmp/kk2 $4
	cat $4
else 
	help $1
fi
	
