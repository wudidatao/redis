#!/bin/bash

#软件安装目录
path=/root/install
#软件安装版本
version=4.0.2
#redis安装目录
redis_path=$path/redis-$version
#节点随机ip
random_ip=192.168.100.190
#节点随机端口
random_port=6379

#redis默认端口
port=6379
#容器内部的主机名
hostname=`ip address | egrep "global e|global dynamic e"| cut -d ' ' -f6 | cut -d '/' -f1`$port
#容器名
container_name=redis-$version-$port-running
#redis基础目录
redis_home=/data/redis/$version-$port
#redis配置文件目录
redis_conf=$redis_home/conf
#redis数据文件目录
redis_data=$redis_home/data

#集群节点
node1=192.168.100.190
node2=192.168.100.191
node3=192.168.100.192
#node4=192.168.100.193
#node5=192.168.100.194
#集群端口
port1=6379
port2=6380
#port3=

echo "path"  $path
echo "version" $version
echo "redis_path" $redis_path
echo "random_ip" $random_ip
echo "random_port" $random_port
echo "port" $port
echo "hostname" $hostname
echo "container_name" $container_name
echo "redis_home" $redis_home
echo "redis_conf" $redis_conf
echo "redis_data" $redis_data
echo "node1" $node1
echo "node2" $node2
echo "node3" $node3
#echo "node4" $node4
#echo "node5" $node5
echo "port1" $port1
echo "port2" $port2
#echo "port3" $port3
