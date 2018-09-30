##MariaDB Cluster Installation


如果预先安装了mysql 需要卸载

	yum remove mysql-server 

安装galera
	yum install -y mariadb mariadb-galera-server mariadb-galera-common galera mariadb-client rsync

	systemctl start mariadb
	systemctl enable mariadb


配置galera

	vi /etc/my.cnf.d/galera.cnf 

	default-storage-engine=innodb
	wsrep_provider=/usr/lib64/galera/libgalera_smm.so
	wsrep_cluster_name="my_wsrep_cluster"
	wsrep_cluster_address="gcomm://10.0.0.70,10.0.0.60"
	wsrep_node_name=mariadb0
	wsrep_node_address=10.0.0.70
	wsrep_sst_method=rsync

注意如果不用ssl 同步必须要注释掉 wsrep_provider_options ，不然启动会失败


拷贝改配置文件到其他节点，并修改相应的hostname和ip

启动cluster

	/usr/libexec/mysqld --wsrep-new-cluster --user root &

初始化mariadb 设置root 密码为'root'

	mysql_secure_installation 

查看是否cluster 是否启动

	mysql -uroot -proot -e "show status like 'wsrep%'"

输出包含一下内容

	 wsrep_local_state_comment  | Synced  
	 wsrep_cluster_size         | 1
	 wsrep_ready                | ON  

接下来配置添加一个新的mysql 节点


拷贝/etc/my.cnf.d/galera.cnf  到其他节点

启动mariad
	systemctl start mariadb

再次查看输出，包含一下内容

	 wsrep_local_state_comment  | Synced  
	 wsrep_cluster_size         | 2
	 wsrep_ready                | ON  


##HAproxy 实现负载均衡

添加一个用于haproxy 做服务可用检查的用户 haproxy

	mysql -u root -p
	delete from mysql.user where user = '';
	insert into mysql.user (Host,User) values ('192.168.1.30','haproxy');
	insert into mysql.user (Host,User) values ('192.168.1.31','haproxy');
	flush privileges;
	exit

注意：这里添加用户需要重启所有mysql 节点方能实现同步。

在haproxy 配置文件后边添加 mysql 的section

在两个haproxy server 的配置文件中添加配置

	vi /etc/haproxy/haproxy.cfg 
	listen galera :3307
	        balance source
	        mode tcp
	        option tcpka
	        option mysql-check user haproxy
	        server MySQL1 10.0.0.70:3306 check weight 1
	        server MySQL2 10.0.0.71:3306 check weight 1

重启haproxy

	systemctl restart haproxy

登录 haproxy web 检查galera 部分的显示均为绿色

用mariadb-client 登录mysql 检查负载均衡是否生效

	mysql -uroot -proot -h10.0.0.79 -P3307

参考：
https://www.youtube.com/watch?v=axBl3Ku_6qs 


问题：
1. wsrep 是什么？
2.为什么第一个节点用 /usr/libexec/mysqld --wsrep-new-cluster --user root & 方式启动，而不是systemctl 方式？










