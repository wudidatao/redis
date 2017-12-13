#!/bin/bash
# 集群重新分片
. ./base.sh

echo "当有新的主节点加入，或者有数据的主节点需要从集群中删除时，使用该命令重新分片集群数据和哈希槽分配"
echo "如果是新加入的主节点，直接输入要分配的哈希槽数量，再输入接收哈希槽的节点的node_id，然后输入all，再即可执行yes操作，集群便会自动完成整个分配过程"
echo "如果是删除主节点，直接输入该主节点想迁移的哈希槽数量，再输入接收哈希槽的节点的node_id，然后输入主节点的node_id，然后输入done，再即可执行yes操作，集群便会自动完成整个分配过程，如果一次性不能迁移完所有哈希槽，可以执行多次迁移"


#要重分片的的节点ip
read -p '请输入要重分片的节点ip，请确认节点是主节点而且没有分配数据槽和数据:' set_master_ip
if [ -z $set_master_ip ];then
    echo "未输入节点，程序结束"
    exit
else
    master_ip=$set_master_ip
fi

#要重分片的节点端口
read -p '请输入要重分片的节点端口:' set_master_port
if [ -z $set_master_port ];then
    echo "未输入端口，程序结束"
    exit
else
    master_port=$set_master_port
fi

$redis_path/src/redis-trib.rb reshard $master_ip:$master_port
