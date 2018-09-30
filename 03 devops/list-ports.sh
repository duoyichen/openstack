#!/bin/bash

[ -f list-ports.txt ] && mv list-ports.txt list-ports.txt.0

for j in `seq 50 61`
do
  echo "" >> list-ports.txt
  echo "" >> list-ports.txt
  echo "" >> list-ports.txt
  echo "------------ Node-$j ------------" >> list-ports.txt
  echo "" >> list-ports.txt
  for i in `seq 0 5`
    do
      echo "br-eth$i:" >> list-ports.txt
      ssh node-$j "ovs-vsctl list-ports br-eth$i" >> list-ports.txt
      echo "" >> list-ports.txt
  done
done

echo ""
echo ""
echo "---------------- Result ----------------"
echo ""
echo ""
cat list-ports.txt
