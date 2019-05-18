# Evaluasi Tengah Semester Wordpress dengan Menggunakan MySQL Cluster dan Redis

## Menu Cepat
1. [Model Arsitektur](#1-model-arsitektur)
2. [Instalasi Wordpress](#2-instalasi-wordpress)
3. [Instalasi Redis](#3-instalasi-redis)
4. [Konfigurasi Wordpress](#4-konfigurasi-wordpress)
5. [Test Failover Redis](#5-test-failover-redis)
6. [Referensi](#6-referensi)

## 1. Model Arsitektur
Pada desain MySQL Cluster dan Redis kali ini, saya menggunakan 4 Node, dengan informasi tiap clusternya:

| No | IP Address | Hostname | Deskripsi |
| --- | --- | --- | --- |
| 1 | 192.168.33.11 | clusterdb1 | Sebagai Node Manager dan Redis Master |
| 2 | 192.168.33.12 | clusterdb2 | Sebagai Server 1 dan Node 1 dan Redis Slave 1 |
| 3 | 192.168.33.13 | clusterdb3 | Sebagai Server 2 dan Node 2 dan Redis Slave 2|
| 4 | 192.168.33.14 | clusterdb4 | Sebagai Load Balancer (ProxySQL) |

Dan ditambah instalasi ``apache`` dan ``wordpress`` dilakukan pada ``clusterdb4``, proses instalasi mysql-cluster sama dengan [tugas_1_implementasi-mysql_cluster](https://github.com/ahmadkikok/bdt_2019/tree/master/tugas_1_implementasi-mysql_cluster).

## 2. Instalasi Wordpress
Sebelum melakukan instalasi wordpress pastikan konfigurasi MySQL Cluster telah berjalan dengan baik, untuk setingan MySQL Cluster bisa melihat dokumentasi sebelumnya :

[tugas_1_implementasi-mysql_cluster](https://github.com/ahmadkikok/bdt_2019/tree/master/tugas_1_implementasi-mysql_cluster)

Apabila MySQL Cluster telah berjalan dengan baik, lakukan instalasi Wordpress dengan melihat dokumentasi sebelumnya :

[tugas_ets_mysql-cluster](https://github.com/ahmadkikok/bdt_2019/tree/master/tugas_ets_mysql-cluster)

## 3. Instalasi Redis
Apabila instalasi wordpress sudah berhasil tanpa adanya error, selanjutnya adalah melakukan instalasi redis dengan mengikuti dokumentasi sebelumnya :

[tugas_5_redis](https://github.com/ahmadkikok/bdt_2019/tree/master/tugas_5_redis)

Pastikan redis telah berjalan dengan baik dan mampu mereplikasi sebelum dimasukan kedalam konfigurasi wordpress.

## 4. Konfigurasi Wordpress
Apabila semua konfigurasi Redis dan MySQL Cluster telah dilakukan dan berjalan dengan baik, selanjutnya adalah melakukan konfigurasi wordpress, untuk konfigurasi wordpress ini hanya tinggal menambahkan konfigurasi Redis agar wordpress mampu membaca Redis, dikarenakan pada dokumentasi sebelumnya sudah melakukan setting MySQL Cluster untuk database utama dari wordpress itu sendiri.

1. Pertama adalah melakukan instalasi ``Wordpress Redis Object Cache`` Plugin :

![](/tugas_eas_mysql-redis/screenshoot/install_redis_cache_wordpress.PNG)

Menu ini dapat diakses setelah melakukan login kedalam wordpress, apabila proses instalasi plugin error, silahkan membaca referensi yang diberikan.

Setelah melakukan instalasi plugin, selanjutnya adalah melakukan konfigurasi pada ``wp-config.php`` :
```
define( 'WP_REDIS_CLIENT', 'predis' );
define( 'WP_REDIS_SENTINEL', 'mymaster' );
define( 'WP_REDIS_SERVERS', [
    'tcp://127.0.0.1:5380',
    'tcp://127.0.0.2:5381',
    'tcp://127.0.0.3:5382',
] );
```

Lakukan konfigurasi diatas sesuai dengan setingan sentinel yang telah dilakukan sebelumnya, mengapa terdapat 3 server? dikarenakan pada sample menggunakan 3 node yang digunakan sebagai redis.

Apabila sudah melakukan konfigurasi, masuk kedalam menu wordpress kembali dan aktifkan plugin ``Redis Object Cache``, maka akan muncul tampilan sepert ini :
![](/tugas_eas_mysql-redis/screenshoot/plugin_redis_on.PNG)

Pastikan plugin menyala dan terhubung, apabila plugin menyala tapi tidak terhubung, silahkan cek kembali konfigurasi pada ``wp-config.php``, dan konfigurasi MySQL Cluster dan Redis telah berhasil dilakukan dengan baik, selanjutnya hanya tinggal melakukan test.

## 5. Test Failover Redis
![](/tugas_eas_mysql-redis/screenshoot/redis_test_1.PNG)

Pada gambara diatas, saya mencoba memonitor ketiga redis, sambil melakukan refresh pada halaman wordpress, maka semua cache masuk pada ``clusterdb2``.

![](/tugas_eas_mysql-redis/screenshoot/redis_test_2.PNG)

Ketika ``clusterdb2`` saya matikan redisnya, maka cache tetap berjalan, akan tetapi pindah ke ``clusterdb1``.

![](/tugas_eas_mysql-redis/screenshoot/redis_test_3.PNG)

Ketika ``clusterdb1`` saya matikan, maka cache akan berjalan pada ``clusterdb3``.

![](/tugas_eas_mysql-redis/screenshoot/redis_test_4.PNG)

Gambar diatas adalah ketika semua redis ditiap node saya matikan, maka status plugin pada wordpress akan berubah menjadi tidak terhubung, dikarenakan tidak terdapat satupun node redis yang berjalan.

## 6. Referensi
https://wordpress.org/plugins/redis-cache/                                                                     
https://www.cloudways.com/blog/install-redis-cache-wordpress/                                                       
https://scalegrid.io/blog/using-redis-object-cache-to-speed-up-your-wordpress-installation/                                                                        
https://www.digitalocean.com/community/tutorials/how-to-configure-redis-caching-to-speed-up-wordpress-on-ubuntu-14-04
https://www.alibabacloud.com/blog/wordpress-performance-benchmarking-%26-installing-redis-object-caching_327910     
https://www.digitalocean.com/community/questions/why-i-can-t-install-a-new-plugin-on-my-wordpress         