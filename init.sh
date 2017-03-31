#!/bin/bash
# author:wang jin
init_setting(){
	timedatectl set-timezone Asia/Shanghai
	
}
install_lrzsz(){
	yum install lrzsz
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
install_lrzsz
install_jdk