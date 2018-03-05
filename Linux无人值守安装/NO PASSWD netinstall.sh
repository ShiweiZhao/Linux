#!/bin/bash
#Ifconfig
echo "# Input ip address."
read I
echo "# Input netmask."
read N
echo "DEVICE=eth0
ONBOOT=yes
BOOTPROTO=static
IPADDR=$I
NETMASK=$N" > /etc/sysconfig/network-scripts/ifcfg-eth0
#Choice cdrom.
ls -l /dev | grep cdrom
echo "# Please input your cdrom name." && read CD
mount /dev/$CD /mnt/ && echo "# Mount CD successfully."	
echo "# Change yum config file. 
# New file name is 'mnt.repo'.
# And new file in '/etc/yum.repos.d/'."
#Change yum config file.
echo "[mnt-source]
name=mnt
baseurl=file:///mnt
gpgcheck=1
enabled=1" > /etc/yum.repos.d/mnt.repo
cat /etc/yum.repos.d/rhel-source.repo | grep "gpgkey=" >> /etc/yum.repos.d/mnt.repo
echo "# Change yum config file is successful." && \
yum -y install dhcp xinetd tftp-server nfs* httpd syslinux system-config-kickstart && \
echo "DNS Server please input."
read D
echo "Subnet please input."
read S
echo "Range please input."
read R
echo "Getway please input."
read G
echo "option domain-name-servers $D;
default-lease-time 86400;
max-lease-time 604800;
next-server $I;
filename=\"pxelinux.0\";
subnet $S netmask $N {
		range $R;
		option routers $G;
}" > /etc/dhcp/dhcpd.conf
cp /mnt/isolinux/vmlinuz /var/lib/tftpboot/
cp /mnt/isolinux/initrd.img /var/lib/tftpboot/
cp /mnt/isolinux/boot.msg /var/lib/tftpboot/
cp /mnt/isolinux/splash.jpg /var/lib/tftpboot/
cp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/
mkdir /var/lib/tftpboot/pxelinux.cfg
cp -p /mnt/isolinux/isolinux.cfg /var/lib/tftpboot/pxelinux.cfg/default
echo "Disk_size please input."
read n
echo "default RHEL6.5
#prompt 1
timeout 600

display boot.msg

menu background splash,jpg
menu title Welcome to Red Hat Enterprise Linux 6.5!
menu color border 0 #ffffffff #00000000
menu color sel 7 #ffffffff #ff000000
menu color title 0 #ffffffff #00000000
menu color tabmsg 0 #ffffffff #00000000
menu color unsel 0 #ffffffff #00000000
menu color hotsel 0 #ff000000 #ffffffff
menu color hotkey 7 #ffffffff #ff000000
menu color scrollbar 0 #ffffffff #00000000

label local
  localboot

label RHEL6.5
  kernel vmlinuz
  append initrd=initrd.img ramdisk_szie=$n ks=http://$I/ks.cfg ksdevice=eth0" > \
/var/lib/tftpboot/pxelinux.cfg/default
echo "/mnt	$S/$N(ro,sync)" > /etc/exports
echo "#platform=x86, AMD64, 或 Intel EM64T
#version=DEVEL
# Firewall configuration
firewall --enabled
# Install OS instead of upgrade
install
# Use NFS installation media
nfs --server=192.168.41.4 --dir=/mnt
# Root password
rootpw zsw5210128..
# System authorization information
auth  --useshadow  --passalgo=sha512
# Use graphical install
graphical
firstboot --disable
# System keyboard
keyboard us
# System language
lang en_US
# SELinux configuration
selinux --enforcing
# Installation logging level
logging --level=info
reboot
# System timezone
timezone  Asia/Shanghai
# System bootloader configuration
network --bootproto=dhcp --device=eth0 --onboot=on
key --skip
bootloader --append=\"rhgb quiet\" --location=mbr --driveorder=sda
zerombr
# Partition clearing information
clearpart --all --initlabel

part /boot --fstype=\"ext4\" --size=1024
part swap --size=2048
part / --fstype=\"ext4\" --grow --size=1  

%packages
@core
@server-policy
%end

%post
echo \"UseDNS no\" >> /etc/ssh/sshd_config
%end" > /var/www/html/ks.cfg
service dhcpd start
service nfs start
service xinetd start
chkconfig tftp on
service httpd start
service iptables stop
setenforce 0
echo "Has httpd is started?
[y/N]"
read YES
if [ $YES = y ] || [ $YES = Y ]
	then exit
	else
echo "Please input host name."
read HOST
echo "127.0.0.1		$HOST" >> /etc/hosts
service httpd restart
fi
