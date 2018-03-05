#!/bin/bash
while true 
do
#Menu
cat << EOF
#######################################
#  1.Config Network                   #
#  2.Config yum and install software  #
#  3.System and services config       #
#  0.Exit this script                 #
#######################################
EOF
read -p "Please input your choice:" Choice
#Config Network
Network() {
read -p "DEVICE name please input:" DEVICE
read -p "IP please input:" IP
read -p "NETMASK please input:" MASK
read -p "GATEWAY please input:" GATEWAY
cat > /etc/sysconfig/network-scripts/ifcfg-eth0<<EOF
DEVICE=$DEVICE
TYPE=Ethernet
ONBOOT=yes
BOOTPROTO=static
IPADDR=$IP
NETMASK=$MASK
GATEWAY=$GATEWAY
EOF
}
#Config yum and install software
Yum() {
cat > /etc/resolv.conf<<EOF
nameserver 8.8.8.8
nameserver 1.2.4.8
EOF
echo '# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the 
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-$releasever - Base - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/os/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6

#released updates 
[updates]
name=CentOS-$releasever - Updates - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/updates/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6

#additional packages that may be useful
[extras]
name=CentOS-$releasever - Extras - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/extras/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=extras
gpgcheck=1
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6

#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-$releasever - Plus - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/centosplus/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=centosplus
gpgcheck=1
enabled=0
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6

#contrib - packages by Centos Users
[contrib]
name=CentOS-$releasever - Contrib - 163.com
baseurl=http://mirrors.163.com/centos/$releasever/contrib/$basearch/
#mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=contrib
gpgcheck=1
enabled=0
gpgkey=http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-6' > /etc/yum.repos.d/CentOS6-Base-163.repo
yum clean all
yum makecache
echo "# Change yum config file is successful."
yum -y install man tree wget lftp lrzsz lsof sysstat curl nmap telnet vim dos2unix
}
#System and services config
System() {
cp /etc/selinux/config /etc/selinux/config.bak && \
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak && \
sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
sed -i 's/#GSSAPIAuthentication yes/GSSAPIAuthentication no/g' /etc/ssh/sshd_config
cp /etc/security/limits.conf /etc/security/limits.conf.bak && \
echo "*			-		nofile		65535" >> /etc/security/limits.conf
for service in `chkconfig --list | grep 3:on | awk '{print $1}' | \
grep -Ev "crond|network|rsyslog|sysstat|sshd|iptables|ip6tables"`
do chkconfig $service off
done
echo "/usr/bin/rsync --daemon" >> /etc/rc.local
service network restart && service sshd restart
}
case $Choice in
	0)
		read -p "Reboot now y or n:" $Y 
		if [ $Y = Y ] || [ $Y = y ]
		then 
			reboot
		else
			exit 130
		fi 
	;;
	1)
		Network > /dev/null && \
		echo "Network config is successful."
	;;
	2)
		Yum > /dev/null && \
		echo "Software install is successful."
	;;
	3)
		System > /dev/null && \
		echo "System and service config is successful."
	;;
	*)
		echo "Please input {0|1|2|3}."
esac
done 