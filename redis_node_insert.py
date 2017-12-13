#!/usr/bin/env python

import redis
r = redis.Redis(host='192.168.100.191',port=6380,db=0)
r.set('liutao1','1')
print r.get('liutao1')
