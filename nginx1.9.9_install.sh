#!/bin/bash
read -p "Please Input Isntall Dir: " INSTALL_DIR

if [ ! -d $INSTALL_DIR ];then
	mkdir $INSTALL_DIR -p
fi
ubnutu() {
    apt-get -y update
    apt-get install -y build-essential libtool install libpcre3 libpcre3-dev zlib1g-dev openssl
}

centos() {
    yum -y update
    yum install -y pcre pcre-devel libtool openssl openssl-devel 
}

making() {
cd $INSTALL_DIR
wget http://nginx.org/download/nginx-1.9.9.tar.gz
tar zxvf nginx-1.9.9.tar.gz 
cd nginx-1.9.9/
./configure --prefix=$INSTALL_DIR
make && make install
ln -s $INSTALL_DIR/sbin/nginx /usr/bin/nginx
}

ubuntu_service() {
cat << EOF >> /etc/init.d/nginx
#!/bin/sh

### BEGIN INIT INFO
# Provides:      nginx
# Required-Start:    $local_fs $remote_fs $network $syslog $named
# Required-Stop:     $local_fs $remote_fs $network $syslog $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the nginx web server
# Description:       starts nginx using start-stop-daemon
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/bin/nginx
NAME=nginx
DESC=nginx

# Include nginx defaults if available
if [ -r /etc/default/nginx ]; then
    . /etc/default/nginx
fi

STOP_SCHEDULE="${STOP_SCHEDULE:-QUIT/5/TERM/5/KILL/5}"

test -x $DAEMON || exit 0

. /lib/init/vars.sh
. /lib/lsb/init-functions

# Try to extract nginx pidfile
PID=$(cat /data/app/nginx/conf/nginx.conf | grep -Ev '^\s*#' | awk 'BEGIN { RS="[;{}]" } { if ($1 == "pid") print $2 }' | head -n1)
if [ -z "$PID" ]; then
    PID=/run/nginx.pid
fi

if [ -n "$ULIMIT" ]; then
    # Set ulimit if it is set in /etc/default/nginx
    ulimit $ULIMIT
fi

start_nginx() {
    # Start the daemon/service
    #
    # Returns:
    #   0 if daemon has been started
    #   1 if daemon was already running
    #   2 if daemon could not be started
    start-stop-daemon --start --quiet --pidfile $PID --exec $DAEMON --test > /dev/null \
        || return 1
    start-stop-daemon --start --quiet --pidfile $PID --exec $DAEMON -- \
        $DAEMON_OPTS 2>/dev/null \
        || return 2
}

test_config() {
    # Test the nginx configuration
    $DAEMON -t $DAEMON_OPTS >/dev/null 2>&1
}

stop_nginx() {
killall nginx
}

reload_nginx() {
    # Function that sends a SIGHUP to the daemon/service
    start-stop-daemon --stop --signal HUP --quiet --pidfile $PID --name $NAME
    return 0
}

rotate_logs() {
    # Rotate log files
    start-stop-daemon --stop --signal USR1 --quiet --pidfile $PID --name $NAME
    return 0
}

upgrade_nginx() {
    # Online upgrade nginx executable
    # http://nginx.org/en/docs/control.html
    #
    # Return
    #   0 if nginx has been successfully upgraded
    #   1 if nginx is not running
    #   2 if the pid files were not created on time
    #   3 if the old master could not be killed
    if start-stop-daemon --stop --signal USR2 --quiet --pidfile $PID --name $NAME; then
        # Wait for both old and new master to write their pid file
        while [ ! -s "${PID}.oldbin" ] || [ ! -s "${PID}" ]; do
            cnt=`expr $cnt + 1`
            if [ $cnt -gt 10 ]; then
                return 2
            fi
            sleep 1
        done
        # Everything is ready, gracefully stop the old master
        if start-stop-daemon --stop --signal QUIT --quiet --pidfile "${PID}.oldbin" --name $NAME; then
            return 0
        else
            return 3
        fi
    else
        return 1
    fi
}

case "$1" in
    start)
        log_daemon_msg "Starting $DESC" "$NAME"
        start_nginx
        case "$?" in
            0|1) log_end_msg 0 ;;
            2)   log_end_msg 1 ;;
        esac
        ;;
    stop)
        log_daemon_msg "Stopping $DESC" "$NAME"
        stop_nginx
        case "$?" in
            0|1) log_end_msg 0 ;;
            2)   log_end_msg 1 ;;
        esac
        ;;
    restart)
        log_daemon_msg "Restarting $DESC" "$NAME"

        # Check configuration before stopping nginx
        if ! test_config; then
            log_end_msg 1 # Configuration error
            exit $?
        fi

        stop_nginx
        case "$?" in
            0|1)
                start_nginx
                case "$?" in
                    0) log_end_msg 0 ;;
                    1) log_end_msg 1 ;; # Old process is still running
                    *) log_end_msg 1 ;; # Failed to start
                esac
                ;;
            *)
                # Failed to stop
                log_end_msg 1
                ;;
        esac
        ;;
    reload|force-reload)
        log_daemon_msg "Reloading $DESC configuration" "$NAME"

        # Check configuration before stopping nginx
        #
        # This is not entirely correct since the on-disk nginx binary
        # may differ from the in-memory one, but that's not common.
        # We prefer to check the configuration and return an error
        # to the administrator.
        if ! test_config; then
            log_end_msg 1 # Configuration error
            exit $?
        fi

        reload_nginx
        log_end_msg $?
        ;;
    configtest|testconfig)
        log_daemon_msg "Testing $DESC configuration"
        test_config
        log_end_msg $?
        ;;
    status)
        status_of_proc -p $PID "$DAEMON" "$NAME" && exit 0 || exit $?
        ;;
    upgrade)
        log_daemon_msg "Upgrading binary" "$NAME"
        upgrade_nginx
        log_end_msg $?
        ;;
    rotate)
        log_daemon_msg "Re-opening $DESC log files" "$NAME"
        rotate_logs
        log_end_msg $?
        ;;
    *)
        echo "Usage: $NAME {start|stop|restart|reload|force-reload|status|configtest|rotate|upgrade}" >&2
        exit 3
        ;;
