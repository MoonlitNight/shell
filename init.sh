#!/bin/bash
# author:wang jin
init_setting(){
	#network setting
	systemctl enable firewalld.service
	systemctl start firewalld.service	
	add_firewall_port
	#timezone setting
	timedatectl set-timezone Asia/Shanghai
	echo "0 2 * * * /sbin/reboot"  >> /var/spool/cron/root
	service crond restart
}
add_firewall_port(){
	ssh_port=""
	while [ "$ssh_port" != "exit"   ]
	do
		read -p "please enter your firewall communication port used(enter exit this feature):" ssh_port
		add_script="firewall-cmd --zone=public --add-port=$ssh_port/tcp --permanent"
		eval $add_script
		if [ $? -eq 0 ]
		then
		echo "$add_script success!"
		fi
	done
	echo "add firewall rule success!"
	firewall-cmd --reload
}
install_lrzsz(){
	yum install -y lrzsz
	if [ $? -eq 0 ]
	then 
	echo "install lrzsz success!"
	else
	echo "install lrzsz failure!"
	fi
}
install_jdk(){
	java -version
	if [ $? -eq 0 ]
	then 
		echo "----------jdk exist!-----------"
		return
	fi
	if [ ! -f "jdk-8u121-linux-x64.rpm" ]
	then
	 echo "jdk not exist!"
	 wget  -c -P /root --no-check-certificate --no-cookie --header "Cookie:s_nr=1489927766492;s_cc=true;oraclelicense=accept-securebackup-cookie;gpw_e24=2F;s_sq=oracleotnlive%2Coracleglobal%3D%2526pid%253Dotn%25253Aen-us%25253A%25252Fjava%25252Fjavase%25252Fdownloads%25252Fjdk8-downloads-2133151.html%2526pidt%253D1%2526oid%253Dfunctiononclick(event)%25257BacceptAgreement(window.self%25252C'jdk-8u121-oth-JPR')%25253B%25257D%2526oidt%253D2%2526ot%253DRADIO"  http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.rpm
	fi
	rpm -i jdk-8u121-linux-x64.rpm
	if [ $? -eq 0 ]
	then 
	echo "install jdk success!"
	rm -f jdk-8u121-linux-x64.rpm
	else
	echo "install jdk failure!"
	fi
	java -version
}
install_mysql(){
	bakdir=`pwd`/mysqlbackup/
	configpath=/etc/my.cnf
	wget https://dev.mysql.com/get/mysql57-community-release-el7-9.noarch.rpm
	yum localinstall mysql57-community-release-el7-9.noarch.rpm
	yum repolist enabled | grep "mysql.*-community.*"
	if [ $? -eq 0 ]
	then 
	echo "install mysql source success!"
	rm -f mysql57-community-release-el7-9.noarch.rpm*
	yum install -y mysql-community-server
	if [ ! -d "$bakdir" ]; then mkdir $bakdir; fi 
	cp $configpath $bakdir
	echo "validate_password_policy=0" >> $configpath
	echo "validate_password = off" >> $configpath
	echo "character_set_server=utf8" >> $configpath
	echo "init_connect='SET NAMES utf8'" >> $configpath
	systemctl start mysqld
	systemctl enable mysqld
	systemctl daemon-reload
	echo "set mysql auto start success!"
	grep "temporary password" /var/log/mysqld.log > $bakdir/mysqlpasswordinfo.bak
	echo "mysql default password please cat mysqlpasswordinfo.bak!"
	fi
}
install_nginx(){
	yumSourceDir=/etc/yum.repos.d/nginx.repo
	echo "[nginx]" >> $yumSourceDir
	echo "baseurl=http://nginx.org/packages/centos/7/x86_64/" >> $yumSourceDir
	echo "gpgcheck=0" >> $yumSourceDir
	echo "enabled=1" >> $yumSourceDir
	echo "write ngin yum source success!"
	yum install -y nginx
	systemctl enable nginx.service
	cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
	echo "backup nginx default config:nginx.conf.bak success!"
	service nginx start
	echo "start nginx service success!"
}
install_shadowsocks(){
	yum install -y gcc automake autoconf libtool make build-essential autoconf libtool 
	yum install -y curl curl-devel zlib-devel openssl-devel perl perl-devel cpio expat-devel gettext-devel
	git clone https://github.com/clowwindy/shadowsocks-libev.git
	if [ $? -ne 0 ]
	then 
	echo "download git source code failure!"
	return
	fi
	echo "download git source code success!"
	cd shadowsocks-libev
	git checkout master
	./configure && make
	make install
	cp rpm/SOURCES/etc/init.d/shadowsocks /etc/init.d/
	chmod +x /etc/init.d/shadowsocks
	echo "shadowsocks install success!"
	cd ..
	rm -rf shadowsocks-libev
	config_path=/etc/shadowsocks
	read -p "please enter your server IP:" ip
	read -p "please enter your server port:" port
	read -p "please enter your server password:" password
	if [ ! -d "$config_path" ]; then mkdir $config_path; fi 
	echo -e "{\n\"server\":\"$ip\",\n\"server_port\":$port,\n\"local_address\": \"127.0.0.1\",\n\"local_port\":1080,\n\"password\":\"$password\",\n\"timeout\":300,\n\"method\":\"aes-256-cfb\",\n\"fast_open\": false\n}" >> $config_path/config.json
	if [ $? -ne 0 ]
	then
	echo "create shadowsocks setting please try again!"
	return
	fi
	echo -e "create shadowsocks setting success!\nyour ip:$ip\nport:$port\npassword:$password"
	echo -e "[Unit]\nDescription=Shadowsocks\nAfter=network.target\n\n[Service]\nType=simple\nUser=nobody\nExecStart=/etc/init.d/shadowsocks start\nExecReload=/etc/init.d/shadowsocks restart\nExecStop=/etc/init.d/shadowsocks stop\nPrivateTmp=true\nKillMode=process\nRestart=on-failure\nRestartSec=5s\n\n[Install]\nWantedBy=multi-user.target\n" > /usr/lib/systemd/system/shadowsocks.service
	systemctl enable shadowsocks.service
	systemctl start shadowsocks.service
}
show(){
	echo -e "\n"
	echo "----------------------------------"  
	echo "please enter your choise:"  
	echo "(0) default_auto_install"  
	echo "(1) init setting"  
	echo "(2) add firewall port"  
	echo "(3) install lrzsz"  
	echo "(4) install jdk1.8"  
	echo "(5) install mysql 5.7"  
	echo "(6) install nginx" 
	echo "(7) install shadowsocks" 
	echo "(8) Exit Menu"  
	echo "----------------------------------"  
}
menu(){
	input=0
	while [ $input -ne 8 ]
	do
	show
	read input
	case $input in  
		0) default_auto_install;;  
		1) init_setting;;  
		2) add_firewall_port;;  
		3) install_lrzsz;;  
		4) install_jdk;;  
		5) install_mysql;;  
		6) install_nginx;;
		7) install_shadowsocks;;
		9) exit;;  
	esac
	done
}
default_auto_install(){
	install_lrzsz
	install_jdk
	install_mysql
	install_nginx
	install_shadowsocks
	init_setting
}
menu