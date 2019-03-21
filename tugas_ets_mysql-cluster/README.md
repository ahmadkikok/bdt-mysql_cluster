# Implementasi Wordpress pada MySQL Cluster dan ProxySQL

## 1. Model Arsitektur
Pada desain MySQL Cluster kali ini, saya menggunakan 4 Cluster, dengan informasi tiap clusternya:

| No | IP Address | Hostname | Deskripsi |
| --- | --- | --- | --- |
| 1 | 192.168.33.11 | clusterdb1 | Sebagai Node Manager |
| 2 | 192.168.33.12 | clusterdb2 | Sebagai Server 1 dan Node 1 |
| 3 | 192.168.33.13 | clusterdb3 | Sebagai Server 2 dan Node 2 |
| 4 | 192.168.33.14 | clusterdb4 | Sebagai Load Balancer (ProxySQL) |

Dan ditambah instalasi ``apache`` dan ``wordpress`` dilakukan pada ``clusterdb4``, proses instalasi mysql-cluster sama dengan [tugas_1_implementasi-mysql_cluster](https://github.com/ahmadkikok/bdt_2019/tree/master/tugas_1_implementasi-mysql_cluster).

## 2. Instalasi Wordpress
1. Membuat database baru ``ets`` pada ``clusterdb2/3``, dan memberikan hak akses terhadap user ``bdt`` pada kedua cluster.
![](/tugas_ets_mysql-cluster/screnshoot/create_database_ets.PNG)
~~~
GRANT ALL PRIVILEGES on ets.* to 'bdt'@'%';
FLUSH PRIVILEGES;
~~~

2. Install Apache2 pada ``clusterdb4`` (proxy), dan php sebagai kebutuhan wordpress.
![](/tugas_ets_mysql-cluster/screnshoot/install_apache2.PNG)
~~~
sudo apt-get install php -y
sudo apt-get install php-mysql
sudo apt-get install -y php-gd php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap php-tidy curl
~~~

3. Copy wordpress kedalam box clusterdb4 dan melakukan untar menggunakan :
Copy :
```
sudo cp '/vagrant/install/wordpress-5.1.1.tar.gz' '/var/www/html/'
```
Untar :
```
tar -xvf wordpress-5.1.1.tar.gz
```

4. Rename file ``wp-config-sample.php`` menjadi ``wp-config.php`` dan ubah konfigurasi database menjadi seperti ini :
~~~
/** The name of the database for WordPress */
define( 'DB_NAME', 'ets' );

/** MySQL database username */
define( 'DB_USER', 'bdt' );

/** MySQL database password */
define( 'DB_PASSWORD', 'bdt2019' );

/** MySQL hostname */
define( 'DB_HOST', '192.168.33.14:6033' );
~~~

5. Ubah database engine menjadi ``ndb`` pada ``wordpress\wp-admin\includes\schema.php`` salah satu contoh :
![](/tugas_ets_mysql-cluster/screnshoot/change_database_engine.PNG)
Lakukan hal yang sama pada semua tables yang akan dibuat. Pada kasus ini saya sudah merubah semua tables, sehinggi hanya perlu mengcopy file schema :
```
sudo cp '/vagrant/install/schema.php' '/var/www/html/wordpress/wp-admin/includes/'
```

6. Buka pada browser ``http://192.168.33.14/wordpress`` maka akan muncul tampilan instalasi ``wordpress`` :
![](/tugas_ets_mysql-cluster/screnshoot/install_view_website.PNG)

Ikuti langkah sesuai petunjuk instalasi ``wordpress``, maka akan muncul :
![](/tugas_ets_mysql-cluster/screnshoot/install_view_website.PNG)

``WordPress`` berhasil diinstall.

6. Schema yang dibuat secara otomatis oleh wordpress telah ada di ``cluster2`` dan ``cluster3`` :
![](/tugas_ets_mysql-cluster/screnshoot/install_view_schemas.PNG)

## 3. Test Database Wordpress
![](/tugas_ets_mysql-cluster/screnshoot/test_info_cluster.PNG)
Status mysql-cluster semua node terkoneksi dengan baik

Ketika salah satu node dimatikan, dan melakukan insert data via wordpress(menambahkan postingan baru) :
![](/tugas_ets_mysql-cluster/screnshoot/test_dataid2_off.PNG)
![](/tugas_ets_mysql-cluster/screnshoot/test_dataid2_off_berhasil.PNG)
Ketika node dengan id 2 dimatikan, otomatis node yang berjalan adalah node dengan id 3, dan posting berhasil dilakukan.

Sekarang mencoba ketika node id 2 diaktifkan dan id 3 dimatikan, maka hasilnya :
![](/tugas_ets_mysql-cluster/screnshoot/test_dataid3_off.PNG)
![](/tugas_ets_mysql-cluster/screnshoot/test_dataid3_off_berhasil.PNG)
Ketika node dengan id 2 dinyalakan, dan node id 3 dimatikan, data masih tetap sama, yang artinya mysql-cluster berhasil saling mereplikasi.

Sekarang mencoba ketika kedua node dimatikan :
![](/tugas_ets_mysql-cluster/screnshoot/test_dataid23_off.PNG)
Ketika kedua node mati, otomatis service akan mati dikarenakan service tidak bsa mengakses data node manapun (error).
![](/tugas_ets_mysql-cluster/screnshoot/test_dataid23_off_gagal.PNG)
Dan ketika kedua data node mati, otomatis wordpress tidak bisa membaca semua tables yang dibutuhkan, sehingga wordpress meminta kembali penginstallan ulang.