esac
EOF
chmod +x /etc/init.d/nginx
cd /etc/init.d/
sed -i "s/^#pid/^pid/g" $INSTALL_DIR/conf/nginx.conf
update-rc.d nginx defaults
systemctl daemon-reload
service nginx status
rm -rf $INSTALL_DIR/nginx-1.9.9*
}

centos_service() {
cat << EOF >> /etc/init.d/nginx
#!/bin/bash 
# chkconfig: - 18 21 
# description: http service. 
# Source Function Library 
. /etc/init.d/functions
# Nginx Settings 
  
NGINX_SBIN="/usr/bin/nginx"
NGINX_CONF="/app/nginx/conf/nginx.conf"
NGINX_PID="/app/nginx/logs/nginx.pid"
RETVAL=0 
prog="Nginx"
  
#Source networking configuration 
. /etc/sysconfig/network
# Check networking is up 
[ ${NETWORKING} = "no" ] && exit 0 
[ -x $NGINX_SBIN ] || exit 0 
  
start() { 
        echo -n $"Starting $prog: "
        touch /var/lock/subsys/nginx
        daemon $NGINX_SBIN -c $NGINX_CONF 
        RETVAL=$? 
        echo
        return $RETVAL 
} 
  
stop() { 
        echo -n $"Stopping $prog: "
        killproc -p $NGINX_PID $NGINX_SBIN -TERM 
        rm -rf /var/lock/subsys/nginx /var/run/nginx.pid 
        RETVAL=$? 
        echo
        return $RETVAL 
} 

  
reload(){ 
        echo -n $"Reloading $prog: "
        killproc -p $NGINX_PID $NGINX_SBIN -HUP 
        RETVAL=$? 
        echo
        return $RETVAL 
} 
  
restart(){ 
        stop 
        start 
} 
  
configtest(){ 
    $NGINX_SBIN -c $NGINX_CONF -t 
    return 0 
} 
  
case "$1" in
  start) 
        start 
        ;; 
  stop) 
        stop 
        ;; 
  reload) 
        reload 
        ;; 
  restart) 
        restart 
        ;; 
  configtest) 
        configtest 
        ;; 
  *) 
        echo $"Usage: $0 {start|stop|reload|restart|configtest}"
        RETVAL=1 
esac
  
exit $RETVAL
EOF
sed -i "s/^#pid/^pid/g" $INSTALL_DIR/conf/nginx.conf
sed -i "s/\/app\/nginx\//'${INSTALL_DIR}'/g" /etc/init.d/nginx
chmod 755 /etc/init.d/nginx
cd /etc/init.d/
chkconfig --add nginx
chkconfig nginx on
service nginx start
rm -rf $INSTALL_DIR/nginx-1.9.9*
}

if [ ! -f /etc/redhat-release ];then
    cat /etc/redhat-release
    centos;
    making;
    centos_service
else
    lsb_release;
    ubuntu;
    making;
    ubuntu_service
fi
