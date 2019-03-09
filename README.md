# Implementation MySQL Cluster with Proxy Load Balancer
Mengimplementasikan MySQL Cluster dengan Proxy Load Balancer, sebelum mengimplementasikan, ada beberapa hal yang harus diperhatikan :

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
Install MySQL Server
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

### 3.2 Provisioning Clusterdb-4
```

```

4. Lakukan poin 3.2 pada ``clusterdb3``, perbedaan hanya pada konfigurasi alamat address.
5. Jalankan script pada ``clusterdb2`` atau ``clusterdb3``
```
sudo mysql -u root -p < /vagrant/mysql-dump/proxy_config_connection.sql
```

6. Jalankan script pada ``clusterdb4``
```
# Melakukan Import Proxy_Config.SQL
sudo mysql -u admin -p -h 127.0.0.1 -P 6032 --prompt='ProxySQLAdmin> ' < /vagrant/mysql-dump/proxy_config.sql

# Mengunduh addition_to_sys.sql
curl -OL https://gist.github.com/lefred/77ddbde301c72535381ae7af9f968322/raw/5e40b03333a3c148b78aa348fd2cd5b5dbb36e4d/addition_to_sys.sql

# Melakukan Import addition_to_sys.sql
sudo mysql -u root -p < addition_to_sys.sql

# Melakukan Import proxy_config_connection.sql
sudo mysql -u root -p < /vagrant/mysql-dump/proxy_config_connection.sql
```

7. Prose instalasi selesai, selanjutnya adalah Dokumentasi penggunaan MySQL Cluster dengan Proxy Load Balancer

## 4. Dokumentasi
