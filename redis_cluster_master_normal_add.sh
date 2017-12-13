#!/bin/bash
# 向集群增加主节点
. ./base.sh

#集群现有的任意节点
read -p '请输集群现有的任意节点ip': set_random_ip
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

#要增加的主节点ip
read -p '请输入要增加的主节点ip:' set_master_ip
if [ -z $set_master_ip ];then
    echo "未输入节点，程序结束"
    exit
else
    master_ip=$set_master_ip
fi

#要增加的主节点端口
read -p '请输入要增加的主节点端口:' set_master_port
if [ -z $set_master_port ];then
    echo "未输入端口，程序结束"
    exit
else
    master_port=$set_master_port
fi

#要增加的主节点的node_id
master_node_id=`redis-cli -h $random_ip -p $random_port cluster nodes | grep $master_ip:$master_port | awk '{print $1}'`

#将主节点加入集群（第一个参数是要增加的主节点，第二个参数是所在集群的任意节点）
$redis_path/src/redis-trib.rb add-node $master_ip:$master_port $random_ip:$random_port
