# Implementation Cassandra Single Note
Mengimplementasikan cassandra single note, pada pengimplementasi-an cassandra kali ini, saya membuat vagrant boxes sebanyak 2, dengan konfigurasi vagrant :

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/cassandra_vagrant.PNG)

cassandra#1 (192.168.33.11) yang akan kita gunakan pada implementasi single note ini.                                
cassandra#2 (192.168.33.12) akan digunakan untuk tugas selanjutnya berupa cassandra multi node.

## Menu Cepat
1. [Kebutuhan](#1-kebutuhan)
2. [Pengenalan](#2-pengenalan)
	- [Cassandra](#21-cassandra)
	- [Relational vs NoSQL](#22-relational-vs-nosql)
	- [Arsitektur](#23-arsitektur)
3. [Instalasi](#3-instalasi)
	- [User dan Sudo](#31-user-dan-sudo)
	- [Oracle Java Virtual Machine](#32-oracle-java-virtual-machine)
	- [Cassandra](#33-cassandra)
4. [CRUD dan Datasets](#4-crud-and-datasets)
	- [Datasets] (#41-datasets)
	- [Import Datasets] (#42-import-datasets)
	- [CRUD Operation] (#43-crud-operation)	
5. [Referensi](#5-referensi)

## 1. Kebutuhan
- Vagrant
- Bento/ubuntu14.04
- Oracle Java Virtual Machine

## 2. Pengenalan
### 2.1 Cassandra
Cassandra atau lengkap APACHE CASSANDRA adalah salah satu produk open source untuk menajemen database yang didistribusikan oleh Apache yang sangat scalable (dapat diukur) dan dirancang untuk mengelola data terstruktur yang berkapasitas sangat besar (Big Data) yang tersebar di banyak server. Cassandra merupakan salah satu implementasi dari NoSQL (Not Only SQL) seperti mongoDB. NoSQL merupakan konsep penyimpanan database dinamis yang tidak terikat pada relasi-relasi tabel yang kaku seperti RDBMS. Selain lebih scalable, NoSQL juga memiliki performa pengaksesan yang lebih cepat.

### 2.2 Relational vs NoSQL
Perbedaan antara Relational Database dan NoSQL Database :

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/different_nosql.PNG)

### 2.3 Arsitektur
Arsitektur pada Cassandra sendiri :

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/arsitektur.PNG)

Dimana cassandra sendiri mempunyai beberapa komponen utama yaitu :
    Node : ini adalah server tempat penyimpanan data.
    Data Center : kumpulan dari beberapa node.
    Cluster : Kumpulan dari beberapa data center.
    Commit Log : adalah log dari proses penulisan di Cassandra , yang berfungsi juga sebagai Crash Recovery Mechanism.
    Mem-Table : Adalah memory-resident data structure. Setelah menulis dalam commit log , cassandra melakukan penulisan di sini.
    CQL : Cassandra Query Language , adalah bahasa perintah query di cassandra .
	
Pada kasus ini saya menggunakan 1 server saja sehingga node dan data node berada pada 1 server saja.

## 3. Instalasi
### 3.1 User dan Sudo
Pertama-tama yang harus dilakukan adalah melakukan ``vagrant up`` dan melakukan creating user.
```
# Make User
adduser bdt
# Grant Root Privileges
gpasswd -a bdt sudo
```

Pada kasus ini, saya membuat user dengan nama ``bdt`` dan password ``bdt2019`` dengan diberikan hak akses berupa ``sudo``
password akan muncul setelah melakukan perintah ``adduser``.

Hasil screenshoot dari creating user dan pemberian hak ases.

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/cassandra_add_user.PNG)

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/cassandra_sudo_user.PNG)

### 3.2 Oracle Java Virtual Machine
Sebelum melakukan install java, diperlukan beberapa package agar dapat melakukan creating repository.

1. Melakukan install properties-common, dengan menjalankan :
```
# Apt-get Update
sudo apt-get update
# Install Lib For Add Apt
sudo apt-get install software-properties-common
```

Apt-get digunakan untuk melakukan update package yang sudah ada, kemudian melakukan instalasi propeties common agar bisa melakukan add-repository.

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/cassandra_install_propeties_common.PNG)

2. Menambahkan repository baru untuk ``Oracle Java`` :
```
# Add Repository Java
sudo add-apt-repository ppa:webupd8team/java
# Apt-get Update for Repository Java
sudo apt-get update
``` 

Lakukan update setelah menambahkan repository, agar repository yang ditambahkan ikut terupdate

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/cassandra_add_repository.PNG)

3. Selanjutnya adalah instalasi java :
```
# Install Java
sudo apt-get install oracle-java8-set-default
```

Setelah proses instalasi selesai, maka akan tampil seperti ini jika mengetikan ``java -version`` :

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/cassandra_install_java.PNG)

### 3.3 Cassandra
Melakukan instalasi cassandra dilakukan export beberapa package serta melakukan update key, langkah yang dilakukan adalah :

1. Install cassandra package and source package :
```
# Cassandra Package
echo "deb http://www.apache.org/dist/cassandra/debian 39x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
# Source Cassandra Package
echo "deb-src http://www.apache.org/dist/cassandra/debian 39x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
```

2. Export 3 key :
```
# First Key
gpg --keyserver pgp.mit.edu --recv-keys F758CE318D77295D
gpg --export --armor F758CE318D77295D | sudo apt-key add -
# Second Key
gpg --keyserver pgp.mit.edu --recv-keys 2B5C1B00
gpg --export --armor 2B5C1B00 | sudo apt-key add -
# Third Key
gpg --keyserver pgp.mit.edu --recv-keys 0353B12C
gpg --export --armor 0353B12C | sudo apt-key add -
# Apt-get Update for Key
sudo apt-get update
```

Berikut hasil screenshoot setelah menambahkan key, jangan lupa untuk melakukan update agar key cassandra ikut terupdate.

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/cassandra_add_key.PNG)

3. Install Cassandra :
```
# Install Cassandra
sudo apt-get install cassandra
```

4. Check status running cassandra dengan cara :
```
sudo service cassandra status
```

Maka akan muncul seperti ini :

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/cassandra_status.PNG)

5. Check node status dengan cara :
```
sudo nodetool status
```

Maka akan muncul seperti ini :

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/cassandra_node_status.PNG)

Cassandra telah berhasil di install dan berhasil di jalankan pada vagrant boxes ``cassandra#1``.

## 4. CRUD dan Datasets
### 4.1 Datasets
Pada kali ini saya menggunakan datasets yang berasal dari www.kaggle.com, datasets yang saya gunakan adalah "Stanford Card Datasets".

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/datasets.PNG)

https://www.kaggle.com/jutrera/stanford-car-dataset-by-classes-folder#names.csv

Datasets ini berisi daftar nama mobil SUV, dimana hanya terdapat 1 atribut pada datasets ini, yaitu nama.

### 4.2 Import Datasets
1. Pertama-tama yang dilakukan adalah login melalui ``cqlsh``.
2. Buat keyspace untuk tempat table import datasets :
Syntax untuk keyspace adalah 
```
CREATE KEYSPACE cycling 
  WITH REPLICATION = { 
   'class' : 'NetworkTopologyStrategy', 
   'datacenter1' : 1 
  } ;
```

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/create_keyspace.PNG)

Penjelasan mengenani replikasi class :

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/described.PNG)

lebih lengkapnya dijelaskan pada referensi.

3. Setelah keyspace telah dibuat, masuk ke dalam keyspace dengan menggunakan :
```
use car;
```

Pada kasus ini saya membuat keyspace dengan nama car

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/keyspace.PNG)

