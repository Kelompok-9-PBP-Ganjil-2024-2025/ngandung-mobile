// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';

class EditMakananPage extends StatefulWidget {
  final int id;
  const EditMakananPage({super.key, required this.id});

  @override
  State<EditMakananPage> createState() => _EditMakananPageState();
}

class _EditMakananPageState extends State<EditMakananPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  String? _selectedRumahMakanId;
  List<dynamic> _rumahMakanList = [];

  @override
  void initState() {
    super.initState();
    final req = CookieRequest();
    _loadMakananDetail(req, widget.id);
    fetchListRumahMakan(req).then((data) {
      setState(() {
        _rumahMakanList = data;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat data rumah makan: $error")),
      );
    });
  }

  Future<void> _loadMakananDetail(CookieRequest req, int id) async {
    try {
      final response =
          await req.get('http://127.0.0.1:8000/get-detail-makanan/$id/');
      setState(() {
        _namaController.text = response['name'];
        _hargaController.text = response['price'].toString();
        _selectedRumahMakanId = response['rumah_makan'].toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error memuat detail makanan")),
      );
    }
  }

  Future<List<dynamic>> fetchListRumahMakan(CookieRequest req) async {
    try {
      final response = await req.get('http://127.0.0.1:8000/list-rumahmakan/');
      return response as List<dynamic>;
    } catch (e) {
      throw Exception("Error fetching rumah makan: $e");
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/update-makanan/${widget.id}/'),
        body: {
          'nama': _namaController.text,
          'harga': int.parse(_hargaController.text),
          'rumah_makan_id': _selectedRumahMakanId,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Makanan berhasil diperbarui")),
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
        title: const Text("Edit Makanan"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nama Makanan
              TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: "Nama Makanan",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Nama makanan tidak boleh kosong";
                    }
                    return null;
                  }),
              const SizedBox(height: 16),

              // Harga
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(
                  labelText: "Harga",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Harga makanan tidak boleh kosong";
                  }
                  if (int.tryParse(value) == null) {
                    return "Harga harus berupa angka";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown Rumah Makan
              DropdownButtonFormField<String>(
                value: _selectedRumahMakanId,
                items: _rumahMakanList.map((rm) {
                  return DropdownMenuItem<String>(
                    value: rm['id'].toString(),
                    child: Text(rm['nama']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRumahMakanId = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Rumah Makan",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null) {
                    return "Silakan pilih rumah makan";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Tombol Submit
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _submitForm();
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
                    "Simpan Perubahan",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }
}
