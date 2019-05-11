# Implementation Redis
Tugas Implementasi Redis dengan menggunakan 1 Master dan 2 Slave.

## Menu Cepat
1. [Model Arsitektur](#1-model-arsitektur)
2. [Instalasi](#2-instalasi)
	- [Install Kebutuhan](#21-install-kebutuhan)
	- [Konfigurasi](#22-konfigurasi)
3. [CRUD](#3-crud)
4. [Fail Over](#4-fail-over)
5. [Referensi](#5-referensi)

## 1. Model Arsitektur
Pada desain Redis kali ini, saya menggunakan 3 Cluster, dengan informasi tiap clusternya:

| No | IP Address | Hostname | Deskripsi | RAM |
| --- | --- | --- | --- | --- |
| 1 | 192.168.33.10 | redismaster | Sebagai Master Redis | 2046 MB |
| 2 | 192.168.33.11 | redisslave1 | Sebagai Slave Redis 1 | 1024 MB |
| 3 | 192.168.33.12 | redisslave2 | Sebagai Slave Redis 2 | 1024 MB |

Menggunakan vagrantbox Bento/Ubuntu16.04, dengan konfigurasi :

![](/tugas_5_redis/screenshoot/konfigurasi_vagrant.PNG)

## 2. Instalasi
### 2.1 Install Kebutuhan
Pertama lakukan instalasi kebutuhan redis dimasing masing node :
```
sudo apt-get update 
sudo apt-get install build-essential tcl
sudo apt-get install libjemalloc-dev  (Optional)
```

Selanjutnya adalah melakukan instalasi redis dimasing masing node :
```
curl -O http://download.redis.io/redis-stable.tar.gz
tar xzvf redis-stable.tar.gz
cd redis-stable
make
make test
sudo make install
```

Pada kasus ini, file redis yang telah didownload dilakukan extract yang kemudian dilakukan compile dengan ``make`` agar redis dapat berjalan.

### 2.2 Konfigurasi
Pertama adalah lakukan konfigurasi untuk firewall dimasing masing node :
```
sudo ufw allow 6379
sudo ufw allow 26379
sudo ufw allow from 192.168.33.10 (Master)
sudo ufw allow from 192.168.33.11 (Slave1) 
sudo ufw allow from 192.168.33.10 (Slave2)
```

Port ``6379`` adalah port untuk redis proses, sedangkan port ``26379`` adalah untuk sentinel, dikarenakan masing masing node membutuhkan kedua proses tersebut, sehingga dimasing masing node dilakukan allow dari kedua port tersebut.
Setelah melakukan instalasi maka akan terdapat 2 file konfigurasi ``redis.conf`` dan ``sentinel.conf``, lakukan konfigurasi pada ``redis.conf`` dengan konfigurasi :
- Pada Master :
```
protected-mode no
port 6379
dir .
logfile "/home/redis-stable/redig.log" #output log
```

- Pada Slave 1 dan 2:
```
protected-mode no
port 6379
dir .
slaveof 192.168.33.10 6379
logfile "/home/redis-stable/redig.log" #output log
```
Konfigurasi diatas menjelaskan bahwa slave 1 dan 2 adalah slave dari master ``192.168.33.10``.

Kemudian lakukan konfigurasi pada masing masing ``sentinel.conf`` dengan konfigurasi sebagai berikut :

```
protected-mode no
port 26379
logfile "/home/redis-stable/sentinel.log"
sentinel monitor mymaster 192.168.33.10 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 10000
```

Selanjutnya adalah menjalankan redis, untuk menjalankan redis kamu harus menjalankan ``redis-server`` yang berada pada folder ``src``, dengan cara :

```
src/redis-server redis.conf &
src/redis-server sentinel.conf --sentinel &
```

Untuk melakukan check status coba ketikkan ``ps -ef | grep redis`` maka akan muncul seperti ini :

![](/tugas_5_redis/screenshoot/redis_running_master.PNG)

![](/tugas_5_redis/screenshoot/redis_running_slave1.PNG)

![](/tugas_5_redis/screenshoot/redis_running_slave2.PNG)

Selanjutnya adalah melakukan testing ping dari masing masing node :
```
redis-cli -h IP_Address ping #Masukkan IP_Address dengan alamat masing masing node
```

![](/tugas_5_redis/screenshoot/redis_master_ping.PNG)

Redis dari ketiga node telah berjalan dengan baik tanpa adanya error.

Selanjutnya check log dari masing masing node :

``redis.log`` dan ``sentinel.log`` pada master :

![](/tugas_5_redis/screenshoot/redis_log_master.PNG)

![](/tugas_5_redis/screenshoot/sentinel_log_master.PNG)

``redis.log`` dan ``sentinel.log`` pada slave1 :

![](/tugas_5_redis/screenshoot/redis_log_slave1.PNG)

![](/tugas_5_redis/screenshoot/sentinel_log_slave1.PNG)

``redis.log`` dan ``sentinel.log`` pada slave2 :

![](/tugas_5_redis/screenshoot/redis_log_slave2.PNG)

![](/tugas_5_redis/screenshoot/sentinel_log_slave2.PNG)

Dari masing masing node telah tersinkronisasi dengan baik tanpa adanya error, dan secara otomatis maka pada info replication akan terkonfigurasi seperti ini :

![](/tugas_5_redis/screenshoot/redis_info_replication.PNG)

## 3. CRUD

## 4. Fail Over
Pada kali ini akan mencoba mematikan node pada master dengan cara :
```
kill -9 <process id>
atau
redis-cli -p 6379 DEBUG sleep 30
atau
redis-cli -p 6379 DEBUG SEGFAULT
```

![](/tugas_5_redis/screenshoot/redis_failover_master_off.PNG)

Maka pada master akan berhasil dimatikan, dan salah satu node slave akan menjadi masternya ketika failover dilakukan :

![](/tugas_5_redis/screenshoot/redis_failover_slave.PNG)

Pada kasus ini slave2 menjadi master setelah failover, sehingga redis tetap berjalan walaupun master mati karna master lainnya telah tergantikan oleh slave yang ada.

## 5. Referensi