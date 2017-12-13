#!/bin/bash
# 修复单个节点故障
. ./base.sh


read -p '输入修复节点ip': set_random_ip
if [ -z $set_random_ip ];then
    random_ip=$random_ip
else
    random_ip=$set_random_ip
fi

read -p '输入修复节点端口:' set_random_port
if [ -z $set_random_port ];then
    random_port=$random_port
else
    random_port=$set_random_port
fi

$redis_path/src/redis-trib.rb fix $random_ip:$random_port
