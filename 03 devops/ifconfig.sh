#!/bin/bash

[ -f ifconfig.txt ] && mv ifconfig.txt ifconfig.txt.bak`date +%Y%m%d%H%M%S`

for j in `seq 50 59`
do
  echo "" >> ifconfig.txt
  echo "" >> ifconfig.txt
  echo "" >> ifconfig.txt
  echo "------------ Node-$j ------------" >> ifconfig.txt
  echo "" >> ifconfig.txt
  for i in ex storage clusternet fw-admin mgmt
    do
      echo "br-$i:" >> ifconfig.txt
      #ssh node-$j "ifconfig br-$i|awk '/inet/ {print $2}'|awk -F ":" '{print $2}'" >> ifconfig.txt
      ssh node-$j "ifconfig br-$i | grep 'inet addr:' | cut -d ':' -f 2 | cut -d ' ' -f 1" >> ifconfig.txt
      echo "" >> ifconfig.txt
  done
done

echo ""
echo ""
echo "-------------------------------- Result --------------------------------"
echo ""
echo ""
cat ifconfig.txt
