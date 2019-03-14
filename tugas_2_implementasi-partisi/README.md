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

### 2.1 Range Partition

### 2.2 List Partition

### 2.3 Hash Partition

### 2.4 Key Partition