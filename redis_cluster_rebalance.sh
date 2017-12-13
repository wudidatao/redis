#!/bin/bash

. ./base.sh

echo "
频繁的增删节点，或者设计集群时不合理，会导致数据分片不均衡，redis使用rebalance命令重新平衡各个节点的数据，但官方介绍该功能目前并不完善

https://redis.io/topics/cluster-tutorial

This allows to build some automatism if you are likely to reshard often, however currently there is no way for redis-trib to automatically rebalance the cluster checking the distribution of keys across the cluster nodes and intelligently moving slots as needed. This feature will be added in the future."

echo "目前已知，新增主节点无法直接使用该命令重平衡，暂不知具体使用场景和情况"

#要重平衡的集群的任意节点ip
read -p '请输入要重平衡的集群的任意节点ip:' set_random_ip
if [ -z $set_random_ip ];then
    echo "未输入节点，程序结束"
    exit
else
    random_ip=$set_random_ip
fi

#要重平衡的集群的任意节点端口
read -p '请输入要重平衡的集群的任意节点ip:' set_random_port
if [ -z $set_random_port ];then
    echo "未输入端口，程序结束"
    exit
else
    random_port=$set_random_port
fi

#平衡时自动分配权重
$redis_path/src/redis-trib.rb rebalance $random_ip:$random_port --auto-weights
