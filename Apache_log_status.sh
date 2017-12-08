#!/bin/bash
mkdir /var/log/apache_log >& /dev/null
LOG=/var/log/apache_log/apache.log
DIR=/var/log/apache_log
download(){
	rm -rf $DIR/*
	read -p "选择Apache日志所在服务器(pcw|cad): " Server
	read -p "填写日期(yyyy_mm_dd): " Date
	if [ $Server = pcw ];then
		scp root@139.196.237.112:/home/server/apache2/logs/${Date}_www.pcw365.com_access_log $LOG
	elif [ $Server = cad ];then
		scp root@139.224.26.199:/home/server/apache2/logs/${Date}_www.aec188.com_access_log $LOG
	else
		exit
	fi
	echo 下载为本地: $LOG
}

select_log(){
	read -p "请输入需要截取的日志文件(绝对路径)：" LOG
	read -p "请输入选取日志的开始时间(yyyy:hh:mm): " StartDate
	Start=`cat $LOG |grep ${StartDate}|head -n 1|awk '{print $4$5}'|tr -cd "[0-9]"`
	read -p "请输入选取日志的结束时间(yyyy:hh:mm): " EndDate
	End=`cat $LOG |grep ${EndDate}|tail -n 1|awk '{print $4$5}'|tr -cd "[0-9]"`
	sed -n "/$StartDate:${Start:11:2}/,/$EndDate:${End:11:2}/p" $LOG &> $DIR/${Server}_apache_${StartDate:5:5}-${EndDate:5:5}.log
	echo 截取日志另存为: $DIR/apache_${StartDate:5:5}-${EndDate:5:5}.log
	echo $DIR/apache_${StartDate:5:5}-${EndDate:5:5}.log > $DIR/.log
}


ip_sort(){
	read -p "请输入需要整理ip的日志文件(绝对路径): " SELECT_LOG	
	Request=`cat $SELECT_LOG|wc -l`
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
	echo 
	echo "访问次数统计"
	echo "该时间段共有:$Request次请求"
	echo "访问次数个位数:$only_1个"
	echo "访问次数十位数:$only_10个"
	echo "访问次数百位数:$only_100个"
	echo "访问次数千位数:$only_1000个"
	echo "访问次数万位数:$only_10000个"
	echo IP排序整理文件为：$DIR/"(1.txt|10.txt|100.txt|1000.txt|10000.txt)"
	echo
}	

ever_hours()
{
	echo "该日志中每个小时访问量对比"
	for i in {00..23}
	do 
		echo -e "$i点: \c";
		cat $LOG|grep "2017:${i}"|wc -l;
	done
}

ip_status()
{
	echo "仅显示访问次数百次以上的IP，其他的自行查看"$DIR/"(1.txt|10.txt|100.txt|1000.txt|10000.txt)"
	cat $DIR/100.txt;sleep 1;
	cat $DIR/1000.txt;sleep 1;
	cat $DIR/10000.txt;sleep 1;
}

ip_page()
{	
	read -p "请输入需要整理ip的服务器(pcw|cad): " Server	
	read -p "输入要查询的IP：" IP
	read -p "全日志查找(all) | 截取日志查找(por) | 自行输入日志文件(path)：" L
	if [ $L = "all"  ];then
		cat $LOG|grep $IP|tee $DIR/${IP}_ip_page.log
		echo 另存为$DIR/${IP}_ip_page.log
	elif [ $L = "por" ];then
		cat `cat $DIR/.log`|grep $IP|tee $DIR/${IP}_ip_page.log
		echo 另存为$DIR/${IP}_ip_page.log
	elif [ $L = "path" ];then
		read -p "Enter Log Path: " Log
		cat $Log|grep $IP|tee $DIR/${IP}_ip_page.log
		echo 另存为$DIR/${IP}_ip_page.log
	else
		exit
	fi
}

echo "可选参数key值对照表"
echo "+-------------------------------------------------------+"
echo "|1         |2       |3     |4         |5     |6         |"
echo "+-------------------------------------------------------+"
echo "|下载到本地|截取日志|IP分析|每小时对比|IP统计|IP访问位置|"
echo "+-------------------------------------------------------+"
echo 
read -p "输入key值：" A
if [ $A = "1" ];then
	download
elif [ $A = "2" ];then
	select_log
elif [ $A = "3" ];then
	ip_sort
elif [ $A = "4" ];then
	ever_hours
elif [ $A = "5" ];then
	ip_status	
elif [ $A = "6" ];then
	ip_page
fi
