import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ngandung_mobile/landing/home_screen.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditRumahMakanPage extends StatefulWidget {
  final int id;
  const EditRumahMakanPage({super.key, required this.id});

  @override
  State<EditRumahMakanPage> createState() => _EditRumahMakanPageState();
}

class _EditRumahMakanPageState extends State<EditRumahMakanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _kodeProvController = TextEditingController();
  final TextEditingController _namaProvController = TextEditingController();
  final TextEditingController _bpsKodeController = TextEditingController();
  final TextEditingController _bpsNamaController = TextEditingController();
  final TextEditingController _rumahMakanNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _masakanDariController = TextEditingController();
  final TextEditingController _jenisMakananController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final req = CookieRequest();
    _loadRumahMakanDetail(req, widget.id);
  }

  Future<void> _loadRumahMakanDetail(CookieRequest req, int id) async {
    try {
      final response = await req.get('http://127.0.0.1:8000/get-detail-rumahmakan/$id/');
      setState(() {
        _kodeProvController.text = response['kode_provinsi'].toString();
        _namaProvController.text = response['nama_provinsi'];
        _bpsKodeController.text = response['bps_kode_kabupaten_kota'].toString();
        _bpsNamaController.text = response['bps_nama_kabupaten_kota'];
        _rumahMakanNameController.text = response['nama_rumah_makan'];
        _addressController.text = response['alamat'];
        _latitudeController.text = response['latitude'].toString();
        _longitudeController.text = response['longitude'].toString();
        _yearController.text = response['tahun'].toString();
        _masakanDariController.text = response['masakan_dari_mana'];
        _jenisMakananController.text = response['makanan_berat_ringan'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error memuat detail rumah makan"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
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
          "Edit Rumah Makan",
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

                      // Informasi Utama
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
                        controller: _rumahMakanNameController,
                        validator: (value) => value?.isEmpty == true ? "Nama Rumah Makan tidak boleh kosong" : null,
                      ),
                      _buildInputField(
                        label: "Alamat",
                        hint: "Masukkan alamat lengkap",
                        icon: Icons.location_on,
                        controller: _addressController,
                        validator: (value) => value?.isEmpty == true ? "Alamat tidak boleh kosong" : null,
                      ),

                      // Informasi Lokasi
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
                        controller: _kodeProvController,
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty == true ? "Kode Provinsi tidak boleh kosong" : null,
                      ),
                      _buildInputField(
                        label: "Nama Provinsi",
                        hint: "Masukkan nama provinsi",
                        icon: Icons.location_city,
                        controller: _namaProvController,
                        validator: (value) => value?.isEmpty == true ? "Nama Provinsi tidak boleh kosong" : null,
                      ),
                      _buildInputField(
                        label: "BPS Kode Kabupaten/Kota",
                        hint: "Masukkan kode BPS",
                        icon: Icons.code,
                        controller: _bpsKodeController,
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty == true ? "BPS Kode tidak boleh kosong" : null,
                      ),
                      _buildInputField(
                        label: "BPS Nama Kabupaten/Kota",
                        hint: "Masukkan nama kabupaten/kota",
                        icon: Icons.location_city,
                        controller: _bpsNamaController,
                        validator: (value) => value?.isEmpty == true ? "BPS Nama tidak boleh kosong" : null,
                      ),

                      // Koordinat
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
                              controller: _latitudeController,
                              keyboardType: TextInputType.number,
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
                              controller: _longitudeController,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value?.isEmpty == true) return "Longitude tidak boleh kosong";
                                if (double.tryParse(value!) == null) return "Longitude harus berupa angka";
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      // Informasi Tambahan
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
                        controller: _yearController,
                        keyboardType: TextInputType.number,
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
                        controller: _masakanDariController,
                        validator: (value) => value?.isEmpty == true ? "Masakan Dari tidak boleh kosong" : null,
                      ),
                      _buildInputField(
                        label: "Jenis Makanan",
                        hint: "Masukkan jenis makanan (semua/berat/ringan)",
                        icon: Icons.restaurant_menu,
                        controller: _jenisMakananController,
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
                                "http://127.0.0.1:8000/edit-detail-rumahmakan/${widget.id}/",
                                jsonEncode(<String, dynamic>{
                                  'kode_provinsi': _kodeProvController.text,
                                  'nama_provinsi': _namaProvController.text,
                                  'bps_kode_kabupaten_kota': _bpsKodeController.text,
                                  'bps_nama_kabupaten_kota': _bpsNamaController.text,
                                  'nama_rumah_makan': _rumahMakanNameController.text,
                                  'alamat': _addressController.text,
                                  'latitude': _latitudeController.text,
                                  'longitude': _longitudeController.text,
                                  'tahun': _yearController.text,
                                  'masakan_dari_mana': _masakanDariController.text,
                                  'makanan_berat_ringan': _jenisMakananController.text,
                                }),
                              );
                              if (mounted) {
                                if (response['status'] == 'success') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Rumah Makan berhasil diperbarui"),
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
                                      content: Text("Gagal memperbarui Rumah Makan"),
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
                            "Perbarui Rumah Makan",
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