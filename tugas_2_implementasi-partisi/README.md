# Implementasi Partisi

## Menu Cepat
1. [Check-Plugin Active](#1-kebutuhan)
2. [Create Partition](#2-model-arsitektur)
	- [Range Partition](#31-provisioning-clusterdb-1)
	- [List Partition](#32-provisioning-clusterdb-2-dan-clusterdb-3)
	- [Hash Partition](#33-provisioning-clusterdb-4)
	- [Key Partition](#33-provisioning-clusterdb-4)

## 1. Check-Plugin Active

![](/tugas_2_implementasi-partisi/screenshoot/create_databases_tugas2.PNG)

Menambahkan database baru ``tugas2`` pada service.

![](/tugas_2_implementasi-partisi/screenshoot/permission_userbdt_fordatabasetugas2.PNG)

Memberikan permission agar user ``bdt`` dapat mengakses database ``tugas2`` melalui ProxySQL.

Untuk melakukan pengecekan support partitioning, masukan syntax berikut :

``SHOW PLUGINS``

atau

```
SELECT
    PLUGIN_NAME as Name,
    PLUGIN_VERSION as Version,
    PLUGIN_STATUS as Status
    FROM INFORMATION_SCHEMA.PLUGINS
    WHERE PLUGIN_TYPE='STORAGE ENGINE';
```

Pada ProxySQL.

Sehingga akan menghasilkan hasil seperti berikut :

![](/tugas_2_implementasi-partisi/screenshoot/check_support_partitioning.PNG)

## 2. Create Partition
Mengimplementasikan pembuatan table dengan menggunakan partisi.

### 2.1 Range Partition
~~~
CREATE TABLE rc1 (
    a INT,
    b INT
)
PARTITION BY RANGE COLUMNS(a, b) (
    PARTITION p0 VALUES LESS THAN (5, 12),
    PARTITION p3 VALUES LESS THAN (MAXVALUE, MAXVALUE)
);
~~~

![](/tugas_2_implementasi-partisi/screenshoot/create_range.PNG)

Melakukan create table ``rc1`` serta melakukan partisi ``p0`` jika value < 5,12. Value sisanya akan dimasukan ke dalam ``p3``.
~~~
INSERT INTO rc1 (a,b) VALUES (4,11);
INSERT INTO rc1 (a,b) VALUES (5,11);
INSERT INTO rc1 (a,b) VALUES (6,11);
INSERT INTO rc1 (a,b) VALUES (4,12);
INSERT INTO rc1 (a,b) VALUES (5,12);
INSERT INTO rc1 (a,b) VALUES (6,12);
INSERT INTO rc1 (a,b) VALUES (4,13);
INSERT INTO rc1 (a,b) VALUES (5,13);
INSERT INTO rc1 (a,b) VALUES (6,13);
~~~

![](/tugas_2_implementasi-partisi/screenshoot/insert_value_range.PNG)

Melakukan insert value kedalam ``rc1``, yang nantinya value tersebut akan otomatis dipindahkan kedalam partisi yang telah dibuat.

~~~
SELECT *,'p0' FROM rc1 PARTITION (p0) UNION ALL SELECT *,'p3' FROM rc1 PARTITION (p3) ORDER BY a,b ASC;
~~~

![](/tugas_2_implementasi-partisi/screenshoot/result_value_range.PNG)

Pada hasil diatas, value yang dimasukan akan otomatis dipindahkan sesuai partisi yang dibuat, seperti pada contoh, yang memiliki values <= 5,12 akan dimasukan kedalam ``p0``.

### 2.2 List Partition
~~~
CREATE TABLE serverlogs (
    serverid INT NOT NULL, 
    logdata BLOB NOT NULL,
    created DATETIME NOT NULL
)
PARTITION BY LIST (serverid)(
    PARTITION server_east VALUES IN(1,43,65,12,56,73),
    PARTITION server_west VALUES IN(534,6422,196,956,22)
);
~~~

![](/tugas_2_implementasi-partisi/screenshoot/create_list.PNG)

Melakukan create table ``serverlogs`` serta melakukan partisi pembagian kode area sesuai partisi yang dibuat.

~~~
INSERT INTO serverlogs (serverid, logdata, created) VALUES (1,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs (serverid, logdata, created) VALUES (43,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs (serverid, logdata, created) VALUES (534,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs (serverid, logdata, created) VALUES (956,'Test','2019-03-01 17:00:47');
~~~

![](/tugas_2_implementasi-partisi/screenshoot/insert_value_list.PNG)

Melakukan insert value kedalam ``serverlogs``, yang nantinya value tersebut akan otomatis dipindahkan kedalam partisi yang telah dibuat.

~~~

SELECT *,'server_east' FROM serverlogs PARTITION (server_east) UNION ALL SELECT *,'server_west' FROM serverlogs PARTITION (server_west) ORDER BY serverid,server_east ASC;
~~~

![](/tugas_2_implementasi-partisi/screenshoot/result_value_list.PNG)

Pada hasil diatas, value yang dimasukan akan otomatis dipindahkan sesuai partisi yang dibuat, seperti pada contoh, yang memiliki ``serverid`` 1,43 akan dikelompokan kedalam wilayah ``server_east``.

### 2.3 Hash Partition

### 2.4 Key Partition