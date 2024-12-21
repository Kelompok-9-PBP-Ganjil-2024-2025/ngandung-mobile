// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ngandung_mobile/landing/home_screen.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class MakananFormPage extends StatefulWidget {
  const MakananFormPage({super.key});

  @override
  State<MakananFormPage> createState() => _MakananFormPageState();
}

class _MakananFormPageState extends State<MakananFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Variabel untuk input
  String _nama = '';
  int _harga = 0;
  String? _selectedRumahMakanId;

  // Data untuk dropdown
  List<dynamic> _rumahMakanList = [];

  @override
  void initState() {
    super.initState();
    final req = CookieRequest();
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
    // print(context.mounted);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Makanan"),
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
                decoration: const InputDecoration(
                  labelText: "Nama Makanan",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _nama = value;
                },
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
                decoration: const InputDecoration(
                  labelText: "Harga Makanan",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _harga = int.tryParse(value) ?? 0;
                },
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
                hint: const Text("Pilih Rumah Makan"),
                items: _rumahMakanList.map((rm) {
                  return DropdownMenuItem<String>(
                    value: rm['id'].toString(),
                    child: Text(rm['nama']),
                  );
                }).toList(),
                onChanged: (value) {
                  if (context.mounted) {
                    setState(() {
                      _selectedRumahMakanId = value;
                    });
                  }
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
                        "http://127.0.0.1:8000/add-makanan-flutter/",
                        jsonEncode(<String, dynamic>{
                          "name": _nama,
                          "price": _harga,
                          "toko_id": _selectedRumahMakanId,
                        }),
                      );
                      if (context.mounted == true) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Makanan berhasil ditambahkan")),
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
                                content: Text("Gagal menambahkan makanan")),
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
    );
  }
}
