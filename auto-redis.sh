#!/usr/bin/env bash

#安装Redis所需的依赖
yum install -y make gcc wget
#下载地址http://redis.io/download，下载最新稳定版本。
wget http://download.redis.io/releases/redis-5.0.4.tar.gz
tar xzf redis-5.0.4.tar.gz -C /usr/local
mv /usr/local/redis-5.0.4 /usr/local/redis
cd /usr/local/redis
#编译
make

#Redis简单配置
sed -ri 's/daemonize no/daemonize yes/' /usr/local/redis/redis.conf
sed -ri 's/timeout 0/timeout 300/' /usr/local/redis/redis.conf

#配置redis为systemctl启动
touch /lib/systemd/system/redis.service
echo "[Unit]
Description=Redis
After=network.target

[Service]
ExecStart=/usr/local/redis/src/redis-server /usr/local/redis/redis.conf  --daemonize no
ExecStop=/usr/local/redis/src/redis-cli -h 127.0.0.1 -p 6379 shutdown

[Install]
WantedBy=multi-user.target" > /lib/systemd/system/redis.service

#redis启动
cd /usr/local/redis/src
./redis-server ../redis.conf
