## VRRP协议介绍

http://bbs.nanjimao.com/thread-845-1-1.html
http://nanjimao.com/blog-uid-70.html

## keepalived + haproxy + httpd 安装

网络拓扑

haproxy0 Server: 10.0.0.70 ( eth0 )
haproxy1 Server: 10.0.0.71( eth0)
Virtual IP: 10.0.0.79


## 在LB haproxy0 节点上安装

	yum -y install -y haproxy keepalived psmisc httpd

Allow non-local Virtual IPs on all HAProxy nodes

	vi /etc/sysctl.conf
	net.ipv4.ip_nonlocal_bind = 1

禁用selinux

	vi /etc/sysconfig/selinux
	SELINUX=disabled

重启server

编辑keepalived 配置文件

	vi /etc/keepalived/keepalived.conf

	global_defs {
	  router_id haproxy0
	}
	vrrp_script haproxy {
	  script "killall -0 haproxy"
	  interval 2
	  weight 2
	}
	vrrp_instance 50 {
	  virtual_router_id 50
	  advert_int 1
	  priority 101
	  state MASTER
	  interface eth0
	  virtual_ipaddress {
	    10.0.0.79 dev eth0
	  }
	  track_script {
	    haproxy
	  }
	}

注意在centos7 上默认没有安装killall ，需要手动安装psmisc 包，不然haproxy 故障迁移会失效。

编辑haproxy 配置文件

	vi /etc/haproxy/haproxy.cfg

	global
		chroot /var/lib/haproxy
		user haproxy
		group haproxy
		daemon
		log 10.0.0.60 local0
		stats socket /var/lib/haproxy/stats
		maxconn 4000

	defaults
		log	global
		mode	http
		option	httplog
		option	dontlognull
	    contimeout 5000
	    clitimeout 50000
	    srvtimeout 50000
		errorfile 400 /etc/haproxy/errors/400.http
		errorfile 403 /etc/haproxy/errors/403.http
		errorfile 408 /etc/haproxy/errors/408.http
		errorfile 500 /etc/haproxy/errors/500.http
		errorfile 502 /etc/haproxy/errors/502.http
		errorfile 503 /etc/haproxy/errors/503.http
		errorfile 504 /etc/haproxy/errors/504.http

	listen stats 10.0.0.60:8080
	        mode http
	        stats enable
	        stats uri /stats
	        stats realm HAProxy\ Statistics
	        stats auth admin:password

	listen proxy *:80
	        option httpchk HEAD /index.html
	        server server1  10.0.0.70:8090 cookie server1 check inter 1500 rise 3 fall 3
	        server server2  10.0.0.71:8090 cookie server2 check inter 1500 rise 3 fall 3

设置启动调用初始化脚本

	vi /etc/default/haproxy
	# Set ENABLED to 1 if you want the init script to start haproxy.
	ENABLED=1


启动

	systemctl start keepalived 
	systemctl start haproxy
	systemctl enable haproxy
	systemctl enable keepalived


##在LB haproxy1 节点上安装

	yum -y install -y haproxy keepalived psmisc

Allow non-local Virtual IPs on all HAProxy nodes

	vi /etc/sysctl.conf
	net.ipv4.ip_nonlocal_bind = 1

立即生效

	sysctl -p

编辑keepalived 配置文件

	vi /etc/keepalived/keepalived.conf

	global_defs {
	  router_id haproxy1
	}
	vrrp_script haproxy {
	  script "killall -0 haproxy"
	  interval 2
	  weight 2
	}
	vrrp_instance 50 {
	  virtual_router_id 50
	  advert_int 1
	  priority 101
	  state MASTER
	  interface eth0
	  virtual_ipaddress {
	    10.0.0.79 dev eth0
	  }
	  track_script {
	    haproxy
	  }
	}

编辑haproxy 配置文件

	vi /etc/haproxy/haproxy.cfg

	global
		chroot /var/lib/haproxy
		user haproxy
		group haproxy
		daemon
		log 10.0.0.71 local0
		stats socket /var/lib/haproxy/stats
		maxconn 4000

	defaults
		log	global
		mode	http
		option	httplog
		option	dontlognull
	    contimeout 5000
	    clitimeout 50000
	    srvtimeout 50000
		errorfile 400 /etc/haproxy/errors/400.http
		errorfile 403 /etc/haproxy/errors/403.http
		errorfile 408 /etc/haproxy/errors/408.http
		errorfile 500 /etc/haproxy/errors/500.http
		errorfile 502 /etc/haproxy/errors/502.http
		errorfile 503 /etc/haproxy/errors/503.http
		errorfile 504 /etc/haproxy/errors/504.http

	listen stats 10.0.0.71:8080
	        mode http
	        stats enable
	        stats uri /stats
	        stats realm HAProxy\ Statistics
	        stats auth admin:password

	listen proxy *:80
	        option httpchk HEAD /index.html
	        server server1  10.0.0.70:8090 cookie server1 check inter 1500 rise 3 fall 3
	        server server2  10.0.0.71:8090 cookie server2 check inter 1500 rise 3 fall 3

设置启动调用初始化脚本

	vi /etc/default/haproxy
	# Set ENABLED to 1 if you want the init script to start haproxy.
	ENABLED=1

启动

	systemctl start keepalived 
	systemctl start haproxy
	systemctl enable haproxy
	systemctl enable keepalived

查看是否配置成功

	ip a|grep eth0

2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    inet 10.0.0.70/24 brd 10.0.0.255 scope global eth0
    inet 10.0.0.79/32 scope global eth0

浏览器访问 http://10.0.0.79:8080/stats 输入admin/password 登录查看haproxy 状态


##配置httpd 负载均衡


修改httpd 监听端口到8090

	vi /etc/httpd/conf/httpd.conf 
	Listen 8090

新建一个默认网页
	echo "node0" > /var/www/html/index.html




