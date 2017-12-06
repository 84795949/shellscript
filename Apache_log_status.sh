#!/bin/bash
mkdir /var/log/apache_log >& /dev/null
LOG=/var/log/apache_log/apache.log
DIR=/var/log/apache_log
download(){
	rm -rf $DIR/*
	read -p "Please Enter The Server To View(pcw|cad): " Server
	read -p "Please Enter The Date(yyyy_mm_dd): " Date
	if [ $Server = pcw ];then
		scp root@139.196.237.112:/home/server/apache2/logs/${Date}_www.pcw365.com_access_log $LOG
	elif [ $Server = cad ];then
		scp root@139.224.26.199:/home/server/apache2/logs/${Date}_www.aec188.com_access_log $LOG
	else
		exit
	fi
	echo $Server > $DIR/Server.txt
	echo $Date > $DIR/Date.txt
}

select_log(){
	read -p "请输入选取日志的开始时间(yyyy:hh:min): " StartDate
	Start=`cat $LOG |grep ${StartDate}|head -n 1|awk '{print $4$5}'|tr -cd "[0-9]"`
	read -p "请输入选取日志的结束时间(yyyy:hh:min): " EndDate
	End=`cat $LOG |grep ${EndDate}|tail -n 1|awk '{print $4$5}'|tr -cd "[0-9]"`
	sed -n "/$StartDate:${Start:11:2}/,/$EndDate:${End:11:2}/p" $LOG &> $DIR/${Server}_apache_$Date.log
}


ip_sort(){
	Date=`cat $DIR/Date.txt`
	read -p "请输入需要整理ip的服务器(pcw|cad): " Server	
	SELECT_LOG=$DIR/${Server}_apache_$Date.log;
	Request=`cat $SELECT_LOG|wc -l`
	line=`wc -l $SELECT_LOG`
	cat $SELECT_LOG | awk '{a[$1]+=1;} END {for(i in a){print a[i]" "i;}}' | sort -n | grep -P '^\d \d' > $DIR/1.txt
	cat $SELECT_LOG | awk '{a[$1]+=1;} END {for(i in a){print a[i]" "i;}}' | sort -n | grep -P '^\d\d \d' > $DIR/10.txt
	cat $SELECT_LOG | awk '{a[$1]+=1;} END {for(i in a){print a[i]" "i;}}' | sort -n | grep -P '^\d\d\d \d' > $DIR/100.txt
	cat $SELECT_LOG | awk '{a[$1]+=1;} END {for(i in a){print a[i]" "i;}}' | sort -n | grep -P '^\d\d\d\d \d' > $DIR/1000.txt
	cat $SELECT_LOG | awk '{a[$1]+=1;} END {for(i in a){print a[i]" "i;}}' | sort -n | grep -P '^\d\d\d\d\d \d' > $DIR/10000.txt
	only_1=`cat $DIR/1.txt | wc -l`
	only_10=`cat $DIR/10.txt | wc -l`
	only_100=`cat $DIR/100.txt | wc -l`
	only_1000=`cat $DIR/1000.txt | wc -l`
	only_10000=`cat $DIR/10000.txt | wc -l`
	echo "+-------------------------------+"
	echo "| 访问次数统计			|"
	echo "| 该时间段共有:$Request次请求	|"
	echo "| 访问次数个位数:$only_1个		|"
	echo "| 访问次数十位数:$only_10个		|"
	echo "| 访问次数百位数:$only_100个		|"
	echo "| 访问次数千位数:$only_1000个		|"
	echo "| 访问次数万位数:$only_10000个		|"
	echo "+-------------------------------+"
}	

ever_hours()
{
	echo "该日志中每个小时访问量对比"
	for i in {00..23}
	do 
		echo -e "$i点: \c";
		cat $LOG|grep "04/Dec/2017:${i}"|wc -l;
	done
}
