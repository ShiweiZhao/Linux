#!/bin/bash
read -p "Local Rsync username:" Localusername
read -p "Local Rsync Vusername:" LocalVusername
read -p "Local Rsync Vusername password:" VusernamePassword
read -p "Local Modename:" Modename
read -p "Local Modepath:" Modepath
read -p "Mode comment:" ModeComment
read -p "Input your Network Segment:" Segment
#About read
useradd -s /sbin/nologin $Localusername && echo "Localusername add is successful."
echo "$LocalVusername:$VusernamePassword" > /etc/rsync.db && \
chmod 600 /etc/rsync.db && echo "LocalVusername add is successful."
mkdir -p $Modepath && chown -R rsync.rsync $Modepath
#Rsync_config
echo "uid = rsync
gid = rsync
use chroot = no
max connections = 100
timeout = 300
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log file = /var/log/rsyncd.log
[$Modename]
path = $Modepath
comment = $ModeComment
ignore errors
read only = false
list = false
hosts allow = $Segment
hosts deny = 0.0.0.0/32
auth users = $LocalVusername
secrets file = /etc/rsync.db" > /etc/rsyncd.conf && \
echo "Rsync config successful." && \
rsync --daemon && \
echo "Rsync start is successful."
#Startup
echo "/usr/bin/rsync --daemon" >> /etc/rc.local
echo '# Description: 
#!/bin/bash
# chkconfig: 2345 31 61
# description: start or stop rsync daemon

. /etc/init.d/functions
pidfile=/var/run/rsyncd.pid
RETVAL=0
start_rsync(){
if [ -f $pidfile ];then
    echo "Rsync is already running"
else
    rsync --daemon
    action "Rsync starts successfully "  /bin/true
fi 
}
stop_rsync(){
if [ -f $pidfile ];then
    kill -USR2 `cat $pidfile`
    rm -rf $pidfile
    action "Rsync stops successfully" /bin/true
else 
    action "Rsync is already stopped.Stop Failed" /bin/false    
fi
}
case "$1" in 
    start)
        start_rsync
        RETVAL=$?
        ;;
    stop)
        stop_rsync
        RETVAL=$?
        ;;
    restart)
        stop_rsync
        sleep 2
        start_rsync
        RETVAL=$?
        ;;
    *)
        echo "Usage:$0 start|stop|restart"
        exit 1      
esac
exit $RETVAL' > /etc/init.d/rsyncd
chmod +x /etc/init.d/rsyncd && \
echo "Startup script config is successful."
#Iptables config
read -p "Stop Iptables,Y or n." Iptables
if [ $Iptables = Y ] || [ $Iptables = y ] 
	then service iptables stop
	else echo "Please attention about Iptables config."
fi 