#!/bin/bash
# author:wang jin
install_lrzsz(){
	yum install lrzsz
	if[$? -eq 0]
	then 
	echo "install lrzsz success!"
	else
	echo "install lrzsz failure!"
	fi
}
install_lrzsz