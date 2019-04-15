# Implementation Cassandra Multi Note
Sebelumnya kita telah melakukan implementasi single note, selanjutnya adalah pengimplementasian menggunakan multi note, sebelumnya kita sudah melakukan konfigurasi pada cassandra#1, selanjutnya yang kita lakukan adalah melakukan installasi terhadap cassandra#2 untuk penginstalan cassandra, mengikuti tutorial sebelumnya.

cassandra#1 sudah di install cassandra.                                
cassandra#2 lakukan instalasi cassandra sesuai penginstalan cassandra yang di lakukan pada [Single Note](https://github.com/ahmadkikok/bdt_2019/tree/master/tugas_4_cassandara-single-and-multiple-note/tugas_single-note).

## Menu Cepat
1. [Kebutuhan](#1-kebutuhan)
2. [Instalasi](#2-instalasi)
	- [Firewall](#21-firewall)
	- [Oracle Java Virtual Machine](#22-oracle-java-virtual-machine)
	- [Cassandra](#23-cassandra)
3. [Referensi](#3-referensi)

## 1. Kebutuhan
- Minimal 2 Vagrant dengan Ubuntu 14.04 Server
- Bento/ubuntu14.04
- Oracle Java Virtual Machine di masing-masing server
- Cassandra di masing-masing server 
- Firewall menggunakan IPTables

## 2. Instalasi
### 2.1 Firewall
Pertama yang dilakukan adalah install firewall di masing-masing server ``cassandra#1`` dan ``cassandra#2`` :
```
sudo apt-get update
sudo apt-get install iptables-persistent
```

setelah install, maka semua konfigurasi firewall berada pada ``/etc/iptables/rules.v4`` jika menggunakan IPv4 dan ``/etc/iptables/rules.v6`` jika menggunakan IPv6.

### 2.2 Konfigurasi Cluster
1. Pertama yang dilakukan adalah melakukan stop service dan penghapusan data default.
```
sudo service cassandra stop
```

Penghapusan data default yang berada di file :
```
sudo rm -rf /var/lib/cassandra/data/system/*
```

2. Konfigurasi cassandra berada pada folder ``/etc/cassandra`` konfigurasi filenya yaitu ``cassandra.yaml``, lakukan konfigurasi pada file tersebut, pada kasus ini saya melakukan konfigurasi :
```
.....
cluster_name: 'Test Cluster' #Nama Clustermu, harus sama tiap node!
.....
seed_provider:
    # Addresses of hosts that are deemed contact points. 
    # Cassandra nodes use this list of hosts to find each other and learn
    # the topology of the ring.  You must change this if you are running
    # multiple nodes!
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          # seeds is actually a comma-delimited list of addresses.
          # Ex: "<ip1>,<ip2>,<ip3>"
          - seeds: "192.168.33.11,192.168.33.12"
.....
listen_address: 192.168.33.11
.....
rpc_address: 192.168.33.11
.....
endpoint_snitch: GossipingPropertyFileSnitch
.....
auto_bootstrap: false #Added this configuration at the bottom of file
```

Penjelasan mengenai konfigurasi tersebut :
```
* cluster_name: This is the name of your cluster.

* -seeds: This is a comma-delimited list of the IP address of each node in the cluster.

* listen_address: This is IP address that other nodes in the cluster will use to connect to this one. It defaults to localhost and needs changed to the IP address of the node.

* rpc_address: This is the IP address for remote procedure calls. It defaults to localhost. If the server's hostname is properly configured, leave this as is. Otherwise, change to server's IP address or the loopback address (127.0.0.1).

* endpoint_snitch: Name of the snitch, which is what tells Cassandra about what its network looks like. This defaults to SimpleSnitch, which is used for networks in one datacenter. In our case, we'll change it to GossipingPropertyFileSnitch, which is preferred for production setups.

* auto_bootstrap: This directive is not in the configuration file, so it has to be added and set to false. This makes new nodes automatically use the right data. It is optional if you're adding nodes to an existing cluster, but required when you're initializing a fresh cluster, that is, one with no data.

```

Lakukan hal yang sama pada server lainnya yaitu ``cassandra#2``.

3. Selanjutnya adalah menyalakan service dan mengecek hasil dari cassandra yang telah di setting.
```
sudo service cassandra start
```

Dan lakukan checking :

```
sudo nodetool status
```

Maka hasil dari cassandra akan keluar seperti ini :

![](/tugas_4_cassandara-single-and-multiple-note/tugas_multi-note/screenshoot/cassandra_status_1.PNG)

![](/tugas_4_cassandara-single-and-multiple-note/tugas_multi-note/screenshoot/cassandra_status_2.PNG)

Kedua note bisa diakses oleh server 1 maupun server 2, berikut hasil uji coba :

![](/tugas_4_cassandara-single-and-multiple-note/tugas_multi-note/screenshoot/node.PNG)

Cassandra telah berhasil di buat clustering, apabila terjadi error, silahkan mengikuti langkah firewall.

### 2.3 Konfigurasi Firewall
Apabila node tidak terbaca silahkan jalankan script ini di masing masing server :
```
-A INPUT -p tcp -s your_other_server_ip -m multiport --dports 7000,9042 -m state --state NEW,ESTABLISHED -j ACCEPT
```

Isikan ``your_other_server_ip`` dengan alamat ip server lainnya yang terhubung.

Cassandra telah selesai di install dan note berjalan dengan baik.


## 3. Referensi
https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-14-04                   
https://github.com/ahmadkikok/bdt_2019/tree/master/tugas_4_cassandara-single-and-multiple-note/tugas_single-note
https://www.digitalocean.com/community/tutorials/how-to-install-cassandra-and-run-a-single-node-cluster-on-ubuntu-14-04
https://www.digitalocean.com/community/tutorials/how-to-run-a-multi-node-cluster-database-with-cassandra-on-ubuntu-14-04
https://www.digitalocean.com/community/tutorials/how-to-implement-a-basic-firewall-template-with-iptables-on-ubuntu-14-04
