// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';

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
  final TextEditingController _rumahMakanNameController =
      TextEditingController();
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
      final response =
          await req.get('http://127.0.0.1:8000/get-detail-rumahmakan/$id/');
      setState(() {
        _kodeProvController.text = response['kode_provinsi'].toString();
        _namaProvController.text = response['nama_provinsi'];
        _bpsKodeController.text =
            response['bps_kode_kabupaten_kota'].toString();
        _bpsNamaController.text = response['bps_nama_kabupaten_kota'];
        _rumahMakanNameController.text = response['nama_rumah_makan'];
        _addressController.text = response['alamat'];
        _latitudeController.text = response['latitude'].toString();
        _longitudeController.text = response['longitude'].toString();
        _yearController.text = response['tahun'];
        _masakanDariController.text = response['masakan_dari_mana'];
        _jenisMakananController.text = response['makanan_berat_ringan'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error memuat detail rumah makan")),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/update-makanan/${widget.id}/'),
        body: {
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
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data Rumah Makan berhasil diperbarui")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  controller: _kodeProvController,
                  decoration: const InputDecoration(
                    labelText: "Kode Provinsi",
                    border: OutlineInputBorder(),
                  ),
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
                  controller: _rumahMakanNameController,
                  decoration: const InputDecoration(
                    labelText: "Nama Rumah Makan",
                    border: OutlineInputBorder(),
                  ),
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
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: "Alamat",
                    border: OutlineInputBorder(),
                  ),
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
                  controller: _namaProvController,
                  decoration: const InputDecoration(
                    labelText: "Nama Provinsi",
                    border: OutlineInputBorder(),
                  ),
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
                  controller: _bpsKodeController,
                  decoration: const InputDecoration(
                    labelText: "BPS Kode Kabupaten/Kota",
                    border: OutlineInputBorder(),
                  ),
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
                  controller: _bpsNamaController,
                  decoration: const InputDecoration(
                    labelText: "BPS Nama Kabupaten/Kota",
                    border: OutlineInputBorder(),
                  ),
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
                  controller: _latitudeController,
                  decoration: const InputDecoration(
                    labelText: "Latitude",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
                  controller: _longitudeController,
                  decoration: const InputDecoration(
                    labelText: "Longitude",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
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
                  controller: _yearController,
                  decoration: const InputDecoration(
                    labelText: "Tahun",
                    border: OutlineInputBorder(),
                  ),
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
                  controller: _masakanDariController,
                  decoration: const InputDecoration(
                    labelText: "Masakan Dari Mana",
                    border: OutlineInputBorder(),
                  ),
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
                  controller: _jenisMakananController,
                  decoration: const InputDecoration(
                    labelText: "Jenis Makanan",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Jenis Makanan tidak boleh kosong";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Tombol Submit
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
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

  @override
  void dispose() {
    _kodeProvController.dispose();
    _namaProvController.dispose();
    _bpsKodeController.dispose();
    _bpsNamaController.dispose();
    _rumahMakanNameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _masakanDariController.dispose();
    _jenisMakananController.dispose();
    super.dispose();
  }
}
