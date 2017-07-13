#!/usr/bin/env bash

#set -e
echo 'docker init 1'
config_file="/etc/maxscale.cnf"

# We start config file creation


sed -i 's/user=myuser/user=boby/g' /etc/maxscale.cnf
sed -i 's/passwd=mypwd/passwd=hey/g' /etc/maxscale.cnf
sed -i 's/Service]/Service]\nenable_root_user=1\nversion_string=10.2.99-MariaDB-maxScale/g' /etc/maxscale.cnf
sed -i 's|address=127.0.0.1|address=db|g' /etc/maxscale.cnf
sed -i 's|port=4008|port=4008\naddress=127.0.0.1|g' /etc/maxscale.cnf
sed -i 's|port=4006|port=4006\naddress=127.0.0.1|g' /etc/maxscale.cnf


echo 'creating configuration done'

sleep 15

#################################################################################################
# wait for db availability for 30s
#################################################################################################
mysql=( mysql --protocol=tcp -ubob -hdb --port=3306 )
for j in {1..0}; do
    for i in {10..0}; do
        if echo 'use test2' | "${mysql[@]}" &> /dev/null; then
            break
        fi
        echo 'DB init process in progress...'
        sleep 1
    done

    echo 'use test2' | "${mysql[@]}"
    if [ "$i" = 0 ]; then
        echo 'DB init process failed.'
        exit 1
    fi
done

echo 'maxscale launching ...'

tail -n 500 /etc/maxscale.cnf

#ls -lrt /usr/bin/
#systemctl start maxscale.service
/usr/bin/maxscale --nodaemon

cd /var/log/maxscale
ls -lrt
tail -n     500 /var/log/maxscale/maxscale.log
#"$@"