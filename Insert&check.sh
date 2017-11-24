#!/bin/bash
AEC_DIR=/var/lib/mysql/aec
CUR_DATE=`date +%Y%m%d`
DB_DIR=/var/lib/mysql/.bakup
DB_SHOW=`mysql --defaults-file=/root/.my.cnf -e "show databases;"|sed '1d'|grep -viE "(information_schema|performance_schema|mysql|sys)"`

insert_backupfile(){
#Download the vipapps database backup file from the local backup server(192.168.1.232)
#	scp -P 22522 root@192.168.1.232:/backup/cad_pcw365_com/database/fullbackup/cad-aec-big-table-$CUR_DATE.tar.gz $DB_DIR
	scp -P 22522 root@192.168.1.232:/backup/cad_pcw365_com/database/fullbackup/cad-other-without-big-table-$CUR_DATE.sql.gz $DB_DIR
	cd $DB_DIR
#	tar zxvf cad-aec-big-table-$CUR_DATE.tar.gz
	gunzip cad-other-without-big-table-$CUR_DATE.sql.gz

#Insert other databases;
	service mysql restart;
	start_tm=`date +%s%N`;
	echo -e "\033[31m Insert other db...... \033[0m";
	mysql --defaults-file=/root/.my.cnf -e "source $DB_DIR/cad-other-without-big-table-$CUR_DATE.sql"
	end_tm=`date +%s%N`;
	use_tm=`echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}'`;
	echo -e "\033[31m OK,Insert other database use $use_tm S \033[0m";

#Insert aec big tables
#	mysql -e "use aec;source $DB_DIR/aec_big_table/aec_big_table-${CUR_DATE}.form;";
#
#	ls $DB_DIR/aec_big_table| while read line 
#	do 
#		AFTER=$(echo $line|sed 's/-'"$CUR_DATE"'//g')
#		mv $DB_DIR/aec_big_table/$line $AEC_DIR/$AFTER
#	done
#
#	start_tm=`date +%s%N`;
#	for i in `ls $AEC_DIR/*.data`
#	do
#		start_tm=`date +%s%N`;
#		echo -e "\033[31m Start insert file $i...... \033[0m"
#		mysqlimport aec $ACE_DIR/$i --fields-terminated-by=','
#		end_tm=`date +%s%N`;
#		use_tm=`echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}'`
#		echo -e "\033[31m OK,Insert File $i use $use_tm S \033[0m"
#	done
#	end_tm=`date +%s%N`;
#	use_tm=`echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}'`;
#	echo -e "\033[31m OK,Insert All Big Tables use $use_tm S \033[0m";
}

clean_old_cache(){
#Delect Old Files;
	find $DB_DIR -name *.gz -exec rm -rf '{}' \;
	find $DB_DIR -name *.sql -exec rm -rf '{}' \;
	find $AEC_DIR -name *.data -exec rm -rf '{}' \; 2 >& /var/log/database/error.log
	find $AEC_DIR -name *.form -exec rm -rf '{}' \; 2 >& /var/log/database/error.log
	rm -rf $DB_DIR/aec_big_table;

#Drop databases;
	service mysql restart;
	for i in $DB_SHOW
	do
		echo -e "\033[31m Start drop $i...... \033[0m"
		start_tm=`date +%s%N`;
		mysql --defaults-file=/root/.my.cnf -e "drop database $i;"
		end_tm=`date +%s%N`;
		use_tm=`echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}'`
		echo -e "\033[31m OK,Delect $i use $use_tm S \033[0m"
	done
	mysql --defaults-file=/root/.my.cnf -e "show databases;"
	echo -e "\033[31m The old database is cleaned up! \033[0m"
}

check_data(){
	service mysql restart;
	for i in $DB_SHOW
	do
		TABLE=`mysql --defaults-file=/root/.my.cnf -e "show tables from $i;"|sed '1d'`
		for table in $TABLE
		do
			#echo -e "\033[31m $table \033[0m"
			mysql --defaults-file=/root/.my.cnf -e "use $i;check table $table EXTENDED"|grep --color=always "$i.$table"
		done
	done
}

vipapps_all(){
#Download the vipapps database backup file from the local backup server(192.168.1.232);
	find /var/lib/mysql/ -name "cad-vipapps*" -exec rm -rf '{}' \;
	scp -P 22522 root@192.168.1.232:/backup/cad_pcw365_com/database/fullbackup/cad-vipapps-${CUR_DATE}.sql.gz /var/lib/mysql/
	gunzip /var/lib/mysql/cad-vipapps-${CUR_DATE}.sql.gz

#Delete the old vipapp database;
	#DATE_SHOW=`mysql --defaults-file=/root/.my.cnf -e "show databases;"|sed '1d'`

	for i in $DATE_SHOW;
do
		if [ $i = vipapps ];then
			mysql --defaults-file=/root/.my.cnf -e "drop database vipapps"
			echo -e "\033[31m old vipapps db delected! \033[0m"
			break;
		fi
	done
	service mysql restart;

#Import data;
	start_tm=`date +%s%N`;
	mysql --defaults-file=/root/.my.cnf -e "show databases;"
	echo -e "\033[31m Start import date...... \033[0m \c"
	mysql --defaults-file=/root/.my.cnf -e "source /var/lib/mysql/cad-vipapps-${CUR_DATE}.sql;"
	end_tm=`date +%s%N`;
	use_tm=`echo $end_tm $start_tm | awk '{ print ($1 - $2) / 1000000000}'`
	echo -e "\033[31m OK,Insert database use $use_tm S \033[0m"

#Check each table of the imported vipapps database;
	TABLE=`mysql --defaults-file=/root/.my.cnf -e "show tables from vipapps;"|sed '1d'`
	for table in $TABLE
	do
		#echo -e "\033[31m $table \033[0m"
		mysql --defaults-file=/root/.my.cnf -e "use vipapps;check table $table EXTENDED"|grep --color=always "vipapps.${table}"|tee /var/log/database/vipapps_check.log
	done

}

case $1 in 
	insert)
		insert_backupfile
		;;
	clean)
		clean_old_cache
		;;
	check)
		check_data|tee /var/log/database/check.log
		;;
	vipapps)
		vipapps_all
		;;
	all)
		date;
		clean_old_cache&&insert_backupfile;check_data|tee /var/log/database/check.log
		;;
esac
