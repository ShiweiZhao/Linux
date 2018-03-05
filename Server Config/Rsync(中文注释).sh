#!/bin/bash
read -p "Local Rsync username:" Localusername		# 定义Rsync本地使用的用户
read -p "Local Rsync Vusername:" LocalVusername		# 定义Rsync的虚拟用户
read -p "Local Rsync Vusername password:" VusernamePassword		# 定义Rsync虚拟用户的密码
read -p "Local Modename:" Modename		# 定义Rsync的模块
read -p "Local Modepath:" Modepath		# 定义Rsync的模块路径
read -p "Mode comment:" ModeComment		# 定义Rsync的模块描述
read -p "Input your Network Segment:" Segment		# 定义Rsync允许那个网段访问
#About read
useradd -s /sbin/nologin $Localusername && echo "Localusername add is successful."		# 使用定义的变量建立本地用户
echo "$LocalVusername:$VusernamePassword" > /etc/rsync.db && \		# 使用定义的变量创建Rsync的密码文件
chmod 600 /etc/rsync.db && echo "LocalVusername add is successful."		# 更改密码文件的权限
mkdir -p $Modepath && chown -R rsync.rsync $Modepath		# 使用定义的变量建立Rsync的模块目录，并更改属主和属组
#Rsync_config		使用定义的变量建立Rsync的配置文件
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
echo "Rsync config successful." && \		# 启动Rsync服务
rsync --daemon && \
echo "Rsync start is successful."
#Startup
echo "/usr/bin/rsync --daemon" >> /etc/rc.local		# 将Rsync加入开机启动列表
cat > /etc/init.d/rsync << EOF		# 将Rsync的启动脚本加入开机启动的脚本当中
#!/bin/bash
#
# rsyncd      This shell script takes care of starting and stopping
#             standalone rsync.
#
# chkconfig: 35 13 91
# description: rsync is a file transport daemon
# processname: rsync
# config: /etc/rsyncd.conf

# Source function library
. /etc/rc.d/init.d/functions

start() {
    # Start daemons.
    rsync --daemon
    if [ $? -eq 0 -a `ps -ef | grep -v grep | grep rsync | wc -l` -gt 0 ];then
        action "starting Rsync:" /bin/true
        sleep 1
    else
        action "starting Rsync:" /bin/false
        sleep 1
    fi
}
stop() {
    pkill rsync;sleep 1;pkill rsync
    #if [ $? -eq 0 -a `ps -ef | grep -v grep | grep rsync | wc -l` -lt 1 ];then
    if [ `ps -ef | grep -v grep | grep "rsync --daemon" | wc -l` -lt 1 ];then
    sleep 1
    else
        action "stopping Rsync: `ps -ef | grep -v grep | grep "rsync --daemon" | wc -l` " /bin/false
        sleep 1
    fi
}
case "$1" in 
    start)
        start;
    ;;
    stop)
        stop;
    ;;
    restart)
        $0 stop;
        $0 start;
    ;;
*)
    echo $"Usage:$0 {start|stop|restart}"
    ;;
esac
EOF
chmod +x /etc/init.d/rsync && \		# 给Rsync启动脚本添加执行权
echo "Startup script config is successful."
#Iptables config
read -p "Stop Iptables,Y or n." Iptables		# 询问是否关闭防火墙
if [ $Iptables = Y ] || [ $Iptables = y ] 
	then service iptables stop
	else echo "Please attention about Iptables config."
fi 