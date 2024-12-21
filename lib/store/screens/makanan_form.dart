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
  String _nama = '';
  int _harga = 0;
  String? _selectedRumahMakanId;
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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tambah Makanan",
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
                        "Detail Makanan",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Nama Makanan",
                          hintText: "Masukkan nama makanan",
                          prefixIcon: const Icon(Icons.restaurant_menu, color: Colors.orange),
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
                        onChanged: (value) => _nama = value,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Nama makanan tidak boleh kosong";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Harga Makanan",
                          hintText: "Masukkan harga makanan",
                          prefixIcon: const Icon(Icons.attach_money, color: Colors.orange),
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
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _harga = int.tryParse(value) ?? 0,
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
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedRumahMakanId,
                        hint: const Text("Pilih Rumah Makan"),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.store, color: Colors.orange),
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
                        validator: (value) {
                          if (value == null) {
                            return "Silakan pilih rumah makan";
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
                                "http://127.0.0.1:8000/add-makanan-flutter/",
                                jsonEncode(<String, dynamic>{
                                  "name": _nama,
                                  "price": _harga,
                                  "toko_id": _selectedRumahMakanId,
                                }),
                              );
                              if (context.mounted) {
                                if (response['status'] == 'success') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Makanan berhasil ditambahkan"),
                                      backgroundColor: Colors.green,
                                    ),
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
                                      content: Text("Gagal menambahkan makanan"),
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
                            "Tambahkan Makanan",
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