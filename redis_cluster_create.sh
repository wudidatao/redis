#!/bin/bash
# 集群创建
. ./base.sh

cd $path
wget http://download.redis.io/releases/redis-$version.tar.gz
tar -zxvf redis-$version.tar.gz
cd $redis_path

#redis-trib.rb依赖环境
#yum install ruby
#yum install rubygems
#gem install redis

$redis_path/src/redis-trib.rb create --replicas 1 $node1:$port1 $node2:$port2 $node2:$port1 $node3:$port2 $node3:$port1 $node4:$port2 $node4:$port1 $node1:$port2
