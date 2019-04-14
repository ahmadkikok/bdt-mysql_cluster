# Implementation Cassandra Single Note
Mengimplementasikan cassandra single note, pada pengimplementasi-an cassandra kali ini, saya membuat vagrant boxes sebanyak 2, dengan konfigurasi vagrant :

![](/tugas_4_cassandara-single-and-multiple-note/tugas_single-note/screenshoot/cassandra_vagrant.PNG)

cassandra#1 yang akan kita gunakan pada implementasi single note ini.                                
cassandra#2 akan digunakan untuk tugas selanjutnya berupa cassandra multi node.

## Menu Cepat
1. [Kebutuhan](#1-kebutuhan)
2. [Instalasi](#2-instalasi)
	- [User dan Sudo](#21-user-dan-sudo)
	- [Oracle Java Virtual Machine](#22-oracle-java-virtual-machine)
	- [Cassandra](#23-cassandra)
3. [Referensi](#3-referensi)

## 1. Kebutuhan
- Vagrant
- Bento/ubuntu14.04
- Oracle Java Virtual Machine

## 2. Instalasi
### 2.1 User dan Sudo
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

### 2.2 Oracle Java Virtual Machine
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

### 2.3 Cassandra
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

## 3. Referensi
https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-14-04                   
https://www.digitalocean.com/community/tutorials/how-to-install-cassandra-and-run-a-single-node-cluster-on-ubuntu-14-04