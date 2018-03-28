#!/bin/bash

read -p "Please Input Isntall Dir: " INSTALL_DIR

if [ ! -d $INSTALL_DIR ];then
	mkdir $INSTALL_DIR -p
fi
read -p "Please Input Data Files Dir: " DATA_DIR
if [ ! -d $DATA_DIR ];then
        mkdir $DATA_DIR -p
fi

apt-get update
apt-get -y install cmake automake autoconf libtool gcc g++ bison
cd /opt
wget https://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz
tar -zxvf boost_1_59_0.tar.gz -C /usr/local/

git clone https://github.com/mysql/mysql-server.git
groupadd mysql
useradd -r -g mysql mysql
chown -R mysql.mysql $INSTALL_DIR
chown -R mysql.mysql $DATA_DIR

cd mysql-server-5.7

cmake . -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
-DMYSQL_DATADIR=$DATA_DIR \
-DWITH_BOOST=/usr/local/boost_1_59_0 \
-DSYSCONFDIR=/etc \
-DEXTRA_CHARSETS=all

make
make install

cd $INSTALL_DIR/bin
./mysqld --initialize-insecure --user=mysql --basedir=$INSTALL_DIR --datadir=$DATA_DIR

echo "export PATH=$PATH:$INSTALL_DIR/bin" >> /etc/profile
source /etc/profile

cat << EOF >> /etc/mysql/conf.d/mysql.cnf

[client]
port=3306
socket=/tmp/mysql.sock

[mysqld]
basedir=/3D/software/mysql5.7
datadir=/3D/software/mysql5.7/data
port=3306
socket=/tmp/mysql.sock
EOF

cp support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
update-rc.d mysqld defaults
update-rc.d mysqld start 2 3 4 5 . stop 0 1 6

service mysql start
service mysql status
