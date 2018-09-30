##RabbitMQ Cluster Installation

网络拓扑

	rabbitmq0 Server: 10.0.0.70 ( eth0 )
	rabbitmq1 Server: 10.0.0.71( eth0)

安装rabbitmq 的包

	yum install -y rabbitmq-server

启动一下rabbitmq 生成coolik

	systemctl start rabbit-server
	systemctl stop rabbit-server

拷贝生成的coolik到其他节点

	scp /var/lib/rabbitmq/.erlang.cookie root@10.0.0.71:/var/lib/rabbitmq/.erlang.cookie

修改每个节点cookie 文件的权限，直接拷贝只有root权限，启动会失败

	chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie
	chmod 400 /var/lib/rabbitmq/.erlang.cookie

启动rabbitmq0

	systemctl start rabbit-server

在rabbitmq1 上执行如下命令

	rabbitmqctl stop_app
	rabbitmqctl join_cluster rabbit@mariadb0
	rabbitmqctl start_app
	rabbitmqctl cluster_status

输出如下内容说明cluster 创建成功

Cluster status of node rabbit@mariadb1 ...
[{nodes,[{disc,[rabbit@rabbitmq0,rabbit@rabbitmq1]}]},
 {running_nodes,[rabbit@rabbitmq0,rabbit@rabbitmq1]},
 {cluster_name,<<"rabbit@mariadb1">>},
 {partitions,[]}]
...done.

The final step for setting up the cluster is to create a policy that instructs RabbitMQ to use mirrored queues. In normal operation, queues are not mirrored across cluster nodes. Enabling mirrored queues allows producers and consumers to connect to any of the RabbitMQ brokers and access the same message queues.

不确定是否一定需要执行这个命令，有待研究。

	rabbitmqctl set_policy HA '^(?!amq\.).*' '{"ha-mode": "all"}'

修改guest 用户密码

	rabbitmqctl change_password guest openstack


##HAproxy 做负载均衡

在HAproxy 配置文件里添加如下配置

	vi /etc/haproxy/haproxy.cfg

	listen  rebbitmq :5673
	        mode    tcp
	        balance roundrobin
	        stats enable
	        option  forwardfor
	        option  tcpka
	        server  rabbitmq0 10.0.0.70:5672 check inter 5000
	        server  rabbitmq1 10.0.0.71:5672 check inter 5000

依此重启HAproxy

	systemctl restart haproxy

登录web 检查 HAproxy 发现的server 状态是否正常


写个Python 脚本测试rabbitmq LB 是否可用

	vi sent.py

	#!/usr/bin/env python
	import pika
	credentials = pika.PlainCredentials('guest', 'openstack')
	connection = pika.BlockingConnection(pika.ConnectionParameters(
	              '10.0.0.79',5673,"/",credentials))
	channel = connection.channel()
	channel.queue_declare(queue='hello2')
	def callback(ch, method, properties, body):
	   print " [x] Received %r" % (body,)
	channel.basic_consume(callback,
	                     queue='hello2',
	                     no_ack=True)
	print ' [*] Waiting for messages. To exit press CTRL+C'
	channel.start_consuming()

	vi reseve.py
	#!/usr/bin/env python
	import pika
	credentials = pika.PlainCredentials('guest', 'openstack')
	connection = pika.BlockingConnection(pika.ConnectionParameters(
	              '10.0.0.79',5673,"/",credentials))
	channel = connection.channel()
	channel.queue_declare(queue='hello')
	def callback(ch, method, properties, body):
	   print " [x] Received %r" % (body,)
	channel.basic_consume(callback,
	                     queue='hello',
	                     no_ack=True)
	print ' [*] Waiting for messages. To exit press CTRL+C'
	channel.start_consuming()


查看两个rabbitmq node 是否同步


参考：

http://blog.flux7.com/blogs/tutorials/how-to-creating-highly-available-message-queues-using-rabbitmq

https://openstack.redhat.com/RabbitMQ