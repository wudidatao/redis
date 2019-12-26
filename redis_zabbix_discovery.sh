#!/bin/bash

#配置zabbix的redis监控参数和自动发现功能

zabbix_conf_path=/etc/zabbix
redis_cli_path=/usr/local/bin/redis-cli
localhost=`ip address | egrep "global e|global dynamic e"| cut -d ' ' -f6 | cut -d '/' -f1`
redis_password=123456

yum install net-tools -y

#创建自动发现端口文件
cd $zabbix_conf_path

echo "#!/usr/bin/env python 
import os 
import json 
#import simplejson as json
t=os.popen(\"\"\"sudo netstat -tlpn |grep redis-server|grep 0.0.0.0|awk '{print $4}'|awk -F: '{print $2}' \"\"\") 
ports = [] 
for port in  t.readlines(): 
        r = os.path.basename(port.strip()) 
        ports += [{'{#REDISPORT}':r}] 
print json.dumps({'data':ports},sort_keys=True,indent=4,separators=(',',':'))
" > redis_port.py

 setenforce 0

#创建zabbix监控redis配置文件
cd $zabbix_conf_path/zabbix_agentd.d

echo "UserParameter=redis_stats[*],$redis_cli_path -h $localhost -a $redis_password -p \$1 info 2>/dev/null|grep \$2|cut -d : -f2

#自动发现
UserParameter=redis.discovery,python $zabbix_conf_path/redis_port.py

#自动发现慢查询日志
UserParameter=redis_slowlog_len_max[*],$redis_cli_path -h $localhost -a $redis_password -p \$1 CONFIG GET slowlog-max-len 2>/dev/null|sed -n 2p
UserParameter=redis_slowlog_len[*],$redis_cli_path -h $localhost -a $redis_password -p \$1 SLOWLOG LEN 2>/dev/null|cut -d : -f2
UserParameter=redis_slowlog_last[*],$redis_cli_path -h $localhost -a $redis_password -p \$1 SLOWLOG GET 1 2>/dev/null|xargs -l20
UserParameter=redis_slowlog_slower_than[*],$redis_cli_path -h $localhost -a $redis_password -p \$1 CONFIG GET slowlog-log-slower-than 2>/dev/null |sed -n 2p

#db0的keys数
UserParameter=redis_db0_keys[*],$redis_cli_path -h $localhost -a $redis_password -p \$1 info 2>/dev/null| grep db0 |cut -d '=' -f2 |cut -d ',' -f1
#db0有过期状态的键值数
UserParameter=redis_db0_expires[*],$redis_cli_path -h $localhost -a $redis_password -p \$1 info 2>/dev/null| grep db0 |cut -d '=' -f3 |cut -d ',' -f1
#抽样估算平均过期时间,如果无TTL键或在Slave则avg_ttl一直为0
UserParameter=redis_db0_avg_ttl[*],$redis_cli_path -h $localhost -a $redis_password -p \$1 info 2>/dev/null| grep db0 |cut -d '=' -f4

#client list(未测试自动化)
UserParameter=redis_client_list[*],$redis_cli_path -h $localhost -a $redis_password -p \$1 client list 2>/dev/null| awk '{\$\$4="";print \$\$0}' > /var/log/redis/redis_client_\$1.log
" > userparameter_redis.conf