4. Selanjutnya adalah membuat table tempat import csv, dikarenakan csv tidak memiliki data type sehingga diperlukan melakukan pembuatan table sebelum melakukan importing csv.

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/create_table.PNG)

5. Selanjutnya adalah melakukan import dengan mengetikkan script :
```
COPY test(Price, Year, Mileage, City, State, Vin, Make, Model) FROM '/home/vagrant/true_car_listings.csv' WITH DELIMITER = ',' AND HEADER = TRUE;
```

Melakukan copy kedalam table dengan atribut yang sudah ditentukan yang diambil dari file true_car_listings.csv yang dipisah melalui ','.
Hasil import csv telah berhasil :

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/import_results.PNG)

### 4.3 CRUD Operation
1. Select Data :
```
SELECT * FROM test;
```
![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/crud_select.PNG)

Melakukan select semua data pada table test.

2. Delete Data :
```
DELETE FROM test WHERE vin = '3FA6P0K90GR142625';
```
![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/crud_delete.PNG)

melakukan delete pada vin ``3FA6P0K90GR142625``, vin adalah primary key yang telah di set.

3. Insert Data :
```
INSERT INTO test(vin) values('3FA6P0K90GR142625');
```
![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/crud_insert.PNG)

Mengapa null? karena pada kasus ini saya hanya memasukkan vin saja tidak dengan data lainnya.

4. Update Data :
```
UPDATE test SET year = '2020' WHERE vin = '3FA6P0K90GR142625';
```
![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/crud_update.PNG)

Melakukan update data pada vin ``3FA6P0K90GR142625`` dengan menambahkan tahun 2020

## 5. Referensi
https://www.youtube.com/watch?v=N71NwCKfyQ4                                                               
https://docs.datastax.com/en/cql/3.3/cql/cql_reference/cqlCreateKeyspace.html                               
https://medium.com/@danairwanda/pengenalan-cassandra-database-nosql-3d33a768a20                            
https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-14-04                   
https://www.digitalocean.com/community/tutorials/how-to-install-cassandra-and-run-a-single-node-cluster-on-ubuntu-14-04