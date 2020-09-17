#Install Nagios Plugins

sudo yum install -y gcc glibc glibc-common make gettest automake autoconf wget openssl-devel net-snmp net-snmp-utils epel-release perl-Net-SNMP
cd /usr/local/src
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz
tar zxf nagios-plugins.tar.gz

cd nagios-plugins-release-2.2.1
./tools/setup
./configure
make
sudo make install

#/usr/local/nagios/etc/objects contains three files which needs to be properly placed
#for nagios to function
#hosts.cfg, services.cfg, commands.cfg
