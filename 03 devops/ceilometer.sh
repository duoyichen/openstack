#!/bin/sh

result_path="result"
result_file_name="ceilometer-status-test"
date=`date +%Y%m%d%H%M%S`

if [ -f ${result_file_name}.txt ];then
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

for j in `seq 51 53`;
  do
    echo "" >> ${result_file_name}.txt;
    echo "" >> ${result_file_name}.txt;
    echo "------------ $j ------------" >> ${result_file_name}.txt;
    echo "" >> ${result_file_name}.txt;

    svc=`chkconfig --list|grep ceil|grep 3:on|cut -d '0' -f 1`
    for i in $svc;
      do
        #echo "" >> ${result_file_name}.txt;
        #echo "$i status: " >> ${result_file_name}.txt;
        ssh node-$j "service $i status" >> ${result_file_name}.txt;
      done
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
