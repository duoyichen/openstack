#!/bin/bash

result_path="result"
result_file_name="df"

#[ -f ${result_file_name}.txt ] && mv ${result_file_name}.txt ./${result_path}/${result_file_name}.txt.tmp`date +%Y%m%d%H%M%S` && echo "The old ${result_file_name}.txt mv to ${result_path} and The filename is ${result_file_name}.txt.tmp`date +%Y%m%d%H%M%S`"

if [ -f ${result_file_name}.txt ];then
  date=`date +%Y%m%d%H%M%S`
  mv ${result_file_name}.txt ./${result_path}/${result_file_name}.txt.tmp${date}
  echo "The old ${result_file_name}.txt mv to ${result_path} and The filename is ${result_file_name}.txt.tmp${date}"
fi

echo "" >> ${result_file_name}.txt;
echo "" >> ${result_file_name}.txt;
echo "--------------------------------" >> ${result_file_name}.txt;
echo "  Get Info On [${date}]" >> ${result_file_name}.txt;
echo "--------------------------------" >> ${result_file_name}.txt;
echo "" >> ${result_file_name}.txt;
echo "" >> ${result_file_name}.txt;

#for i in `seq 50 59`;
for i in `cat /etc/hosts|awk '/node-/ {print $3}'`;
  do
    echo "" >> ${result_file_name}.txt;
    echo "------------ $i ------------" >> ${result_file_name}.txt;
    ssh $i 'df -h|grep -vE "os-root|tmpfs|md0"' >> ${result_file_name}.txt;
    #ssh node-$i 'df -TH' >> ${result_file_name}.txt;
done

echo "" >> ${result_file_name}.txt;
echo "" >> ${result_file_name}.txt;
echo "--------------------------------" >> ${result_file_name}.txt;
echo "  Get Info On [${date}]" >> ${result_file_name}.txt;
echo "--------------------------------" >> ${result_file_name}.txt;
echo "" >> ${result_file_name}.txt;
echo "" >> ${result_file_name}.txt;

echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "-------------------------------- Result --------------------------------"
echo ""
echo ""
cat ${result_file_name}.txt
