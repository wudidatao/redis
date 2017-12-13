#!/bin/bash
# 集群中的主节点增加一个从节点
. ./base.sh

#集群现有的任意节点
read -p '请输集群现有的任意节点ip的端口': set_random_ip
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

#要增加的从节点ip
read -p '请输入要增加的从节点ip:' set_slave_ip
if [ -z $set_slave_ip ];then
    echo "未输入节点，程序结束"
    exit
else
    slave_ip=$set_slave_ip
fi

#要增加的从节点端口
read -p '请输入要增加的从节点端口:' set_slave_port
if [ -z $set_slave_port ];then
    echo "未输入端口，程序结束"
    exit
else
    slave_port=$set_slave_port
fi

#要把从节点增加到哪个主节点ip
read -p '请输入要把从节点增加到哪个主节点ip:' set_master_ip
if [ -z $set_master_ip ];then
    echo "未输入节点，程序结束"
    exit
else
    master_ip=$set_master_ip
fi

#要把从节点增加到哪个主节点端口
read -p '请输入要把从节点增加到哪个主节点端口:' set_master_port
if [ -z $set_master_port ];then
    echo "未输入端口，程序结束"
    exit
else
    master_port=$set_master_port
fi

#要增加的从节点所属主节点的node_id
master_node_id=`redis-cli -h $random_ip -p $random_port cluster nodes | grep $master_ip:$master_port | awk '{print $1}'`

#将节点加入集群对应的主节点上
$redis_path/src/redis-trib.rb add-node --slave --master-id $master_node_id $slave_ip:$slave_port $random_ip:$random_port

echo "$slave_ip:$slave_port已加入集群"
