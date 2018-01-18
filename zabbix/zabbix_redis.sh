#!/bin/bash

#配置zabbix的redis监控参数和自动发现功能

zabbix_conf_path=/etc/zabbix
redis_cli_path=/usr/local/bin/redis-cli
localhost=`ip address | egrep "global e|global dynamic e"| cut -d ' ' -f6 | cut -d '/' -f1`
redis_password=123456

yum install net-tools -y

#创建自动发现端口文件
cd $zabbix_conf_path

echo "
#!/usr/bin/env python 
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

echo "UserParameter=redis_stats[*],$redis_cli_path -h $localhost -a $redis_password -p \$1 info|grep \$2|cut -d : -f2

#自动发现
UserParameter=redis.discovery,$zabbix_conf_path/redis_port.py

#自动发现慢查询日志
UserParameter=redis_slowlog_len_max[*],$redis_cli_path -h $localhost -a $redis_password -p \$1 CONFIG GET slowlog-max-len |sed -n 2p
UserParameter=redis_slowlog_len[*],$redis_cli_path -h $localhost -a $redis_password -p \$1 SLOWLOG LEN |cut -d : -f2
UserParameter=redis_slowlog_last[*],$redis_cli_path -h $localhost -a $redis_password -p \$1 SLOWLOG GET 1 |cut -d : -f2|xargs -l7
UserParameter=redis_slowlog_slower_than[*],$redis_cli_path -h $localhost -a $redis_password -p \$1 CONFIG GET slowlog-log-slower-than |sed -n 2p

#当前keys数
UserParameter=redis_db0_keys[*],$redis_cli_path -h $localhost -a $redis_password -p \$1 info | grep db0 |cut -d '=' -f2 |cut -d ',' -f1
" > userparameter_redis.conf
