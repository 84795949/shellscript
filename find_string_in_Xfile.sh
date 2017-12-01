#!/bin/bash
DIR=`ls /app/ansible-jobs/scripts/AliyunCad/`
for i in $DIR;do
    cat /app/ansible-jobs/scripts/AliyunCad/$i|grep "# copy to nfsmount"
    if [ $? = 0 ];then
       echo $i
    fi
