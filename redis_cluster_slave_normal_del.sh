#!/bin/bash
# 集群的主节点删除一个从节点
. ./base.sh

#集群现有的任意节点
read -p '请输集群现有的任意节点ip:' set_random_ip
if [ -z $set_random_ip ];then
    random_ip=$random_ip
else
    random_ip=$set_random_ip
fi

read -p '请输集群现有的任意节点ip的端口:' set_random_port
if [ -z $set_random_port ];then
    random_port=$random_port
else
    random_port=$set_random_port
fi

#通过任意节点获取整个集群节点信息
redis-cli -h $random_ip -p $random_port cluster nodes

#要删除的从节点ip
read -p '请输入要删除的从节点ip:' set_slave_ip
if [ -z $set_slave_ip ];then
    echo "未输入节点，程序结束"
    exit
else
    slave_ip=$set_slave_ip
fi

read -p '请输入要删除的从节点端口:' set_slave_port
if [ -z $set_slave_port ];then
    echo "未输入端口，程序结束"
    exit
else
    slave_port=$set_slave_port
fi

#要删除的从节点node_id
slave_node_id=`redis-cli -h $random_ip -p $random_port cluster nodes | grep $slave_ip:$slave_port | awk '{print $1}'`

#将从节点从集群中删除
$redis_path/src/redis-trib.rb del-node $random_ip:$random_port $slave_node_id

echo "$slave_ip:$slave_port $slave_node_id已脱离集群"
