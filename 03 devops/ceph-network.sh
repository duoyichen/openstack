#!/bin/bash

[ -f ceph-network.txt ] && mv ceph-network.txt ceph-network.txt.tmp`date +%Y%m%d%H%M%S`

for i in `seq 50 59`;
  do
    echo "" >> ceph-network.txt;
    echo "------------ $i ------------" >> ceph-network.txt;
    ssh node-$i 'cat /etc/ceph/ceph.conf|grep -E "mon_host|public_network|cluster_network"' >> ceph-network.txt;


echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "-------------------------------- Result --------------------------------"
echo ""
echo ""
cat ceph-network.txt

done
