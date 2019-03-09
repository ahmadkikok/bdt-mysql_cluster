# Implementation MySQL Cluster with Proxy Load Balancer
Mengimplementasikan MySQL Cluster dengan Proxy Load Balancer, sebelum mengimplementasikan, ada beberapa hal yang harus diperhatikan :

## Kebutuhan
- Vagrant
- Bento/ubuntu18.04
- MySQL Data Sample
- MySQL Remote Software (Pada kasus ini saya menggunakan SQLYog)

## Model Arsitektur
Pada desain MySQL Cluster kali ini, saya menggunakan 4 Cluster, dengan informasi tiap clusternya:

| No | IP Address | Hostname | Deskripsi |
| --- | --- | --- | --- |
| 1 | 192.168.33.11 | clusterdb1 | Sebagai Node Manager |
| 2 | 192.168.33.12 | clusterdb2 | Sebagai Server 1 dan Node 1 |
| 3 | 192.168.33.13 | clusterdb3 | Sebagai Server 2 dan Node 2 |
| 4 | 192.168.33.14 | clusterdb4 | Sebagai Load Balancer (ProxySQL) |

## Instalasi
1.  ``git clone `` https://github.com/ahmadkikok/bdt-mysql_cluster.git
2. Hapus folder ``.vagrant`` untuk menghapus konfigurasi VB sebelumnya.
3. Lakukan ``vagrant up`` dan lakukan ``vagrant ssh`` ditiap clusternya.
### Provisioning Clusterdb-1


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
Konfigurasi ini adalah jumlah replikasi yang akan dilkukan
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

### Provisioning Clusterdb-2 dan Clusterdb-3
