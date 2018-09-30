#!/bin/bash

for j in `seq 50 59`
do
  echo "" >> ethx_10g.txt
  echo "------ Node-$j ------" >> ethx_10g.txt
  for i in `seq 0 5`
    do
      ssh node-$j "ethtool eth$i |grep 10000 >> /dev/null && echo "eth$i is 10G"" >> ethx_10g.txt
  done
done
echo ""
echo ""
echo "---------------- Result ----------------"
echo ""
echo ""
cat ethx_10g.txt
