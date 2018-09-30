#!/bin/bash

basedir="/root/backup"
#for j in keystone glance nova cinder ceilometer ceph
for j in keystone glance ceilometer
do
  for i in `seq 50 59`
    do
      [ -d "$basedir/$j" ] || mkdir -p $basedir/$j
      scp node-$i:/etc/$j/$j.conf node-51:$basedir/$j/$j.conf_node-$i && echo "node-$i Successful" || echo "node-$i Failed"
  done
done
