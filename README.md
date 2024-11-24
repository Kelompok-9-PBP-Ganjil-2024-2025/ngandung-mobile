## Ngandung Mobile (Ngemil di Bandung)

### Daftar Isi

1. [Nama-nama anggota kelompok](#1-nama-nama-anggota-kelompok)
2. [Deskripsi aplikasi](#2-deskripsi-aplikasi)
3. [Daftar modul aplikasi](#3-daftar-modul-aplikasi)
4. [_Role_ pengguna (_User_ dan _Admin_)](#4-role-pengguna-user-dan-admin)
5. [Alur pengintegrasian dengan _web service_](#5-alur-pengintegrasian-dengan-web-service)

### 1. Nama-nama anggota kelompok

-   Ahmad Dzulfikar As Shavy (2306152374) - `AhmadDzulfikar`
-   Christian Raphael Heryanto (2306152323) - `papaChick`
-   Daffa Abhipraya Putra (2306245131) - `absolutepraya`
-   Muhammad Radhiya Arshq (2306275885) - `arshqiii`
-   Rayhan Syahdira Putra (2306275903) - `RayhanSP`

### 2. Deskripsi aplikasi

Ngandung adalah aplikasi berbasis web yang menyediakan informasi lengkap tentang makanan dan toko-toko di kota tertentu. Aplikasi ini dirancang untuk memudahkan pengguna yang baru pindah atau berkunjung ke kota tersebut dalam menemukan berbagai jenis makanan dan tempat membelinya. Pengguna dapat mencari makanan berdasarkan kategori, melihat daftar rekomendasi, memberikan rating serta ulasan untuk toko, dan menyimpan toko favorit mereka. Admin memiliki kemampuan untuk menambahkan dan mengelola data makanan dan toko yang tersedia, sementara pengguna biasa dapat mengakses informasi dan memberikan ulasan. Ngandung bertujuan untuk memberikan solusi praktis dalam mencari makanan di kota baru dengan mudah dan cepat.

### 3. Daftar modul aplikasi

#### a. Modul/fitur wajib:

-   _**Authentication**_ **and** _**Authorization**_  
    Modul ini berfungsi untuk mengatur _authentication_ pengguna. Pengguna dapat mendaftar, masuk, dan keluar dari aplikasi.

-   **Implementasi fixture data toko, makanan, dan admin**  
    Modul ini berfungsi untuk mengisi data awal ke dalam database. Data awal yang dimasukkan berupa data makanan dan data toko.

#### b. Modul/fitur aplikasi:

-   **Daftar Makanan & Toko**  
    Modul ini berfungsi untuk menampilkan daftar makanan yang tersedia, menambahkan makanan baru, dan menambahkan toko baru.

    **_Dikerjakan oleh:_** Muhammad Radhiya Arshq

-   **_Rating_ & _Review_ Toko**  
    Modul ini berfungsi untuk memberikan _rating_ & _review_ ke toko yang tersedia.

    **_Dikerjakan oleh:_** Daffa Abhipraya Putra

-   **Toko Favorit**  
    Modul ini berfungsi untuk menyimpan toko yang disukai oleh pengguna.

    **_Dikerjakan oleh:_** Rayhan Syahdira Putra

-   **Forum Diskusi Makanan**  
    Modul ini berfungsi untuk memberikan ruang diskusi global kepada pengguna untuk berbagi informasi tentang makanan.

    **_Dikerjakan oleh:_** Ahmad Dzulfikar As Shavy

-   **Polling Makanan Terenak**  
    Modul ini berfungsi untuk memberikan polling makanan terenak yang ada di Kota Bandung.

    **_Dikerjakan oleh:_** Christian Raphael Heryanto

### 4. **Role** pengguna (_User_ dan _Admin_)

| No. | Modul                   | _Permission User_                                                                                                                                       | _Permission Admin_                                                                                                                                  |
| --- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | Daftar Makanan & Toko   | Pengguna dapat mengakses informasi makanan yang tersedia di aplikasi, serta toko yang menjual makanan tersebut, tanpa dapat mengubah atau menghapusnya. | Admin memiliki permission sama seperti user, ditambah admin juga dapat menghapus dan menambah toko & makanannya                                     |
| 2   | Rating & Review Toko    | Pengguna dapat memberikan rating dengan range 1-5 dan review berupa teks singkat ke toko yang tersedia.                                                 | Admin memiliki permission sama seperti user, ditambah admin juga dapat menghapus rating dan review yang tidak sesuai dengan ketentuan yang berlaku. |
| 3   | Toko Favorit            | Pengguna dapat menyimpan toko yang disukai ke 'Toko Favorit' yang dimiliki setiap akun pengguna.                                                        | Admin memiliki permission sama seperti user.                                                                                                        |
| 4   | Forum Diskusi Makanan   | Pengguna dapat menggunakan ruang diskusi global untuk berdiskusi tentang makanan. Pengguna juga bisa mengedit, menghapus                                | Admin memiliki permission sama seperti user, ditambah admin dapat menghapus diskusi yang tidak sesuai dengan ketentuan yang berlaku.                |
| 5   | Polling Makanan Terenak | Pengguna dapat memberikan suaranya untuk sebuah makanan.                                                                                                | Admin memiliki permission sama seperti user.                                                                                                        |

### 5. Alur pengintegrasian dengan **_web service_**

1. **_Authentication_**
    1. Modul autentikasi akan menggunakan BE dari Ngandung dengan Framework Django. Pengguna akan melakukan registrasi dan login di BE, kemudian BE akan memberikan token kepada pengguna yang akan digunakan untuk mengakses API.
    2. Akan dilakukan modifikasi pada `views.py` dan `urls.py` di app `/authentication` untuk menambahkan autentikasi yang dibutuhkan.

2. **_Daftar Makanan & Toko_**
    1. Modul ini akan menggunakan BE dari Ngandung dengan Framework Django. Pengguna akan mengakses API yang disediakan oleh BE untuk mendapatkan data makanan dan toko.
    2. Akan dilakukan modifikasi pada `views.py` dan `urls.py` di app `/toko_makanan` untuk menambahkan API yang dibutuhkan. 
    3. Modifikasi tersebut dapat berupa adaptasi ke JSON response, dan adaptasi beberapa HTTP method lainnya. 

3. **_Rating & Review Toko_**
    1. Modul ini akan menggunakan BE dari Ngandung dengan Framework Django. Pengguna akan mengakses API yang disediakan oleh BE untuk memberikan rating dan review ke toko.
    2. Akan dilakukan modifikasi pada `views.py` dan `urls.py` di app `/rating_toko` untuk menambahkan API yang dibutuhkan. 
    3. Modifikasi tersebut dapat berupa adaptasi ke JSON response, dan adaptasi beberapa HTTP method lainnya.

4. **_Toko Favorit_**
    1. Modul ini akan menggunakan BE dari Ngandung dengan Framework Django. Pengguna akan mengakses API yang disediakan oleh BE untuk menyimpan toko favorit.
    2. Akan dilakukan modifikasi pada `views.py` dan `urls.py` di app `/dev_favorite_store` untuk menambahkan API yang dibutuhkan. 
    3. Modifikasi tersebut dapat berupa adaptasi ke JSON response, dan adaptasi beberapa HTTP method lainnya.

5. **_Forum Diskusi Makanan_**
    1. Modul ini akan menggunakan BE dari Ngandung dengan Framework Django. Pengguna akan mengakses API yang disediakan oleh BE untuk berdiskusi tentang makanan.
    2. Akan dilakukan modifikasi pada `views.py` dan `urls.py` di app `/discuss_forum` untuk menambahkan API yang dibutuhkan. 
    3. Modifikasi tersebut dapat berupa adaptasi ke JSON response, dan adaptasi beberapa HTTP method lainnya. 

6. **_Polling Makanan Terenak_**
    1. Modul ini akan menggunakan BE dari Ngandung dengan Framework Django. Pengguna akan mengakses API yang disediakan oleh BE untuk memberikan suara pada makanan.
    2. Akan dilakukan modifikasi pada `views.py` dan `urls.py` di app `/polling` untuk menambahkan API yang dibutuhkan. 
    3. Modifikasi tersebut dapat berupa adaptasi ke JSON response, dan adaptasi beberapa HTTP method lainnya.

7. **_Menerapkan _CORS_ pada BE Django_**
    1. Akan dilakukan modifikasi pada `settings.py` di BE Django untuk menambahkan _CORS_ agar BE dapat diakses oleh FE.

8. **_Implementasi Flutter FE_**
    1. Aplikasi Flutter akan mengakses API yang disediakan oleh BE Django untuk menampilkan data makanan dan toko, memberikan rating dan review, menyimpan toko favorit, berdiskusi tentang makanan, dan memberikan suara pada polling makanan terenak.
    2. Semua dilakukan dengan asynchronus request menggunakan package `http` pada Flutter.
