#!/usr/bin/env bash

#配置Java环境
tar xf /usr/local/src/jdk-8u211-linux-x64.tar.gz -C /usr/local/
mv /usr/local/jdk1.8.0_211 /usr/local/java
touch /etc/profile.d/java.sh
echo "
JAVA_HOME=/usr/local/java
PATH=$JAVA_HOME/bin:$PATH
export JAVA_HOME PATH
" >>/etc/profile.d/java.sh
source /etc/profile.d/java.sh

#创建运行ES的普通用户
useradd ela
echo 123 | passwd --stdin ela

#安装配置ES
tar xf /usr/local/src/elasticsearch-6.5.4.tar.gz -C /usr/local/ 
mv /usr/local/elasticsearch-6.5.4 /usr/local/elasticsearch
echo '
cluster.name: bjbpe01-elk
node.name: elk01
node.master: true
node.data: true
path.data: /opt/data/elasticsearch/data
path.logs: /opt/data/elasticsearch/logs
bootstrap.memory_lock: false
bootstrap.system_call_filter: false
network.host: 0.0.0.0
http.port: 9200
#discovery.zen.ping.unicast.hosts: ["172.16.244.26", "172.16.244.27"]
#discovery.zen.minimum_master_nodes: 2
#discovery.zen.ping_timeout: 150s
#discovery.zen.fd.ping_retries: 10
#client.transport.ping_timeout: 60s
http.cors.enabled: true
http.cors.allow-origin: "*"
' >>/usr/local/elasticsearch/config/elasticsearch.yml

#设置JVM堆大小
sed -i 's/-Xms1g/-Xms4g/' /usr/local/elasticsearch/config/jvm.options
sed -i 's/-Xmx1g/-Xmx4g/' /usr/local/elasticsearch/config/jvm.options

#创建ES数据及日志储存目录
mkdir -p /opt/data/elasticsearch/data
mkdir -p /opt/data/elasticsearch/logs

#修改安装目录及存储目录权限
chown -R ela:ela /opt/data/elasticsearch
chown -R ela:ela /usr/local/elasticsearch

#系统优化
echo  "* - nofile 65536" >> /etc/security/limits.conf
echo  "* soft nproc 31717" >> /etc/security/limits.conf
#增加最大内存映射数
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -p
su - ela -c "cd /usr/local/elasticsearch && nohup bin/elasticsearch &"

##安装head插件
#cd /usr/local/src
#yum -y install wget unzip
#wget https://npm.taobao.org/mirrors/node/latest-v4.x/node-v4.4.7-linux-x64.tar.gz
#tar -zxf node-v4.4.7-linux-x64.tar.gz -C /usr/local
#touch /etc/profile.d/node.sh
#echo '
#NODE_HOME=/usr/local/node-v4.4.7-linux-x64
#PATH=$NODE_HOME/bin:$PATH
#export NODE_HOME PATH
#' >>/etc/profile.d/node.sh
#source /etc/profile.d/node.sh
#node --version
#
##下载head插件
#cd /usr/local/src/
#wget https://github.com/mobz/elasticsearch-head/archive/master.zip
#unzip -d /usr/local master.zip
#
##安装grunt
#cd /usr/local/elasticsearch-head-master
#npm install -g grunt-cli
#grunt -version
##修改head源码
#sed -i s/"keepalive: true"/"keepalive: true,"/ /usr/local/elasticsearch-head-master/Gruntfile.js
#sed -i "96i hostname: '*'" /usr/local/elasticsearch-head-master/Gruntfile.js 
#yum -y install net-tools
#$ip=`ifconfig | awk -F" " 'NR==2{print $2}'`
#sed -i s/localhost/$ip/ /usr/local/elasticsearch-head-master/_site/app.js
#
##下载head必要的文件
#cd /usr/local/src
#wget https://github.com/Medium/phantomjs/releases/download/v2.1.1/phantomjs-2.1.1-linux-x86_64.tar.bz2
#yum -y install bzip2
#tar -jxf phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /tmp/
#
##运行head
#cd /usr/local/elasticsearch-head-master/
#npm install
#nohup grunt server &
