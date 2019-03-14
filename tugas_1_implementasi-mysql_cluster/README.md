# Implementation MySQL Cluster with Proxy Load Balancer
Mengimplementasikan MySQL Cluster dengan Proxy Load Balancer dengan Menggunakan 2 MySQL Server API, 2 MySQL Data Node, 1 MySQL Cluster Manager, dan 1 Proxy Load Balancer

## Menu Cepat
1. [Kebutuhan](#1-kebutuhan)
2. [Model Arsitektur](#2-model-arsitektur)
3. [Instalasi](#3-instalasi)
	- [Provisioning Clusterdb-1](#31-provisioning-clusterdb-1)
	- [Provisioning Clusterdb-2 dan Clusterdb-3](#32-provisioning-clusterdb-2-dan-clusterdb-3)
	- [Provisioning Clusterdb-4](#33-provisioning-clusterdb-4)
4. [Dokumentasi](#4-dokumentasi)
	- [Instalasi Cluster Manager](#41-instalasi-cluster-manager)
	- [Instalasi Data Node](#42-instalasi-data-node)
	- [Instalasi Service API](#43-instalasi-service-api)
	- [NDB Status & NDB_MGM Status](#44-ndb-status--ndb_mgm-status)
	- [SQL Manipulation Data](#45-sql-manipulation-data)
	- [SQL Manipulation Data when Some API OFF](#46-sql-manipulation-data-when-some-api-off)
	- [Load Balancer ProxySQL](#47-load-balancer-proxysql)
	- [ProxySQL with SQLYog](#48-proxysql-with-sqlyog)
5. [Referensi](#5-referensi)

## 1. Kebutuhan
- Vagrant
- Bento/ubuntu18.04
- MySQL Data Sample
- MySQL Remote Software (Pada kasus ini saya menggunakan SQLYog)

## 2. Model Arsitektur
Pada desain MySQL Cluster kali ini, saya menggunakan 4 Cluster, dengan informasi tiap clusternya:

| No | IP Address | Hostname | Deskripsi |
| --- | --- | --- | --- |
| 1 | 192.168.33.11 | clusterdb1 | Sebagai Node Manager |
| 2 | 192.168.33.12 | clusterdb2 | Sebagai Server 1 dan Node 1 |
| 3 | 192.168.33.13 | clusterdb3 | Sebagai Server 2 dan Node 2 |
| 4 | 192.168.33.14 | clusterdb4 | Sebagai Load Balancer (ProxySQL) |

## 3. Instalasi
1.  ``git clone `` https://github.com/ahmadkikok/bdt-mysql_cluster.git
2. Hapus folder ``.vagrant`` untuk menghapus konfigurasi VB sebelumnya.
3. Lakukan ``vagrant up`` dan lakukan ``vagrant ssh`` ditiap clusternya.

### 3.1 Provisioning Clusterdb-1
```
# Update repositories
sudo apt-get update

# Copy MySQL Cluster Manager
sudo cp '/vagrant/install/mysql-cluster-community-management-server_7.6.9-1ubuntu18.04_amd64.deb' '/home/vagrant/mysql-cluster-community-management-server_7.6.9-1ubuntu18.04_amd64.deb'

# Install MySQL Cluster
sudo dpkg -i mysql-cluster-community-management-server_7.6.9-1ubuntu18.04_amd64.deb

# Create Folder MySQL Cluster
sudo mkdir /var/lib/mysql-cluster

# Copy Config MySQL Cluster
sudo cp '/vagrant/files/clusterdb1/config.ini' '/var/lib/mysql-cluster/config.ini'

# Starting Manager
sudo ndb_mgmd -f /var/lib/mysql-cluster/config.ini

# Kill Service
sudo pkill -f ndb_mgmd

# Copy Service Configuration
sudo cp '/vagrant/files/clusterdb1/ndb_mgmd.service' '/etc/systemd/system/ndb_mgmd.service'

# Reload Service
sudo systemctl daemon-reload

# Enable Startup Manager
sudo systemctl enable ndb_mgmd

# Starting Service
sudo systemctl start ndb_mgmd

# Allow Firewall
sudo ufw allow from 192.168.33.12

sudo ufw allow from 192.168.33.13
```

Pada provisioning di ``clusterdb1`` ini,  vagrant akan otomatis melakukan proses instalasi MySQL Cluster Manager, service, serta allow firewall, yang kemudian nantinya akan menggunakan konfigurasi yang sudah disetting dengan konfigurasi :
```
[ndbd default]
# Options affecting ndbd processes on all data nodes:
NoOfReplicas=2  # Number of replicas
```

Konfigurasi ini adalah jumlah replikasi yang akan dilakukan
```
[ndb_mgmd]
# Management process options:
hostname=192.168.33.11 # Hostname of the manager
datadir=/var/lib/mysql-cluster  # Directory for the log files
```

Konfigurasi dimana Cluster Manager berada, pada kasus ini berada pada ``192.168.33.11`` (clusterdb1)
```
[ndbd]
hostname=192.168.33.12 # Hostname/IP of the first data node
NodeId=2            # Node ID for this data node
datadir=/usr/local/mysql/data   # Remote directory for the data files

[ndbd]
hostname=192.168.33.13 # Hostname/IP of the second data node
NodeId=3            # Node ID for this data node
datadir=/usr/local/mysql/data   # Remote directory for the data files
```

Konfigurasi ini adalah Data Node, saya menggunakan 2 Data Node dengan ID 2 dan ID 3 sebagai pembeda antar Nodenya.
```
[mysqld]
# SQL node options:
hostname=192.168.33.12 # In our case the MySQL server/client is on the same Droplet as the cluster manager

[mysqld]
# SQL node options:
hostname=192.168.33.13 # In our case the MySQL server/client is on the same Droplet as the cluster manager
```

Konfigurasi MySQL Server API berada, saya menggunakan 2 Server API yang bersamaan dengan lokasi Data Node.

### 3.2 Provisioning Clusterdb-2 dan Clusterdb-3
```
# Update repositories
sudo apt-get update

# Install Libraries Perl
sudo apt-get install libclass-methodmaker-perl libaio1 libmecab2

# Copy MySQL Data Node
sudo cp '/vagrant/install/mysql-cluster-community-data-node_7.6.9-1ubuntu18.04_amd64.deb' '/home/vagrant/mysql-cluster-community-data-node_7.6.9-1ubuntu18.04_amd64.deb'

# Install MySQL Data Node
sudo dpkg -i '/home/vagrant/mysql-cluster-community-data-node_7.6.9-1ubuntu18.04_amd64.deb'

# Copy MySQL Data Node Configuration
sudo cp '/vagrant/files/clusterdb2/my.cnf' '/etc/my.cnf'

# Create Folder Data Node
sudo mkdir -p /usr/local/mysql/data

# Starting Node
sudo ndbd

# Allow Firewall
sudo ufw allow from 192.168.33.11

sudo ufw allow from 192.168.33.13

sudo ufw allow from 192.168.33.14

# Kill Service Data Node
sudo pkill -f ndbd

# Copy Configuration Service Data Node
sudo cp '/vagrant/files/clusterdb2/ndbd.service' '/etc/systemd/system/ndbd.service'

# Reload Service
sudo systemctl daemon-reload

# Enable Startup Data Node Service
sudo systemctl enable ndbd

# Starting Data Node Service
sudo systemctl start ndbd
```

Pada provisioning ini, adalah proses instalasi data node dengan konfigurasi letak instalasi MySQL Cluster di ``my.cnf`` sebagai berikut:
```
[mysql_cluster]
# Options for NDB Cluster processes:
ndb-connectstring=192.168.33.11  # location of cluster manager
```

NDB akan mengkoneksikan data node ke MySQL Cluster yang berada pada alamat ``192.168.33.11``
```
# Installation MySQL API
# Get Download Files MySQL Server
sudo curl -OL https://dev.mysql.com/get/Downloads/MySQL-Cluster-7.6/mysql-cluster_7.6.9-1ubuntu18.04_amd64.deb-bundle.tar

# Create MySQL Server Installation Folder
sudo mkdir install

# Untar MySQL Requirements
sudo tar -xvf mysql-cluster_7.6.9-1ubuntu18.04_amd64.deb-bundle.tar -C install/

# Install MySQL Common
sudo dpkg -i '/home/vagrant/install/mysql-common_7.6.9-1ubuntu18.04_amd64.deb'

# Install MySQL Cluster Client
sudo dpkg -i '/home/vagrant/install/mysql-cluster-community-client_7.6.9-1ubuntu18.04_amd64.deb'

# Install MySQL Client
sudo dpkg -i '/home/vagrant/install/mysql-client_7.6.9-1ubuntu18.04_amd64.deb'

# Install MySQL Server
#sudo dpkg -i '/home/vagrant/install/mysql-cluster-community-server_7.6.9-1ubuntu18.04_amd64.deb'

# Copy Configuration MySQL Server
#sudo cp '/vagrant/files/clusterdb2/mysql/my.cnf' '/etc/mysql/my.cnf'

# Restarting MySQL Service
#sudo systemctl restart mysql

# Enable Startup MySQL Service
#sudo systemctl enable mysql
```

Pada provisioning ini adalah proses instalasi MySQL Server API, dikarenakan pada ``clusterdb2 dan clusterdb3`` Data Node berperan sebagai MySQL Server API juga.
Selanjutnya adalah menjalan script berikut pada ``clusterdb2``:
```
# Install MySQL Server
sudo dpkg -i '/home/vagrant/install/mysql-cluster-community-server_7.6.9-1ubuntu18.04_amd64.deb'
sudo cp '/vagrant/files/clusterdb2/mysql/my.cnf' '/etc/mysql/my.cnf'
sudo systemctl restart mysql
sudo systemctl enable mysql
```

Pada script diatas adalah instalasi MySQL Server serta enable service pada saat startup vagrant, konfigurasi MySQL tidak berbeda jauh dengan konfigurasi Data Node:
```
[mysqld]
# Options for mysqld process:
ndbcluster                      # run NDB storage engine
bind-address=192.168.33.12

[mysql_cluster]
# Options for NDB Cluster processes:
ndb-connectstring=192.168.33.11  # location of management server
```

Yaitu lokasi service MySQL Server API yang berjalan pada ``192.168.33.12`` serta MySQL Cluster yang berjalan pada ``192.168.33.11``

### 3.3 Provisioning Clusterdb-4
```
# Install Proxy
sudo apt-get update

sudo cd /tmp

sudo curl -OL https://github.com/sysown/proxysql/releases/download/v2.0.2/proxysql_2.0.2-dbg-ubuntu18_amd64.deb

sudo dpkg -i proxysql_*

sudo rm proxysql_*

# Install MySQL Client
sudo apt-get install mysql-client -y

# Allow Port Proxy
sudo ufw allow 33061

sudo ufw allow 3306

# Allow Firewall
sudo ufw allow from 192.168.33.12

sudo ufw allow from 192.168.33.13

sudo ufw allow from 192.168.33.14

# Enable and Start Service
sudo systemctl enable proxysql

sudo systemctl start proxysql
```

Pada script ini adalah proses instalasi ProxySQL, Instalasi MySQL Client, serta allow firewall
```
# Export Files Configuration to ProxySQL
#sudo mysql -u admin -p -h 127.0.0.1 -P 6032 --prompt='ProxySQLAdmin> ' < /vagrant/mysql-dump/proxy_config.sql
```

Pada script ini adalah proses konfigurasi ProxySQL dengan konfigurasi pada ``proxy_config.sql``:
```
# Mengganti Password Admin default menjadi bdt2019 dan melakukan reload
UPDATE global_variables SET variable_value='admin:bdt2019' WHERE variable_name='admin-admin_credentials';
LOAD ADMIN VARIABLES TO RUNTIME;
SAVE ADMIN VARIABLES TO DISK;

# Melakukan Set value monitor pada mysql-monitor dan melakukan reload
UPDATE global_variables SET variable_value='monitor' WHERE variable_name='mysql-monitor_username';
LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;

# Melakukan insert data node, yaitu node 192.168.33.12 dan 192.168.33.13 dengan port 3306(MySQL) yang kemudian direload
INSERT INTO mysql_group_replication_hostgroups (writer_hostgroup, backup_writer_hostgroup, reader_hostgroup, offline_hostgroup, active, max_writers, writer_is_also_reader, max_transactions_behind) VALUES (2, 4, 3, 1, 1, 3, 1, 100);
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (2, '192.168.33.12', 3306);
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (2, '192.168.33.13', 3306);
LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;

# Melakukan insert username dan password untuk mengakses node yang telah disetting
INSERT INTO mysql_users(username, password, default_hostgroup) VALUES ('bdt', 'bdt2019', 2);
LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;
```

Pada kasus ini, username ``bdt`` mampu mengakses hostgroup_id 2, yaitu Node ``192.168.33.12`` dan ``192.168.33.13``, apabila tidak didefine, maka proxy tidak akan berjalan.
```
# Run This On Clusterdb2/3
# Download Files Addition SYS
#curl -OL https://gist.github.com/lefred/77ddbde301c72535381ae7af9f968322/raw/5e40b03333a3c148b78aa348fd2cd5b5dbb36e4d/addition_to_sys.sql

# Run This On Clusterdb2/3
# Export Files Addition
#sudo mysql -u root -p < addition_to_sys.sql

# Run This On Clusterdb2/3
# Export Files Proxy Connect Configuration
#sudo mysql -u root -p < /vagrant/mysql-dump/proxy_config_connection.sql
```

Konfigurasi pada ``proxy_config_connection.sql``:
```
# Membuat user monitor default memonitoring proxysql
CREATE USER 'monitor'@'%' IDENTIFIED BY 'bdt2019';
GRANT SELECT on sys.* to 'monitor'@'%';
FLUSH PRIVILEGES;

# Membuat user bdt yang digunakan untuk memanipulasi data melalui data node yang telah di set pada proxysql
CREATE USER 'bdt'@'%' IDENTIFIED BY 'bdt2019';
GRANT ALL PRIVILEGES on user.* to 'bdt'@'%';
FLUSH PRIVILEGES;
```

User ``bdt`` berfungsi sebagai user yang mampu mengakses penuh database user, dan pada proxysql telah dilakukan konfigurasi bahwa user ``bdt`` mampu memanipulasi data yang berada di node ``192.168.33.12`` dan ``192.168.33.13``.

4. Lakukan poin 3.2 pada ``clusterdb3``, perbedaan hanya pada konfigurasi alamat address.
5. Jalankan script berikut pada ``clusterdb2`` atau ``clusterdb3``
```
# Melakukan Import proxy_config_connection.sql
sudo mysql -u root -p < /vagrant/mysql-dump/mysqlsampledatabase.sql
```

Melakukan import MySQL sample database yang nantinya akan digunakan untuk proses uji coba.

6. Jalankan script pada ``clusterdb4``
```
# Melakukan Import Proxy_Config.SQL
sudo mysql -u admin -p -h 127.0.0.1 -P 6032 --prompt='ProxySQLAdmin> ' < /vagrant/mysql-dump/proxy_config.sql
```

Dan script berikut pada ``clusterdb2`` dan ``clusterdb3``:
```
# Mengunduh addition_to_sys.sql
curl -OL https://gist.github.com/lefred/77ddbde301c72535381ae7af9f968322/raw/5e40b03333a3c148b78aa348fd2cd5b5dbb36e4d/addition_to_sys.sql

# Melakukan Import addition_to_sys.sql
sudo mysql -u root -p < addition_to_sys.sql

# Melakukan Import proxy_config_connection.sql
sudo mysql -u root -p < /vagrant/mysql-dump/proxy_config_connection.sql
```

Script diatas berisi konfigurasi user yang akan digunakan nantinya serta konfigurasi proxy yang telah disediakan oleh proxySQL.

7. Proses instalasi selesai, selanjutnya adalah Dokumentasi penggunaan MySQL Cluster dengan Proxy Load Balancer

## 4. Dokumentasi
### 4.1 Instalasi Cluster Manager
![](/tugas_1_implementasi-mysql_cluster/screenshoot/ndb_manager_status.PNG)

Cluster Manager Pada Clusterdb1.

### 4.2 Instalasi Data Node
![](/tugas_1_implementasi-mysql_cluster/screenshoot/node_id_2_status.PNG)

Data Node 1 Pada Clusterdb2.

![](/tugas_1_implementasi-mysql_cluster/screenshoot/node_id_3_status.PNG)

Data Node 2 Pada Clusterdb3.

### 4.3 Instalasi Service API
![](/tugas_1_implementasi-mysql_cluster/screenshoot/mysqld_cluster3_status.PNG)

Service MySQL Pada clusterdb3.

![](/tugas_1_implementasi-mysql_cluster/screenshoot/mysqld_cluster2_status.PNG)

Service MySQL Pada clusterdb2.

### 4.4 NDB Status & NDB_MGM Status
![](/tugas_1_implementasi-mysql_cluster/screenshoot/mysqld_ndb_cluster2_status.PNG)

Status running NDB pada Cluster2.

![](/tugas_1_implementasi-mysql_cluster/screenshoot/mysqld_ndb_cluster3_status.PNG)

Status running NDB pada Cluster3.

![](/tugas_1_implementasi-mysql_cluster/screenshoot/ndb_mgm_cluster2_status.PNG)

Informasi Cluster pada ndb_mgm Clusterdb2.

![](/tugas_1_implementasi-mysql_cluster/screenshoot/ndb_mgm_cluster3_status.PNG)

Informasi Cluster pada ndb_mgm Clusterdb3.

### 4.5 SQL Manipulation Data
![](/tugas_1_implementasi-mysql_cluster/screenshoot/info_1_cluster2-insertdumpsql.PNG)
![](/tugas_1_implementasi-mysql_cluster/screenshoot/info_2_cluster3-showtablesafterinsert.PNG)

Melakukan import mysqlsampledatabase.sql pada ``clusterdb2``.

![](/tugas_1_implementasi-mysql_cluster/screenshoot/info_3_cluster2-selectpayment114.PNG)

Melakukan select customer yang memiliki nomor ``114`` pada ``clusterdb2``.

![](/tugas_1_implementasi-mysql_cluster/screenshoot/info_4_cluster2-delete114nr27552.PNG)

Melakukan delete data customer nomor ``114`` yang memiliki nomor check ``NR27552`` pada ``clusterdb2``.

![](/tugas_1_implementasi-mysql_cluster/screenshoot/info_5_cluster3-datachanges.PNG)

Data pada ``clusterdb3`` ikut berubah sesuai dengan ``clusterdb2``.

### 4.6 SQL Manipulation Data when Some API OFF
![](/tugas_1_implementasi-mysql_cluster/screenshoot/info_6_cluster3-someapioff.PNG)

Memastikan salah satu service telah dimatikan.

![](/tugas_1_implementasi-mysql_cluster/screenshoot/info_7_cluster3-deletedata.PNG)

Melakukan delete data customer nomor ``114`` yang memiliki nomor check ``GG31455`` pada ``clusterdb3``.

![](/tugas_1_implementasi-mysql_cluster/screenshoot/info_8_cluster2-dataonnode2whensomeapioff.PNG)

Data pada ``clusterdb2`` ikut berubah sesuai dengan ``clusterdb3``.

### 4.7 Load Balancer ProxySQL
![](/tugas_1_implementasi-mysql_cluster/screenshoot/cluster4_proxyon.PNG)

Proxy Server pada Clusterdb4.

![](/tugas_1_implementasi-mysql_cluster/screenshoot/proxy_running_status.PNG)

Proxy Status, 2 Hostname ONLINE, yaitu pada ``clusterdb2`` dan ``clusterdb3``.

![](/tugas_1_implementasi-mysql_cluster/screenshoot/proxy_running_status-someapioff.PNG)

Ketika ``clusterdb2`` dimatikan, maka status akan berubah menjadi SHUNNED.

![](/tugas_1_implementasi-mysql_cluster/screenshoot/proxy_hostname_status-someapioff.PNG)

Hostname yang dipakai adalah hostname yang status ONLINE secara random, dikarenakan ``clusterdb2`` sedang dimatikan, sehingga default hostname adalah ``clusterdb3``.

### 4.8 ProxySQL with SQLYog
![](/tugas_1_implementasi-mysql_cluster/screenshoot/sqlyog_running.PNG)

Proxy berjalan pada hostname ``clusterdb3``.

![](/tugas_1_implementasi-mysql_cluster/screenshoot/sqlyog_insertdata.PNG)

Melakukan penambahan data office melalui SQLYog dengan menggunakan ProxySQL yang mengarah ke hostname ``clusterdb3``.

![](/tugas_1_implementasi-mysql_cluster/screenshoot/sqlyog_result_clusterdb3.PNG)

Data pada ``clusterdb3`` ikut bertambah sesuai dengan yang ditambahkan melalui SQLYog.

![](/tugas_1_implementasi-mysql_cluster/screenshoot/sqlyog_result_clusterdb2.PNG)

Data pada ``clusterdb2`` ikut bertambah sesuai dengan yang ditambahkan melalui SQLYog.

## 5. Referensi
https://www.digitalocean.com/community/tutorials/how-to-create-a-multi-node-mysql-cluster-on-ubuntu-18-04
https://www.digitalocean.com/community/tutorials/how-to-use-proxysql-as-a-load-balancer-for-mysql-on-ubuntu-16-04