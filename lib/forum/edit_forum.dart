import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'forum_screen.dart';
import 'models/forum_model.dart';

class EditForumForm extends StatefulWidget {
  final Forum forum;

  const EditForumForm({super.key, required this.forum});

  @override
  State<EditForumForm> createState() => _EditForumFormState();
}

class _EditForumFormState extends State<EditForumForm> {
  final _formKey = GlobalKey<FormState>();

  // Variabel penampung data input
  late String _title;
  late String _content;

  @override
  void initState() {
    super.initState();

    // Isi nilai awal dari forum yang hendak diedit
    _title = widget.forum.fields.title;
    _content = widget.forum.fields.content;
  }

  @override
  Widget build(BuildContext context) {
    // Ambil CookieRequest dari provider
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Form Edit Forum',
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Field title
                TextFormField(
                  initialValue: _title,
                  decoration: InputDecoration(
                    hintText: "Title",
                    labelText: "Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _title = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Title tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Field content
                TextFormField(
                  initialValue: _content,
                  decoration: InputDecoration(
                    hintText: "Description/Content",
                    labelText: "Description/Content",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  minLines: 3,
                  maxLines: 5,
                  onChanged: (String? value) {
                    setState(() {
                      _content = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Content tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tombol SAVE
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Panggil endpoint edit forum di Django
                        final response = await request.postJson(
                          // Ganti URL di bawah sesuai urls.py Anda
                          "http://127.0.0.1:8000/edit-forum-flutter/",
                          jsonEncode(<String, String>{
                            'title': _title,
                            'content': _content,
                          }),
                        );

                        if (context.mounted) {
                          // Jika sukses, Django akan mengembalikan diskusi atau data yang diedit
                          // Ubah pengecekan sesuai output respons di views.py
                          if (response['discussion'] != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Forum berhasil diupdate!"),
                              ),
                            );
                            // Arahkan kembali ke halaman ForumScreen (atau halaman lain sesuai kebutuhan)
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForumScreen(),
                              ),
                            );
                          } else if (response['error'] != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: ${response['error']}"),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Terdapat kesalahan, silakan coba lagi."),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
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
