# Implementasi Partisi

## Menu Cepat
1. [Check-Plugin Active](#1-check-plugin-active)
2. [Create Partition](#2-create-partition)
	- [Range Partition](#21-range-partition)
	- [List Partition](#22-list-partition)
	- [Hash Partition](#23-hash-partition)
	- [Key Partition](#24-key-partition)
3. [Testing "A Typical Use Case: Time Series Data"](#24-key-partition)

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
~~~
CREATE TABLE serverlogs2 (
    serverid INT NOT NULL, 
    logdata BLOB NOT NULL,
    created DATETIME NOT NULL
)
PARTITION BY HASH (serverid)
PARTITIONS 10;
~~~

![](/tugas_2_implementasi-partisi/screenshoot/create_hash.PNG)

Melakukan create table ``serverlogs2`` serta melakukan partisi dengan menggunakan hash, partisi yang dibuat adalah sebanyak 10.

~~~
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (1,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (43,'Test','2019-03-02 17:00:48');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (65,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (12,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (56,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (73,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (534,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (6422,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (196,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (956,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs2 (serverid, logdata, created) VALUES (22,'Test','2019-03-01 17:00:47');
~~~

![](/tugas_2_implementasi-partisi/screenshoot/insert_value_hash.PNG)

Melakukan insert value kedalam ``serverlogs2``, yang nantinya value tersebut akan otomatis dipindahkan kedalam partisi yang telah dibuat berdasarkan hash.

~~~
SELECT *,'p0' FROM serverlogs2 PARTITION (p0) UNION ALL 
SELECT *,'p1' FROM serverlogs2 PARTITION (p1) UNION ALL 
SELECT *,'p2' FROM serverlogs2 PARTITION (p2) UNION ALL 
SELECT *,'p3' FROM serverlogs2 PARTITION (p3) UNION ALL 
SELECT *,'p4' FROM serverlogs2 PARTITION (p4) UNION ALL 
SELECT *,'p5' FROM serverlogs2 PARTITION (p5) UNION ALL 
SELECT *,'p6' FROM serverlogs2 PARTITION (p6) UNION ALL 
SELECT *,'p7' FROM serverlogs2 PARTITION (p7) UNION ALL 
SELECT *,'p8' FROM serverlogs2 PARTITION (p8) UNION ALL 
SELECT *,'p9' FROM serverlogs2 PARTITION (p9)
ORDER BY serverid ASC;
~~~

![](/tugas_2_implementasi-partisi/screenshoot/result_value_hash.PNG)

Pada hasil diatas, value yang dimasukan akan otomatis dipindahkan sesuai partisi yang dibuat berdasarkan hash dari masing masing value yang dimasukan, dan akan dikelompokan berdasarkan jumlah partisi yang dibuat.

### 2.4 Key Partition
~~~
CREATE TABLE serverlogs4 (
    serverid INT NOT NULL, 
    logdata BLOB NOT NULL,
    created DATETIME NOT NULL,
    UNIQUE KEY (serverid)
)
PARTITION BY KEY()
PARTITIONS 5;
~~~

![](/tugas_2_implementasi-partisi/screenshoot/create_key.PNG)

Melakukan create table ``serverlogs4`` serta melakukan partisi dengan menggunakan key, partisi yang dibuat adalah sebanyak 5.

~~~
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (1,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (43,'Test','2019-03-02 17:00:48');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (65,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (12,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (56,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (73,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (534,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (6422,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (196,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (956,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (22,'Test','2019-03-01 17:00:47');
INSERT INTO serverlogs4 (serverid, logdata, created) VALUES (5543,'Test','2019-03-01 17:00:47');
~~~

![](/tugas_2_implementasi-partisi/screenshoot/insert_value_key.PNG)

Melakukan insert value kedalam ``serverlogs4``, yang nantinya value tersebut akan otomatis dipindahkan kedalam partisi yang telah dibuat berdasarkan key.

~~~
SELECT *,'p0' FROM serverlogs4 PARTITION (p0) UNION ALL 
SELECT *,'p1' FROM serverlogs4 PARTITION (p1) UNION ALL 
SELECT *,'p2' FROM serverlogs4 PARTITION (p2) UNION ALL 
SELECT *,'p3' FROM serverlogs4 PARTITION (p3) UNION ALL 
SELECT *,'p4' FROM serverlogs4 PARTITION (p4)
ORDER BY serverid ASC;
~~~

![](/tugas_2_implementasi-partisi/screenshoot/result_value_key.PNG)

Pada hasil diatas, value yang dimasukan akan otomatis dipindahkan sesuai partisi yang dibuat berdasarkan key dari masing masing value yang dimasukan, dan akan dikelompokan berdasarkan jumlah partisi yang dibuat, pada partisi key ini memiliki kesamaan dengan hash, hanya saja berdasarkan unique key yang dibuat pada saat create table.
