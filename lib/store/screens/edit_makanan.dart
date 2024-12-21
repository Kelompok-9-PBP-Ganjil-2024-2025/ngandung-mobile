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
        SnackBar(
          content: Text("Gagal memuat data rumah makan: $error"),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  Future<void> _loadMakananDetail(CookieRequest req, int id) async {
    try {
      final response = await req.get('http://127.0.0.1:8000/get-detail-makanan/$id/');
      setState(() {
        _namaController.text = response['name'];
        _hargaController.text = response['price'].toString();
        _selectedRumahMakanId = response['rumah_makan']['id'].toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error memuat detail makanan"),
          backgroundColor: Colors.red,
        ),
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
        title: const Text(
          "Edit Makanan",
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
                        "Edit Detail Makanan",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _namaController,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Nama makanan tidak boleh kosong";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _hargaController,
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
                        validator: (value) {
                          final harga = int.tryParse(value ?? '') ?? 0;
                          if (harga <= 0) {
                            return "Harga makanan harus lebih besar dari 0";
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
                          setState(() {
                            _selectedRumahMakanId = value;
                          });
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
                                      content: Text("Makanan berhasil diperbarui"),
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
                                      content: Text("Gagal memperbarui makanan"),
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
                            "Perbarui Makanan",
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