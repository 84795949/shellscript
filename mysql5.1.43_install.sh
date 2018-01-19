yum -y install ncurses* libtermcap* gcc
useradd  -s /sbin/nologin  mysql
#wget http://downloads.mysql.com/archives/mysql-5.1/mysql-5.1.54.tar.gz
mkdir /home/server/mysql5 -p
tar zxvf mysql-5.1.54.tar.gz
cd mysql-5.1.54
mkdir /home/data
./configure --prefix=/home/server/mysql5 --localstatedir=/home/data
make && make install
cp support-files/my-medium.cnf /etc/my.cnf


http://blog.csdn.net/u013378306/article/details/72857240
http://blog.csdn.net/xyang81/article/details/52562571
http://www.linuxidc.com/Linux/2013-05/84735.htm
