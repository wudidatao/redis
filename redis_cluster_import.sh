import将外部redis数据导入集群


import命令可以把外部的redis节点数据导入集群。导入的流程如下：

1、通过load_cluster_info_from_node方法转载集群信息，check_cluster方法检查集群是否健康。
2、连接外部redis节点，如果外部节点开启了cluster_enabled，则提示错误。
3、通过scan命令遍历外部节点，一次获取1000条数据。
4、遍历这些key，计算出key对应的slot。
5、执行migrate命令,源节点是外部节点,目的节点是集群slot对应的节点，如果设置了--copy参数，则传递copy参数，如果设置了--replace，则传递replace参数。
6、不停执行scan命令，直到遍历完全部的key。
7、至此完成整个迁移流程
这中间如果出现异常，程序就会停止。没使用--copy模式，则可以重新执行import命令，使用--copy的话，最好清空新的集群再导入一次。

import命令更适合离线的把外部redis数据导入，在线导入的话最好使用更专业的导入工具，以slave的方式连接redis节点去同步节点数据应该是更好的方式。
下面是一个例子
./redis-trib.rb import --from 10.0.10.1:6379 10.10.10.1:7000
上面的命令是把 10.0.10.1:6379（redis 2.8）上的数据导入到 10.10.10.1:7000这个节点所在的集群

两个集群之间的节点导入，亲测，不行，以下是报错，关闭了安全模式，都用的主节点，也不行，以上资料第二条也说明，集群模式无法导入
Migrating liutao45879 to 192.168.100.190:6381: ERR Syntax error, try CLIENT (LIST | KILL | GETNAME | SETNAME | PAUSE | REPLY)
Migrating liutao85343 to 192.168.100.190:6381: ERR Syntax error, try CLIENT (LIST | KILL | GETNAME | SETNAME | PAUSE | REPLY)
Migrating liutao38391 to 192.168.100.190:6381: ERR Syntax error, try CLIENT (LIST | KILL | GETNAME | SETNAME | PAUSE | REPLY)
Migrating liutao43118 to 192.168.100.190:6381: ERR Syntax error, try CLIENT (LIST | KILL | GETNAME | SETNAME | PAUSE | REPLY)
Migrating liutao63564 to 192.168.100.190:6381: ERR Syntax error, try CLIENT (LIST | KILL | GETNAME | SETNAME | PAUSE | REPLY)
Migrating liutao25204 to 192.168.100.190:6381: ERR Syntax error, try CLIENT (LIST | KILL | GETNAME | SETNAME | PAUSE | REPLY)
Migrating liutao77760 to 192.168.100.190:6381: ERR Syntax error, try CLIENT (LIST | KILL | GETNAME | SETNAME | PAUSE | REPLY)
