#!/usr/bin/env bash

#set -e
echo 'docker init 1'
config_file="/etc/maxscale.cnf"

# We start config file creation


sed -i 's/user=myuser/user=boby/g' /etc/maxscale.cnf
sed -i 's/passwd=mypwd/passwd=hey/g' /etc/maxscale.cnf
sed -i 's/Service]/Service]\nenable_root_user=1\nversion_string=10.2.99-MariaDB-maxScale/g' /etc/maxscale.cnf
sed -i 's|port=4008|port=4008\naddress=localhost|g' /etc/maxscale.cnf
sed -i 's|port=4006|port=4006\naddress=localhost|g' /etc/maxscale.cnf
sed -i 's|address=127.0.0.1|address=db|g' /etc/maxscale.cnf


tail -500 /etc/maxscale.cnf

echo 'creating configuration done'

sleep 5

echo 'maxscale launching ...'

#ls -lrt /usr/bin/
#systemctl start maxscale.service
/usr/bin/maxscale --nodaemon

cd /var/log/maxscale
ls -lrt
tail -500 /var/log/maxscale/maxscale.log
#"$@"