#!/bin/bash
# 创建集群空节点
. ./base.sh

#容器内部的主机名
hostname=`ip address | grep "global e"| cut -d ' ' -f6 | cut -d '/' -f1 | cut -d '.' -f4`$port
#容器名
container_name=redis-$version-$port-running
#redis基础目录
redis_home=/data/redis/$version-$port
#redis配置文件目录
redis_conf=$redis_home/conf
#redis数据文件目录
redis_data=$redis_home/data

#创建目录
mkdir -p $redis_home $redis_conf $redis_data

#编写配置文件
echo "################################## NETWORK #####################################
# bind 127.0.0.1
protected-mode no
port $port
tcp-backlog 511
timeout 0
tcp-keepalive 300
################################# GENERAL #####################################
daemonize no
# pidfile /var/run/redis_6379.pid
loglevel notice
logfile "redis-nodes-$port.log"
# syslog-enabled no
# syslog-ident redis
# syslog-facility local0
databases 16
always-show-logo yes
################################ SNAPSHOTTING  ################################
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir ./
################################# REPLICATION #################################
# slaveof <masterip> <masterport>
# masterauth <master-password>
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
# repl-ping-slave-period 10
# repl-timeout 60
repl-disable-tcp-nodelay no
# repl-backlog-size 1mb
# repl-backlog-ttl 3600
slave-priority 100
# min-slaves-to-write 3
# min-slaves-max-lag 10
# slave-announce-ip 5.5.5.5
# slave-announce-port 1234
################################## SECURITY ###################################
# requirepass foobared
# rename-command CONFIG b840fc02d524045429941cc15f59e41cb7be6c52
################################### CLIENTS ####################################
# maxclients 10000
############################## MEMORY MANAGEMENT ################################
# maxmemory <bytes>
# maxmemory-policy noeviction
# maxmemory-samples 5
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
slave-lazy-flush no
############################## APPEND ONLY MODE ###############################
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
auto-aof-rewrite-min-size 64mb
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
aof-rewrite-incremental-fsync yes
aof-load-truncated yes
aof-use-rdb-preamble no
################################ LUA SCRIPTING  ###############################
lua-time-limit 5000
################################ REDIS CLUSTER  ###############################
cluster-enabled yes
# cluster-config-file nodes-$port.conf
cluster-node-timeout 15000
# cluster-slave-validity-factor 10
# cluster-migration-barrier 1
# cluster-require-full-coverage yes
########################## CLUSTER DOCKER/NAT support  ########################
# cluster-announce-ip 10.1.1.5
# cluster-announce-port 6379
# cluster-announce-bus-port 6380
################################## SLOW LOG ###################################
slowlog-log-slower-than 10000
slowlog-max-len 128
################################ LATENCY MONITOR ##############################
latency-monitor-threshold 0
############################# EVENT NOTIFICATION ##############################
# notify-keyspace-events ""
############################### ADVANCED CONFIG ###############################
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes
########################### ACTIVE DEFRAGMENTATION #######################
# activedefrag yes
# active-defrag-ignore-bytes 100mb
# active-defrag-threshold-lower 10
# active-defrag-threshold-upper 100
# active-defrag-cycle-min 25
# active-defrag-cycle-max 75
" > $redis_conf/redis.conf

docker pull redis:$version

#redis官方推荐使用--net=host模式启动
docker run -d -p $port:$port -v $redis_conf:/usr/local/etc/redis/ -v $redis_data:/data/ --restart=yes --restart=on-failure:3 --net=host --name $container_name -h $hostname redis:$version redis-server /usr/local/etc/redis/redis.conf
