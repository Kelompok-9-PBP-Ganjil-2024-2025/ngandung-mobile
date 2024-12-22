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

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.orange),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.orange, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tambah Rumah Makan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange.shade600,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Detail Rumah Makan",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section: Informasi Utama
                      const Text(
                        "Informasi Utama",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Nama Rumah Makan",
                        hint: "Masukkan nama rumah makan",
                        icon: Icons.restaurant,
                        onChanged: (value) => _namaRumahMakan = value,
                        validator: (value) =>
                            value?.isEmpty == true ? "Nama Rumah Makan tidak boleh kosong" : null,
                      ),
                      _buildInputField(
                        label: "Alamat",
                        hint: "Masukkan alamat lengkap",
                        icon: Icons.location_on,
                        onChanged: (value) => _alamat = value,
                        validator: (value) =>
                            value?.isEmpty == true ? "Alamat tidak boleh kosong" : null,
                      ),

                      // Section: Informasi Lokasi
                      const SizedBox(height: 24),
                      const Text(
                        "Informasi Lokasi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Kode Provinsi",
                        hint: "Masukkan kode provinsi",
                        icon: Icons.numbers,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _kodeProv = int.tryParse(value) ?? 0,
                        validator: (value) =>
                            value?.isEmpty == true ? "Kode Provinsi tidak boleh kosong" : null,
                      ),
                      _buildInputField(
                        label: "Nama Provinsi",
                        hint: "Masukkan nama provinsi",
                        icon: Icons.location_city,
                        onChanged: (value) => _namaProv = value,
                        validator: (value) =>
                            value?.isEmpty == true ? "Nama Provinsi tidak boleh kosong" : null,
                      ),
                      _buildInputField(
                        label: "BPS Kode Kabupaten/Kota",
                        hint: "Masukkan kode BPS",
                        icon: Icons.code,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _bpsKode = int.tryParse(value) ?? 0,
                        validator: (value) =>
                            value?.isEmpty == true ? "BPS Kode tidak boleh kosong" : null,
                      ),
                      _buildInputField(
                        label: "BPS Nama Kabupaten/Kota",
                        hint: "Masukkan nama kabupaten/kota",
                        icon: Icons.location_city,
                        onChanged: (value) => _bpsNama = value,
                        validator: (value) =>
                            value?.isEmpty == true ? "BPS Nama tidak boleh kosong" : null,
                      ),

                      // Section: Koordinat
                      const SizedBox(height: 24),
                      const Text(
                        "Koordinat Lokasi",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              label: "Latitude",
                              hint: "Masukkan latitude",
                              icon: Icons.explore,
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _latitude = value,
                              validator: (value) {
                                if (value?.isEmpty == true) return "Latitude tidak boleh kosong";
                                if (double.tryParse(value!) == null) return "Latitude harus berupa angka";
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInputField(
                              label: "Longitude",
                              hint: "Masukkan longitude",
                              icon: Icons.explore,
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _longitude = value,
                              validator: (value) {
                                if (value?.isEmpty == true) return "Longitude tidak boleh kosong";
                                if (double.tryParse(value!) == null) return "Longitude harus berupa angka";
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      // Section: Informasi Tambahan
                      const SizedBox(height: 24),
                      const Text(
                        "Informasi Tambahan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Tahun",
                        hint: "Masukkan tahun",
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _tahun = int.tryParse(value) ?? 0,
                        validator: (value) {
                          if (value?.isEmpty == true) return "Tahun tidak boleh kosong";
                          if (int.tryParse(value!) == null) return "Tahun harus berupa angka";
                          return null;
                        },
                      ),
                      _buildInputField(
                        label: "Masakan Dari",
                        hint: "Masukkan asal masakan",
                        icon: Icons.food_bank,
                        onChanged: (value) => _masakanDari = value,
                        validator: (value) =>
                            value?.isEmpty == true ? "Masakan Dari tidak boleh kosong" : null,
                      ),
                      _buildInputField(
                        label: "Jenis Makanan",
                        hint: "Masukkan jenis makanan (semua/berat/ringan)",
                        icon: Icons.restaurant_menu,
                        onChanged: (value) => _jenisMakanan = value,
                        validator: (value) {
                          if (value?.isEmpty == true) return "Jenis Makanan tidak boleh kosong";
                          if (!['semua', 'berat', 'ringan'].contains(value)) {
                            return "Pilih: semua, berat, atau ringan";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (!request.loggedIn) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Anda harus login terlebih dahulu!"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              final response = await request.postJson(
                                "http://daffa-abhipraya-ngandung.pbp.cs.ui.ac.id/add-rumahmakan/",
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
                                      content: Text("Rumah Makan berhasil ditambahkan"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Gagal menambahkan Rumah Makan baru"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            "Tambah Rumah Makan",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}