#!/bin/bash
# 集群删除一个主节点
. ./base.sh

#集群现有的任意节点
read -p '请输集群现有的任意节点ip:' set_random_ip
if [ -z $set_random_ip ];then
    echo "未输入节点，程序结束"
    exit
else
    random_ip=$set_random_ip
fi

read -p '请输集群现有的任意节点ip的端口:' set_random_port
if [ -z $set_random_port ];then
    echo "未输入端口，程序结束"
    exit
else
    random_port=$set_random_port
fi

#通过任意节点获取整个集群节点信息
redis-cli -h $random_ip -p $random_port cluster nodes

#要删除的主节点ip
read -p '请输入要删除的主节点ip:' set_master_ip
if [ -z $set_master_ip ];then
    echo "未输入节点，程序结束"
    exit
else
    master_ip=$set_master_ip
fi

#要删除的从节点端口
read -p '请输入要删除的主节点端口:' set_master_port
if [ -z $set_master_port ];then
    echo "未输入端口，程序结束"
    exit
else
    master_port=$set_master_port
fi

#要删除的主节点node_id
master_node_id=`redis-cli -h $random_ip -p $random_port cluster nodes | grep $master_ip:$master_port | awk '{print $1}'`

#将主节点从集群中删除
$redis_path/src/redis-trib.rb del-node $random_ip:$random_port $master_node_id

echo "$master_ip:$master_port $master_node_id已脱离集群"
