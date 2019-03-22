# Register and Implementation MongoDB

## Menu Cepat
1. [Register and Implementation](#1-register-and-implementation)
2. [Referensi](#2-referensi)

## 1. Register and Implementation
Sebelum melakukan implementasi, pertama yang harus dilakukan adalah melakukan registrasi mongodb melalui website [MongoDB](https://cloud.mongodb.com/user#/atlas/login).

Setelah melakukan registrasi, ikuti petunjuk untuk melakukan pembuatan cluster, sehingga setelah selesai akan muncul seperti ini :
![](/tugas_3_implementasi-mongodb/screenshoot/mongoregister.PNG)

Selanjutnya adalah melakukan import file data json, pada kasus ini saya menggunakan datases ``starwars`` yang didapatkan dari [Starwars DataSets](https://public.tableau.com/s/sites/default/files/media/starwarscharacterdata.json).
menggunakan cmd :
~~~
mongoimport --host cluster0-shard-00-00-opihd.mongodb.net:27017 --db starwars --type json --file Downloads/starwarscharacterdata.json --jsonArray --authenticationDatabase admin --ssl --username ahmadkikok --password ahmad091170

--host adalah host yang digunakan untuk melakukan import
--db adalah database yang digunakan
--type type yang digunakan, pada kasus ini saya menggunakan json
--file lokasi file dari json
--authenticationDatabase autotentikasi yang digunakan adalah admin
~~~

Sehingga akan menghasilkan seperti ini :
![](/tugas_3_implementasi-mongodb/screenshoot/mongoimport.PNG)

Selanjutnya adalah mencoba melakukan login dan melihat data yang ada melalui ``shell``
![](/tugas_3_implementasi-mongodb/screenshoot/mongoimport_show.PNG)

Selanjutnya adalah mengakses data menggunakan mongodb compass :
![](/tugas_3_implementasi-mongodb/screenshoot/mongo_compass.PNG)

Data yang diimport berhasil ditampilkan dan sukses dimasukan kedalam mongodb.

## 2. Referensi
https://docs.mongodb.com/manual/                                                           
https://public.tableau.com/s/sites/default/files/media/starwarscharacterdata.json           