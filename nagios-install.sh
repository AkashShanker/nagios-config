#!/bin/sh

######################################################################
######		NAGIOS-CORE INSTALLATION SCRIPT			######
######################################################################


#Disable Selinux temporarily
sudo sed 's/enforcing/permissive/g' /etc/selinux/config
sudo setenforce 0
getenforce


########################################################################
###### 			Install Dependencies			  ######
########################################################################

#gcc C Compiler
#glibc Standard C Library
#glibc-common Common binaries and locale data for glibc
#gd Graphic Library for creation of JPEG and PNG
#postfix mail system

# Snippet from: https://unix.stackexchange.com/a/438895

list=("vim" "firewalld" "gcc" "glibc" "glibc-common" "wget" "unzip" "httpd" "php" "gd" "gd-devel" "perl" "postfix")

check_list=$(rpm -q "${list[@]}" | grep -e "not installed" | awk 'BEGIN { FS = " " } ; { printf $2" "}' > /tmp/list.txt)

install=$(cat /tmp/list.txt)

grep -q '[^[:space:]]' < /tmp/list.txt

EMPTY_FILE=$?

if [[ $EMPTY_FILE -eq 1 ]]; then
echo "Nothing to do"

else

echo "Installing: $install"
sudo yum install -y $install
fi

echo "Removing list.txt"
sleep 3
rm /tmp/list.txt



########################################################################
###### 			Install Nagios-Core			  ######
########################################################################

echo -e "\
********************************************************************** \
\n************************INSTALLING NAGIOS***************************** \
\n********************************************************************** \
\n**********************************************************************"


sleep 2

echo "*******************************"
echo "Starting download and installation of nagios core packages in 5 seconds..."
echo "*******************************"

sleep 5


echo "*******************************"
echo "Let's go"
echo "*******************************"
echo "*******************************"

#Download and install Nagios
cd /usr/local/src
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.5.tar.gz
tar xzf nagioscore.tar.gz



echo "*******************************"
echo "Configure and Make"
echo "*******************************"

sleep 5

cd /usr/local/src/nagioscore-nagios-4.4.5/
./configure
make all


echo "*******************************"
echo "Create Groups and Users for Nagios & install"
echo "*******************************"

sleep 5

sudo make install-groups-users
sudo usermod -a -G nagios apache
sudo make install

sleep 5


echo -e "\
********************************************************************** \
\n*****************DONE WITH BASIC INSTALLATION************************* \
\n********************************************************************** \
\n**********************************************************************"

sleep 10

echo -e "\
********************************************************************** \
\n*******Next Step: DAEMONINIT COMMANDMODE CONFIG WEBCONF*************** \
\n********************************************************************** \
\n**********************************************************************"

sleep 10

sudo make install-daemoninit
sudo systemctl enable httpd.service

sudo make install-commandmode
sudo make install-config
sudo make install-webconf


systemctl is-active --quiet nagios && echo -e "nagios is running\n\n\n\n" || sudo systemctl start nagios

echo -e "\
\n******************************
\n****Allowing port 80 and 22****
\n*******************************\n\n\n\n\n\n"

sudo firewall-cmd --zone=public --add-port=80/tcp
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --zone=public --add-port=22/tcp --permanent

sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

sudo firewall-cmd --reload

sleep 5

echo -e "\n********Starting Nagios and HTTPD*******\n"
 
sudo systemctl start httpd
sudo systemctl start nagios



echo -e "\
********************************************************************** \
\n*****************FIREWALL CHANGES COMPLETED************************* \
\n********************************************************************** \
\n**********************************************************************"

sleep 10

echo -e "\
*********************************************************************** \
\n*******Next Step: NAGIOS PLUGIN DOWNLOAD AND INSTALLATION************* \
\n********************************************************************** \
\n**********************************************************************"

sleep 10


#Install Nagios Plugins

######################################################################
######		Nagios Plugin Download and Installation		######
######################################################################

sudo yum install -y gcc glibc glibc-common make gettest automake autoconf wget openssl-devel net-snmp net-snmp-utils epel-release perl-Net-SNMP

cd /usr/local/src

wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz
tar zxf nagios-plugins.tar.gz

cd nagios-plugins-release-2.2.1
./tools/setup
./configure
make
sudo make install


echo -e "\
********************************************************************** \
\n*****************SCRIPT COMPLETED************************* \
\n********************************************************************** \
\n**********************************************************************"

#/usr/local/nagios/etc/objects contains three files which needs to be properly placed
#for nagios to function
#hosts.cfg, services.cfg, commands.cfg
