// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';

class MakananFormPage extends StatefulWidget {
  const MakananFormPage({super.key});

  @override
  State<MakananFormPage> createState() => _MakananFormPageState();
}

class _MakananFormPageState extends State<MakananFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();

  // Data untuk dropdown
  List<dynamic> _rumahMakanList = [];
  String? _selectedRumahMakanId;

  @override
  void initState() {
    super.initState();
    final req =
        CookieRequest(); // Gunakan CookieRequest dari context jika sudah terhubung dengan Provider
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

  void _submitForm() async {
    final nama = _namaController.text;
    final harga = int.parse(_hargaController.text);
    final rumahMakanId = _selectedRumahMakanId;

    try {
      final response = await fetchAddMakanan(nama, harga, rumahMakanId!);

      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Makanan berhasil ditambahkan")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(response['message'] ?? "Gagal menambahkan makanan")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<Map<String, dynamic>> fetchAddMakanan(
    String nama,
    int harga,
    String rumahMakanId,
  ) async {
    final url = Uri.parse("http://127.0.0.1:8000/add-makanan-ajax/");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "name": nama,
        "price": harga.toString(),
        "toko_id": rumahMakanId,
      },
    );

    if (response.statusCode == 201) {
      return {"success": true, "message": "Makanan berhasil ditambahkan"};
    } else {
      final responseBody = response.body;
      return {
        "success": false,
        "message": responseBody.isNotEmpty
            ? responseBody
            : "Terjadi kesalahan saat menambahkan makanan"
      };
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }
}
