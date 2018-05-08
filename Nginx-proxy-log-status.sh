#!/bin/bash

Select_log=/tmp/nginx-select.log
IP=/tmp/ip.list
STATUS=/tmp/status-ip.txt

select_log(){
    read -p "请输入需要截取的日志文件(绝对路径)：" LOG
    read -p "请输入选取日志的开始时间(eg: yyyy:HH:mm): " StartDate
    read -p "请输入选取日志的结束时间(eg: yyyy:HH:mm): " EndDate
    sed -n "/$StartDate/,/$EndDate/p" $LOG|head -n 1
    sed -n "/$StartDate/,/$EndDate/p" $LOG|tail -n 1
    read -p  "上面是截取日志首行与尾行,验证无误后输入yes:" CHECK
    if [ $CHECK == "yes" ];then
	sed -n "/$StartDate/,/$EndDate/p" $LOG > $Select_log
      	echo "截取日志保存为/tmp/nginx-select.log"
    fi
}

status_ip(){
    echo -e "\n下面对截取日志进行IP统计\n"
    grep -Eo ^'[0-9]{1,3}(\.[0-9]{1,3}){3}'.*\"'[0-9]{1,3}(\.[0-9]{1,3}){3}'\"$ ${Select_log}|awk '{print $NF}' > $IP
    sed -i 's/"//g' $IP
    awk '{a[$1]+=1;} END {for(i in a){print a[i]" "i;}}' $IP |sort -n > $STATUS
    echo "IP统计排序结果保存为/tmp/status-ip.txt"
}

select_log;
status_ip
