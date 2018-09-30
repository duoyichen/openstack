#!/bin/sh

result_path="result"
result_file_name="openstack-status"
date=`date +%Y%m%d%H%M%S`

#[ -f ${result_file_name}.txt ] && mv ${result_file_name}.txt ./${result_path}/${result_file_name}.txt.tmp`date +%Y%m%d%H%M%S` && echo "The old ${result_file_name}.txt mv to ${result_path} and The filename is ${result_file_name}.txt.tmp`date +%Y%m%d%H%M%S`"

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

for i in `seq 50 59`;
  do
    echo "" >> ${result_file_name}.txt;
    echo "------------ $i ------------" >> ${result_file_name}.txt;
    ssh node-$i 'openstack-status | grep -vE "active|disabled"' >> ${result_file_name}.txt;
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
