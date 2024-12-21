// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ngandung_mobile/landing/home_screen.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RumahMakanFormPage extends StatefulWidget {
  const RumahMakanFormPage({super.key});

  @override
  State<RumahMakanFormPage> createState() => _RumahMakanFormPageState();
}

class _RumahMakanFormPageState extends State<RumahMakanFormPage> {
  final _formKey = GlobalKey<FormState>();
  int _kodeProv = 0;
  String _namaProv = "";
  int _bpsKode = 0;
  String _bpsNama = "";
  String _namaRumahMakan = "";
  String _alamat = "";
  String _latitude = "";
  String _longitude = "";
  int _tahun = 0;
  String _masakanDari = "";
  String _jenisMakanan = "";

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Rumah Makan"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input Kode Provinsi
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Kode Provinsi",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _kodeProv = int.tryParse(value)!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Kode Provinsi tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input Nama Rumah Makan
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Nama Rumah Makan",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _namaRumahMakan = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Nama Rumah Makan tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input Alamat
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Alamat",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _alamat = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Alamat tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input Nama Provinsi
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Nama Provinsi",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _namaProv = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Nama Provinsi tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input BPS Kode Kabupaten/Kota
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "BPS Kode Kabupaten/Kota",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _bpsKode = int.tryParse(value)!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "BPS Kode tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input Nama Kabupaten/Kota
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "BPS Nama Kabupaten/Kota",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _bpsNama = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "BPS Nama tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input Latitude
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Latitude",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _latitude = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Latitude tidak boleh kosong";
                    }
                    if (double.tryParse(value) == null) {
                      return "Latitude harus berupa angka";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input Longitude
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Longitude",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _longitude = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Longitude tidak boleh kosong";
                    }
                    if (double.tryParse(value) == null) {
                      return "Longitude harus berupa angka";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input Tahun
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Tahun",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _tahun = int.tryParse(value)!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Tahun tidak boleh kosong";
                    }
                    if (int.tryParse(value) == null) {
                      return "Tahun harus berupa angka";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input Masakan Dari Mana
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Masakan Dari Mana",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _masakanDari = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Masakan Dari Mana tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input Jenis Makanan
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Jenis Makanan",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _jenisMakanan = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Jenis Makanan tidak boleh kosong";
                    }
                    if (value != 'semua' &&
                        value != 'berat' &&
                        value != 'ringan') {
                      return "Cantumkan jenis makanan yang benar!";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Tombol Submit
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (!request.loggedIn) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Anda harus login terlebih dahulu!"),
                            ),
                          );
                          return;
                        }
                        final response = await request.postJson(
                          "http://127.0.0.1:8000/add-rumahmakan/",
                          jsonEncode(<String, dynamic>{
                            "kode_provinsi": _kodeProv,
                            "nama_provinsi": _namaProv,
                            "bps_kode_kabupaten_kota": _bpsKode,
                            "bps_nama_kabupaten_kota": _bpsNama,
                            "nama_rumah_makan": _namaRumahMakan,
                            "alamat": _alamat,
                            "latitude": _latitude,
                            "longitude": _longitude,
                            "tahun": _tahun,
                            "masakan_dari_mana": _masakanDari,
                            "makanan_berat_ringan": _jenisMakanan,
                          }),
                        );
                        if (mounted) {
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Rumah Makan berhasil ditambahkan")),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Gagal menambahkan Rumah Makan baru")),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Tambahkan",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
