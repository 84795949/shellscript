#!/bin/bash
for d in $(ls /data/); do
	if [ -f /data/$d/logs/catalina.out ]; then
		ls -lh /data/$d/logs/catalina.out
		cat /dev/null >/data/$d/logs/catalina.out
	fi
done
