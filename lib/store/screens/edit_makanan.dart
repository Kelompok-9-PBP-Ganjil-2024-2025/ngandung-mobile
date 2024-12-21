// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ngandung_mobile/landing/home_screen.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

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
        _selectedRumahMakanId = response['rumah_makan']['id'].toString();
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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input Nama Makanan
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
                },
              ),
              const SizedBox(height: 16),

              // Input Harga Makanan
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(
                  labelText: "Harga Makanan",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final harga = int.tryParse(value ?? '') ?? 0;
                  if (harga <= 0) {
                    return "Harga makanan harus lebih besar dari 0";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown Rumah Makan
              DropdownButtonFormField<String>(
                value: _selectedRumahMakanId,
                hint: const Text("Pilih Rumah Makan"),
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (!request.loggedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Anda harus login terlebih dahulu!"),
                          ),
                        );
                        return;
                      }
                      final response = await request.postJson(
                        "http://127.0.0.1:8000/edit-detail-makanan/${widget.id}/",
                        jsonEncode(<String, dynamic>{
                          "name": _namaController.text,
                          "price": int.parse(_hargaController.text),
                          "toko_id": _selectedRumahMakanId,
                        }),
                      );
                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Makanan berhasil diperbarui")),
                          );
                          Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Gagal memperbarui makanan")),
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
                    "Perbarui",
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
}
