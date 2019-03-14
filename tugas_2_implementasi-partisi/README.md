# Implementasi Partisi

## Menu Cepat
1. [Check-Plugin Active](#1-kebutuhan)
2. [Create Partition](#2-model-arsitektur)
	- [Range Partition](#31-provisioning-clusterdb-1)
	- [List Partition](#32-provisioning-clusterdb-2-dan-clusterdb-3)
	- [Hash Partition](#33-provisioning-clusterdb-4)
	- [Key Partition](#33-provisioning-clusterdb-4)
4. [Dokumentasi](#4-dokumentasi)
	- [Instalasi Cluster Manager](#41-instalasi-cluster-manager)
	- [Instalasi Data Node](#42-instalasi-data-node)
	- [Instalasi Service API](#43-instalasi-service-api)
	- [NDB Status & NDB_MGM Status](#44-ndb-status--ndb_mgm-status)
	- [SQL Manipulation Data](#45-sql-manipulation-data)
	- [SQL Manipulation Data when Some API OFF](#46-sql-manipulation-data-when-some-api-off)
	- [Load Balancer ProxySQL](#47-load-balancer-proxysql)
	- [ProxySQL with SQLYog](#48-proxysql-with-sqlyog)
5. [Referensi](#5-referensi)

## 1. Check-Plugin Active

![](/tugas_2_implementasi-partisi/screenshoot/create_databases_tugas2)

Menambahkan database baru ``tugas2`` pada service.

![](/tugas_2_implementasi-partisi/screenshoot/permission_userbdt_fordatabasetugas2)

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

![](/tugas_2_implementasi-partisi/screenshoot/check_support_partitioning)

## 2. Create Partition

### 2.1 Range Partition

### 2.2 List Partition

### 2.3 Hash Partition

### 2.4 Key Partition