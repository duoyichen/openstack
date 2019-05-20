Ceph 部署文档







环境：

| 节点      | 角色             | IP地址       |
| :-------- | :--------------- | :----------- |
| control01 | ceph-deploy      | 10.10.100.60 |
| compute01 | osd.0, mon.node0 | 10.10.100.61 |
| compute02 | osd.1, mon.node1 | 10.10.100.62 |
| compute03 | osd.2, mon.node2 | 10.10.100.63 |





下面，来进行初始化配置。以下6步操作，每个ceph节点上都要执行。



1. 配置epel源与ceph源，本文档采用本地yum源，每个ceph节点上都要配：

   ```
   curl -o /etc/yum.repos.d/ceph.repo --progress-bar \
       http://10.10.100.10/o/yum/ceph-nautilus.repo
   yum clean all
   yum makecache
   ```



2. 更新系统，并重启

   ```
   yum update -y
   reboot
   ```



3. 安装并配置时间同步服务：

   ```
   yum install -y ntp ntpdate ntp-doc
   ```



4. 安装 SSH 服务：

   ```
   yum install -y openssh-server
   ```



5. 创建一个用户并配置sudo权限，用来部署ceph服务，本文档直接使用root，可以跳过：

   ```
   useradd -d /home/{username} -m {username}
   passwd {username}
   
   echo "{username} ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/{username}
   chmod 0440 /etc/sudoers.d/{username}
   
   echo "root ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/root
   chmod 0440 /etc/sudoers.d/root
   
   以下实际上只需要修改三个ceph集群节点即可
   sudo visudo
   将 Defaults requiretty 修改为： 
   Defaults:root !requiretty
   
   sed -i '/Defaults    requiretty/a\
   Defaults:root !requiretty' /etc/sudoers
   sed -i 's/Defaults    requiretty/\
   #Defaults    requiretty/' /etc/sudoers
   ```



6. Firewall 开放服务端口及SeLinux设置

   ```
   firewall-cmd --zone=public --add-service=ceph-mon --permanent
   firewall-cmd --zone=public --add-service=ceph --permanent
   firewall-cmd --reload
   
   setenforce 0
   ```



7. 主机名 IP 解析

   ```
   cat /etc/hosts
   127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
   ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
   10.10.100.64       compute04
   10.10.100.63       compute03
   10.10.100.62       compute02
   10.10.100.61       compute01
   10.10.100.60       control01
   ```



8. 在 ceph-deploy 节点上生成密钥，并分发到每个ceph节点

   ```
   ssh-keygen    # 一路回车即可
   
   ssh-copy-id root@control01
   ssh-copy-id root@compute01
   ssh-copy-id root@compute02
   ssh-copy-id root@compute03
   ssh-copy-id root@compute04
   ```
   
   ssh 登录一下每个节点，要不 ceph-deploy 的时候要手动输入 yes 。



9. 在 ceph-deploy 节点上

   ```
   tee ~/.ssh/config << endof
   Host control01
       Hostname control01
           User root
   Host compute01
       Hostname compute01
           User root
   Host compute02
       Hostname compute02
           User root
   Host compute03
       Hostname compute03
           User root
   endof
   ```



10. 在 ceph-deploy 节点上安装ceph-deploy

    ```
    yum install -y ceph-deploy
    ```



11. 创建集群配置文件目录，注意，要在该路径下进行 ceph-deploy 部署

    ```
    mkdir /root/my-cluster
    cd /root/my-cluster
    ```



12. 创建集群

    ```
    ceph-deploy new compute01 compute02 compute03
    ```

    这里 new 后面是 mon 节点主机名，这里部署3个 mon 节点。执行完后，会在当前目录生成如下文件：
    
    ```
    [root@control01 my-cluster]# ls
    ceph.conf  ceph.log  ceph.mon.keyring
    ```
    
    ImportError: No module named pkg_resources
    
    yum install -y python2-pip



13. 修改ceph集群的网络

    在 ceph.conf  的 [global] 下添加如下:

    ```
    tee -a ceph.conf <<endof
    osd pool default size = 2
    public network = 10.10.100.0/24
    cluster network = 172.19.33.0/24
    endof
    ```



14. 安装ceph相关包

    ```
    ceph-deploy install --no-adjust-repos compute01 compute02 compute03
    ```

    --release nautilus  安装指定版本

    --no-adjust-repos  不修改 repo 文件。

    如果是重新安装，执行以下命令，以清除数据：
    
    ```
    ceph-deploy purge compute01 compute02 compute03
    ceph-deploy purgedata  compute01 compute02 compute03
    ceph-deploy forgetkeys
    rm -rf ceph*
    
    /usr/sbin/ceph-volume --cluster ceph lvm zap --destroy /dev/vdb
    ```



15. 初始化 monitor

    ```
    ceph-deploy mon create-initial
    ```



16. 生成如下文件

    ```
    [root@compute04 my-cluster]# ll
    total 220
    -rw------- 1 root root    113 May 19 03:38 ceph.bootstrap-mds.keyring
    -rw------- 1 root root    113 May 19 03:38 ceph.bootstrap-mgr.keyring
    -rw------- 1 root root    113 May 19 03:38 ceph.bootstrap-osd.keyring
    -rw------- 1 root root    113 May 19 03:38 ceph.bootstrap-rgw.keyring
    -rw------- 1 root root    151 May 19 03:38 ceph.client.admin.keyring
    -rw-r--r-- 1 root root    338 May 19 02:56 ceph.conf
    -rw-r--r-- 1 root root 178735 May 19 03:38 ceph-deploy-ceph.log
    -rw------- 1 root root     73 May 19 02:49 ceph.mon.keyring
    ```



17. 分发 keyring 到每个ceph节点

    ```
    ceph-deploy admin compute01 compute02 compute03
    ```



18. 部署一个 manager daemon

    ```
    ceph-deploy mgr create compute01
    ```



19. 添加 OSDs

    ```
    ceph-deploy osd create --data /dev/vdb compute01
    ceph-deploy osd create --data /dev/vdb compute02
    ceph-deploy osd create --data /dev/vdb compute03
    ```

    假设每台节点有块未使用的 /dev/vdb 盘作为 osd 盘。
    
    添加journal盘接口如下：
    
    ```
    ceph-deploy osd create {ceph-node} --journal {/dev/sdx}
    ```



20. 集群健康检查

    ```
    ssh compute01 ceph health
    ```

    正常情况会返回 HEALTH_OK 。



21. INSTALL CEPH

    ```
    ceph-deploy install --no-adjust-repos control01
    
    ceph-deploy admin control01
    
    chmod +r /etc/ceph/ceph.client.admin.keyring
    ```



22. 在 ceph-deploy 节点上修改了集群的配置文件，可以通过如下命令同步到各个节点：

    ```
    ceph-deploy --overwrite-conf admin compute01 compute02 compute03
    ```

    

22. ADD A METADATA SERVER

    ```
    ceph-deploy mds create compute01
    ```



23. ADDING MONITORS

    ```
    ceph-deploy mon add control01
    ```

    检查 quorum status

    ```
    ceph quorum_status --format json-pretty
    ```



24. ADDING MANAGERS

    ```
    ceph-deploy mgr create control01
    
    检查集群状态
    ssh compute01 ceph -s
    ```



25. ADD AN RGW INSTANCE

    ```
    ceph-deploy rgw create compute01
    
    tee -a ceph.conf <<endof
    
    [client]
    rgw frontends = civetweb port=80
    endof
    ```



26. 

