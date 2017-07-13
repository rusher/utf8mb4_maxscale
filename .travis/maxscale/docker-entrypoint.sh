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
#cat <<EOF > $config_file
#
#
#[maxscale]
#threads=2
#log_messages=1
#log_trace=1
#log_debug=1
#
#[db]
#type=server
#address=db
#port=3306
#protocol=MySQLBackend
#authenticator_options=skip_authentication=true
#router_options=master
#
#[Galera Monitor]
#type=monitor
#module=mysqlmon
#servers=db
#user=boby
#passwd=hey
#monitor_interval=1000
#
#[qla]
#type=filter
#module=qlafilter
#options=/tmp/QueryLog
#
#[fetch]
#type=filter
#module=regexfilter
#match=fetch
#replace=select
#
#[hint]
#type=filter
#module=hintfilter
#
#[Write Connection Router]
#type=service
#router=readconnroute
#servers=db
#user=boby
#passwd=hey
#router_options=master
#localhost_match_wildcard_host=1
#version_string=10.2.99-MariaDB-maxscale
#
#[Read Connection Router]
#type=service
#router=readconnroute
#servers=db
#user=boby
#passwd=hey
#router_options=synced
#localhost_match_wildcard_host=1
#version_string=10.2.99-MariaDB-maxscale
#
#[RW Split Router]
#type=service
#router=readwritesplit
#servers=db
#user=boby
#passwd=hey
#max_slave_connections=100%
#localhost_match_wildcard_host=1
#router_options=disable_sescmd_history=true
#version_string=10.2.99-MariaDB-maxscale
#
#[CLI]
#type=service
#router=cli
#
#[RW Split Listener]
#type=listener
#service=RW Split Router
#protocol=MySQLClient
#port=4006
#socket=/var/lib/maxscale/rwsplit.sock
#
#[Write Connection Listener]
#type=listener
#service=Write Connection Router
#protocol=MySQLClient
#port=4007
#socket=/var/lib/maxscale/writeconn.sock
#
#[Read Connection Listener]
#type=listener
#service=Read Connection Router
#protocol=MySQLClient
#port=4008
#socket=/var/lib/maxscale/readconn.sock
#
#[CLI Listener]
#type=listener
#service=CLI
#protocol=maxscaled
#socket=/tmp/maxadmin.sock
#
#EOF

echo 'creating configuration done'
echo 'maxscale run init ...'
sleep 5
echo 'maxscale run wait for DB done ...'

#################################################################################################
# wait for db availability for 30s
#################################################################################################
mysql=( mysql --protocol=tcp -ubob -hdb --port=3306 )
#for j in {1..0}; do
#    for i in {10..0}; do
#        if echo 'use test2' | "${mysql[@]}" &> /dev/null; then
#            break
#        fi
#        echo 'DB init process in progress...'
#        sleep 3
#    done
#
#    echo 'use test2' | "${mysql[@]}"
#    if [ "$i" = 0 ]; then
#        echo 'DB init process failed.'
#        exit 1
#    fi
#done
echo 'maxscale launching ...'

#ls -lrt /usr/bin/
#systemctl start maxscale.service
/usr/bin/maxscale --nodaemon

cd /var/log/maxscale
ls -lrt
tail -500 /var/log/maxscale/maxscale.log
#"$@"