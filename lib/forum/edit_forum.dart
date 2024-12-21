// edit_forum.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'models/forum_model.dart';
import 'package:http/http.dart' as http;

class EditForumPage extends StatefulWidget {
  final Forum forum;

  const EditForumPage({Key? key, required this.forum}) : super(key: key);

  @override
  State<EditForumPage> createState() => _EditForumPageState();
}

class _EditForumPageState extends State<EditForumPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _content;

  @override
  void initState() {
    super.initState();
    _title = widget.forum.fields.title;
    _content = widget.forum.fields.content;
  }

  Future<void> editForum(CookieRequest request) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final response = await request.postJson(
          "http://10.0.2.2:8000/api/edit-forum-flutter/${widget.forum.pk}/", // Ganti dengan IP yang sesuai
          jsonEncode(<String, String>{
            'title': _title,
            'content': _content,
          }),
        );

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Forum berhasil diupdate!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Kembalikan true untuk menyegarkan ForumScreen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Gagal mengupdate forum."),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Terjadi kesalahan. Silakan coba lagi."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Forum'),
        backgroundColor: const Color(0xFF111111),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Field Title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) {
                    _title = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Title tidak boleh kosong!';
                    }
                    return null;
                  },
                ),
              ),
              // Field Content
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  initialValue: _content,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  onSaved: (value) {
                    _content = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Content tidak boleh kosong!';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Tombol Submit
              ElevatedButton(
                onPressed: () => editForum(request),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9900),
                ),
                child: const Text(
                  "Update",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
