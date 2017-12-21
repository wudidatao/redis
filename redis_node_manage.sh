#!/bin/bash
# redis-cli常用管理命令
. ./base.sh

echo "
读取测试数据 get
清除所有数据库 flushdb
删除所有数据库中的key flushall
查看集群信息 cluster info
查看所有节点 cluster nodes
查看默认信息 info default
查看所有信息，比default更详细 info all
监控所有正在执行的语句 monitor
查看慢查询日志的长度 slowlog len
查看慢查询日志的内容 slowlog get
重新记录慢查询 slowlog reset
关闭redis服务器 shutdown
故障转移，从库执行后提升为主库 cluster failover
查看当前所有客户端连接信息 client list
"

#集群现有的任意节点
read -p '输入随机ip': set_random_ip
if [ -z $set_random_ip ];then
    random_ip=$random_ip
else
    random_ip=$set_random_ip
fi

read -p '输入随机ip的端口:' set_random_port
if [ -z $set_random_port ];then
    random_port=$random_port
else
    random_port=$set_random_port
fi

read -p '输入命令:' cmd

read -p '输入密码，如果没设置密码为空:' set_password
if [ -z $set_password ];then
    redis-cli -h $random_ip -p $random_port $cmd
else
    redis-cli -h $random_ip -p $random_port -a $set_password $cmd 
fi
