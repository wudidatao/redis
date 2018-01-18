#!/bin/bash
# redis°²×°
. ./base.sh

if [ ! -e $path/redis-$version.tar.gz ];then
    cd $path
    wget http://download.redis.io/releases/redis-$version.tar.gz
    tar -zxvf redis-$version.tar.gz
fi

cd $path/redis-$version
make && make install