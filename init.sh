#!/bin/bash
# author:wang jin
install_lrzsz(){
	yum install lrzsz
	if [ $? -eq 0 ]
	then 
	echo "install lrzsz success!"
	else
	echo "install lrzsz failure!"
	fi
}
install_java(){
	if [ ! -f "jdk-8u121-linux-x64.rpm" ]
	then
	 echo "jdk not exist!"
	 wget http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.rpm
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
	echo $?
}
install_lrzsz