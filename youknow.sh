#!/bin/bash

url=${1}
mkdir -p ${url}
cd ${url}

for i in $(seq 1 10); do
	curl https://www.btrabbit.biz/search/${url}/size-${i}.html >${i}.log
	cat ${i}.log | grep thunder | awk -F "\"" '{print $6}' >>get.log
	rm -rf ${i}.log
done

touch done.log
exec <get.log
while read line; do
	line1=$(tail -1 done.log | awk '{print $1}')
	line2=$(echo ${line} | awk '{print $1}')
	if [ "${line1}" != "${line2}" ]; then
		echo ${line} >>done.log
	fi
done

rm -rf get.log
cat done.log
