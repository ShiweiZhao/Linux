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
echo "Startup config is successful."
#Iptables config
read -p "Stop Iptables,Y or n." Iptables
if [ $Iptables = Y ] || [ $Iptables = y ] 
	then service iptables stop
	else echo "Please attention about Iptables config."
fi 