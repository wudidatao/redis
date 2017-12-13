#!/usr/bin/env python
#coding:utf-8
# 向redis集群插入测试数据
#pip install redis-py-cluster

from rediscluster import StrictRedisCluster
import sys
import time

def redis_cluster():

    #经测试证明，如果redis_nodes节点配置少于实际的redis集群节点，当插入数据时，数据依然会被重定向到忘记配置的集群节点上。
    #如果redis_nodes节点配置多了一些不可用的redis集群节点，数据会被重定向到可用的redis集群节点上，当这些节点可用时，数据就正常写入这些节点。
    redis_nodes = [{'host':'192.168.100.190','port':6379},{'host':'192.168.100.190','port':6380},
                   {'host':'192.168.100.191','port':6379},{'host':'192.168.100.191','port':6380},
                   {'host':'192.168.100.192','port':6379},{'host':'192.168.100.192','port':6380},
                   {'host':'192.168.100.193','port':6379},{'host':'192.168.100.193','port':6380},
                  ]
    try:
        redisconn = StrictRedisCluster(startup_nodes=redis_nodes)
    
    except Exception,e:
        print "连接错误！"
        sys.exit(1)
    
    for i in range(1,100000):
        stri = '%d' %i
        redisconn.set("liutao"+stri,i)
        print redisconn.get("liutao"+stri)
        time.sleep(1)

redis_cluster()
