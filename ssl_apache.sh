#!/bin/bash
plan_a(){
cp httpd.conf httpd.conf_bak_20171222
sed -i '/httpd-ssl/s/^#//' httpd.conf
cat httpd.conf|grep httpd-ssl
systemctl restart apache.service
netstat -ntlp
}
plan_a_back(){
cp httpd.conf httpd.conf_err_a
mv httpd.conf_bak_20171222 httpd.conf
cat httpd.conf|grep httpd-ssl
systemctl restart apache.service
netstat -ntlp
}

plan_b(){
cp httpd.conf httpd.conf_bak_20171222
sed -i '/httpd-ssl/s/^#//' httpd.conf
cat httpd.conf|grep httpd-ssl
cp extra/httpd-ssl.conf extra/httpd-ssl.conf_err_a
mv extra/httpd-ssl.conf_ok extra/httpd-ssl.conf
mv extra/httpd-vhosts.conf extra/httpd-vhosts.conf_bak_20171222
mv extra/httpd-vhosts.conf_ok extra/httpd-vhosts.conf
systemctl restart apache.service
netstat -ntlp
}

plan_b_back(){
cp httpd.conf httpd.conf_err_b
mv httpd.conf_bak_20171222 httpd.conf
cat httpd.conf|grep httpd-ssl
mv extra/httpd-ssl.conf extra/httpd-ssl.conf_err_b
cp extra/httpd-ssl.conf_default extra/httpd-ssl.conf
mv extra/httpd-vhosts.conf extra/httpd-vhosts.conf_err_b
mv extra/httpd-vhosts.conf_bak_20171222 extra/httpd-vhosts.conf
systemctl restart apache.service
netstat -ntlp
}

case $1 in 
	a)
		plan_a
		;;
	a_bak)
		plan_a_back
		;;
	b)
		plan_b
		;;
	b_bak)
		plan_b_back
		;;
esac
