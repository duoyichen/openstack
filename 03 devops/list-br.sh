#!/bin/bash

for j in `seq 50 59`
do
  echo "" >> list-br.txt
  echo "------ Node-$j ------" >> list-br.txt
#  for i in `seq 0 5`
#    do
      ssh node-$j "ovs-vsctl list-br" >> list-br.txt
#  done
done
echo ""
echo ""
echo "---------------- Result ----------------"
echo ""
echo ""
cat list-br.txt
