#!/bin/sh

node="node-51"
destination_directory="/root/rpm2"
loal_directory="/root/rpm"

echo "Test Destination Directory..."
ssh ${node} "if [ ! -f ${result_file_name}.txt ];then mkdir -p ${destination_directory};fi"
if [ $? == 0 ];then echo "Destination Directory is OK!";else echo "Destination Directory not exist!";fi
echo ""

echo "Copy files..."
scp ${loal_directory}/*.rpm ${node}:${destination_directory}
if [ $? == 0 ];then echo "Copy Finished";else echo "Copy Failed,Please check it!";fi
echo ""

echo "Installing RPMs,Please waiting,waiting,and waiting......"
ssh ${node} "cd ${destination_directory};rpm -ivh *.rpm"
echo "......"
if [ $? == 0 ];then echo "Install Finished!";else echo "Install Failed,Please check it!";fi
echo ""
