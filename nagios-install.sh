#!/bin/sh

echo "**************************************************************************"
echo "**************************************************************************"
echo "INSTALLING NAGIOS!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "**************************************************************************"
echo "**************************************************************************"

sleep 10

echo "*******************************"
echo "Wait 10 seconds..."
echo "*******************************"

#Download and install Nagios
cd /usr/local/src
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.5.tar.gz
tar xzf nagioscore.tar.gz

cd /usr/local/src/nagioscore-nagios-4.4.5/
./configure
make all

sudo make install-groups-users
sudo usermod -a -G nagios apache
sudo make install

sleep 5

echo "**************************************************************************"
echo "**************************************************************************"
echo "DONE!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "**************************************************************************"
echo "**************************************************************************"

echo "**************************************************************************"
echo "**************************************************************************"
echo "DONE!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "**************************************************************************"
echo "**************************************************************************"

sleep 5

echo "**************************************************************************"
echo "**************************************************************************"
echo "DAEMONINIT COMMANDMODE CONFIG WEBCONF!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "**************************************************************************"
echo "**************************************************************************"

sudo make install-daemoninit
sudo systemctl enable httpd.service

sudo make install-commandmode
sudo make install-config
sudo make install-webconf

echo "Adding port 80 and 22 **** \n\n\n\n\n\n\n"
sudo systemctl start firewalld
sudo firewall-cmd --zone=public --add-port=80/tcp
sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --zone=public --add-port=22/tcp --permanent

sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

sudo firewall-cmd --reload

sudo systemctl start httpd
sudo systemctl start nagios

