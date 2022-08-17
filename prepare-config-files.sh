#!/bin/sh
SERVER_0_IP=192.168.1.14
SERVER_1_IP=192.168.1.14
SERVER_2_IP=192.168.1.14
REDIS_PASSWORD=a_complex_password

replace_server_ips()
{
  FILE_PATH=$1
  sed -i '.bak' -e "s/_SERVER_0_IP_/$SERVER_0_IP/g" $FILE_PATH
  sed -i '.bak' -e "s/_SERVER_1_IP_/$SERVER_1_IP/g" $FILE_PATH
  sed -i '.bak' -e "s/_SERVER_2_IP_/$SERVER_2_IP/g" $FILE_PATH
  sed -i '.bak' -e "s/_PASSWORD_HERE_/$REDIS_PASSWORD/g" $FILE_PATH
  rm "$FILE_PATH.bak"  
  echo "$FILE_PATH OK"
}

# server-0 - MASTER
cp server-0/redis-0/redis.template server-0/redis-0/redis.conf
replace_server_ips server-0/redis-0/redis.conf
cp server-0/sentinel-0/sentinel.template server-0/sentinel-0/sentinel.conf
replace_server_ips server-0/sentinel-0/sentinel.conf

# server-1 - REPLICA
cp server-1/redis-1/redis.template server-1/redis-1/redis.conf
replace_server_ips server-1/redis-1/redis.conf
cp server-1/sentinel-1/sentinel.template server-1/sentinel-1/sentinel.conf
replace_server_ips server-1/sentinel-1/sentinel.conf

# server-2 - REPLICA
cp server-2/redis-2/redis.template server-2/redis-2/redis.conf
replace_server_ips server-2/redis-2/redis.conf
cp server-2/sentinel-2/sentinel.template server-2/sentinel-2/sentinel.conf
replace_server_ips server-2/sentinel-2/sentinel.conf