#!/bin/bash
# 创建集群空节点
read -p '版本,最新3.2.11和4.0.2,默认4.0.2:' version_set
if [ -z $version_set ];then
        version=4.0.2
else
        version=$version_set
fi

read -p '端口,默认6379:' port_set
if [ -z $port_set ];then
        port=6379
else
        if [ -n $port_set ];then
                port=$port_set
        else
                echo "输入不正确，使用默认值"
                port=6379
        fi
fi

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
# 监听ip绑定，默认127.0.0.1，一般改为本地ip即可，docker环境下注释该参数即可
# bind 127.0.0.1
# 保护模式，默认yes打开，3.2之后新参数，在保护模式下，如果没有绑定监听ip，也没有设置集群密码，则节点只能接受来自本地的命令，将导致集群脚本无法在任意节点执行命令，这时可以改为no
protected-mode no
# 监听端口
port $port
# tcp accept队列长度（accept队列用于保存ESTABLISHED状态的连接），redis默认511，linux默认128，如果linux小于redis，将使用linux配置，并给予警告。
# 建议将linux改为511以上，通过调整内核参数 net.core.somaxconn = 511 ，使用/proc/sys/net/core/somaxconn查看效果
tcp-backlog 511
# 客户端空闲多久才关闭连接，默认0一直不断开，如果客户端由于某些原因没有正常关闭连接，导致连接数增大，占用端口过多，可考虑增大该参数到300
timeout 0
# tcp_keepalive默认保持时间，默认300，3.2.1之后新参数，linux默认7200，通过调整内核参数 net.ipv4.tcp_keepalive_time = 7200，使用/proc/sys/net/ipv4/tcp_keepalive_time查看效果
tcp-keepalive 300

################################# GENERAL #####################################
# 默认no,表示前台运行redis，docker环境为前台运行no，非docker环境要改成yes，表示后台运行
daemonize no
# 之后在daemonize yes时，才有pid文件生成，这里不用设置，直接注释
# pidfile /var/run/redis_6379.pid
# 日志模式，默认notice，日志详细程度由高到低是debug verbose notice warning
loglevel notice
# 日志输出位置，默认/dev/null，需要输出到硬盘上
logfile "redis-nodes-$port.log"
# 是否将日志文件输出到linux系统日志中（/var/log/message），默认no不输出，不用修改
# syslog-enabled no
# 记录到linux系统日志中（/var/log/message）的信息的标识符，syslog-enabled no时该参数无效。
# syslog-ident redis
# 日志输出级别，LOCAL0-LOCAL7之间，默认local0，不用修改
# syslog-facility local0
# 默认数据库数，16个
databases 16
always-show-logo yes
################################ SNAPSHOTTING  ################################
# 如果900秒内有1个key变化，则持久化保存快照
# 如果300秒内有10个key变化，则持久化保存快照
# 如果10000秒内有60个key变化，则持久化保存快照
save 900 1
save 300 10
save 60 10000
# 如果redis后台快照保存的进程出现故障，redis将禁止写入，当故障消失时，会继续写入数据，建议默认打开
stop-writes-on-bgsave-error yes
# 保存快照是否压缩，默认使用，压缩则写入操作效率低点但数据文件小，反之写入操作快但文件大
rdbcompression yes
# 否校验快照，默认校验
rdbchecksum yes
# 快照文件名，默认dump.rdb 
dbfilename dump.rdb 
# 快照文件存储路径
dir ./
################################# REPLICATION #################################
# 设置slave访问masterip和port，该参数为主从模式下使用，集群模式下不需要使用该参数
# slaveof <masterip> <masterport>
# 设置slave访问master的密码，该参数为主从模式下使用，集群模式下不需要使用该参数
# masterauth <master-password>
# master和slave失联或正在复制时，slave是否返回数据，yes表示返回，数据可能会过时，no表示不返回，salve返回SYNC with master in progress等待异常恢复
slave-serve-stale-data yes
# slave只读，从2.6版本开始，默认打开，如果配置文件中不加入该参数，slave不可读写，只能故障转移，如果想让slave可读，需要显示加入参数
slave-read-only yes
# 主从同步策略，yes时master创建一个进程将快照写入硬盘后，然后立刻再将写好的硬盘文件传给每个slave，默认no时master创建一个进程将快照直接写入slave复制进程，不写入硬盘
repl-diskless-sync no
# 当使用无盘复制模式（repl-diskless-sync no）时，master向slave同步的延迟时间，如果设置0，将以最快的速度将master的快照写入slave复制进程中，默认会有5秒延迟
repl-diskless-sync-delay 5
# slave向master发送ping包的间隔时间，默认10秒
# repl-ping-slave-period 10
# 设置主从同步的超时时间，这个值必须大于repl-ping-slave-period，默认60秒
# repl-timeout 60
# 是否在slave套接字发送SYNC之后禁用TCP_NODELAY
#yes,Redis将使用更少的TCP包和带宽来向slaves发送数据。但是这将使数据传输到slave上有延迟，Linux内核的默认40毫秒
# 默认no,数据传输到salve的延迟将会减少但要使用更多的带宽
repl-disable-tcp-nodelay no
# 设置数据复制的backlog大小，backlog是一个slave在一段时间内断开连接时记录salve数据的缓冲， 所以一个slave在重新连接时，不必要全量的同步，而是一个增量同步就足够了，将在断开连接的这段时间内slave丢失的部分数据传送给它。
# 同步的backlog越大，slave能够进行增量同步并且允许断开连接的时间就越长
# repl-backlog-size 1mb
#slave与master断开开始计时多少秒后，backlog缓冲将会释放。默认3600，0表示永不释放backlog
# repl-backlog-ttl 3600
# slave的优先级,master故障时，优先级低数字小的会被优先提升为master,0表示永远不能成为master，默认100
slave-priority 100
# 如果master连接的数量小于min-slaves-to-write，而且延迟超过min-slaves-max-lag秒，master将禁止写入，默认都是0，禁止使用该特性
# 延迟是以秒为单位，是指从最后一个从slave接收到的ping（通常每秒发送）开始计数。
# min-slaves-to-write 3
# min-slaves-max-lag 10
# slave-announce-ip 5.5.5.5
# slave-announce-port 1234
################################## SECURITY ###################################
# redis密码，建议强度高一些，redis每秒可以执行150K次破解
# requirepass foobared
# 命令别名，可以把命令改成一串类似密码的字符，这里是把CONFIG命令改为b840fc02d524045429941cc15f59e41cb7be6c52
# rename-command CONFIG b840fc02d524045429941cc15f59e41cb7be6c52
################################### CLIENTS ####################################
# 限制客户端的数量，默认10000
# maxclients 10000
############################## MEMORY MANAGEMENT ################################
# 设置最大可用内存，单位是字节，默认被注释，表示不限制
# maxmemory <bytes>
# 内存过期算法 
# volatile-lru:使用LRU算法来删除一个集合中过期的key，适合有明显时间顺序的数据
# allkeys-lru:使用LRU算法来删除所有过期的key
# volatile-lfu:使用LFU算法来删除一个集合中过期的key
# allkeys-lfu:使用LFU算法来删除所有过期的key
# volatile-random:使用随机算法来删除一个集合中过期的key，适合随机数据
# allkeys-random:使用随机算法来删除所有过期的key
# volatile-ttl:删除最近即将过期的key（the nearest expire time (minor TTL)）
# noeviction :根本不过期，写操作直接报错(默认)
# maxmemory-policy noeviction
# 设置maxmemory-policy采样时的样本数量，影响算法精度，默认5，,10比较接近真实情况，3不够准确
# maxmemory-samples 5

lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
slave-lazy-flush no

############################## APPEND ONLY MODE ###############################
# appendonly模式，默认no，服务器宕机时，可能会丢失一秒钟数据，建议改为yes，打开后，redis不会丢失任何数据
appendonly yes
# appendonly文件名
appendfilename "appendonly.aof"
# appendfsync always 每次收到aof写命令就立即强制写入磁盘，最慢的，但是保证完全的持久化，不推荐使用
# appendfsync everysec 每秒钟强制写入磁盘一次，在性能和持久化方面做了很好的折中，默认值，推荐
# appendfsync no 完全依赖os，一般为30秒左右一次，性能最好,持久化没保证
appendfsync everysec
# aof自动重写的百分比，默认100，表示当aof文件当前大小为1G，则下一次重写时间为aof增长为2G的时候，如果命令中重复较多，可以减少这个比例到50，如果重复较少，可以使用默认值
auto-aof-rewrite-min-size 64mb
#在日志重写时，不进行命令追加操作，而只是将其放在缓冲区里，避免与命令的追加造成DISK IO上的冲突？？？？？？？？？？？？？？？
no-appendfsync-on-rewrite no
# 默认64mb表示如果aof文件大于64mb就进行重写。
auto-aof-rewrite-percentage 100
aof-rewrite-incremental-fsync yes
# Redis3.0参数，redis在启动时可以加载被截断的AOF文件，而不需要先执行redis-check-aof工具
aof-load-truncated yes
aof-use-rdb-preamble no
################################ LUA SCRIPTING  ###############################
lua-time-limit 5000
################################ REDIS CLUSTER  ###############################
# 是否使用集群模式，默认no不使用，这里要创建的是redis集群，所以打开该参数
cluster-enabled yes
# 集群配置文件，该文件为系统自动生成，不能人工操作，这里指定该文件名称，docker环境下注释该参数即可
# cluster-config-file nodes-$port.conf
# 集群节点的超时时间，当节点达到这个时间，集群其他节点才会认为该节点失效，默认15秒
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
# redis关闭客户端超时的连接，清除未被请求过的过期Key等操作的频率，默认10
# 该参数影响serverCron频率，serverCron每间隔1000/hz ms会调用databasesCron方法来检测并淘汰过期的key。
# 官方不建议设置超过100，该参数提高会增加cpu开销，但可以提高高并发处理速度
hz 10
aof-rewrite-incremental-fsync yes
# lfu-log-factor 10
# lfu-decay-time 1
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
