#!/bin/bash
# 集群创建
. ./base.sh

yum install wget -y

if [ ! -e $path/redis-$version.tar.gz ];then
    cd $path
    wget http://download.redis.io/releases/redis-$version.tar.gz
    tar -zxvf redis-$version.tar.gz
fi

#redis-trib.rb依赖环境
if [ ! -e $path/ruby-2.3.1.tar.gz ];then
    cd $path
    wget https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz
    tar -zxvf ruby-2.3.1.tar.gz
    cd ruby-2.3.1
    ./configure
    make && make install
fi

yum install rubygems -y
gem install redis

#创建集群
$redis_path/src/redis-trib.rb create --replicas 1 $node1:$port1 $node2:$port2 $node2:$port1 $node3:$port2 $node3:$port1 $node4:$port2 $node4:$port1 $node1:$port2
