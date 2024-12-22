// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ngandung_mobile/authentication/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class LogoutButton extends StatefulWidget {
  const LogoutButton({super.key});

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  bool _isExpanded = false;

  void _logout(BuildContext context) async {
    final req = context.read<CookieRequest>();
    final response = await req.logout("http://127.0.0.1:8000/auth/logout/");
    String message = response["message"];
    if (context.mounted) {
      if (response['status']) {
        String uname = response["username"];
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("$message Sampai jumpa, $uname."),
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _isExpanded = !_isExpanded;
        });

        // Tunggu animasi selesai sebelum logout
        await Future.delayed(const Duration(milliseconds: 300));
        if (_isExpanded) {
          _logout(context);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _isExpanded ? 150 : 56, // Lebar tombol saat expand atau normal
        height: 56, // Tinggi tetap
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(28), // Bentuk lingkaran atau oval
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Colors.white),
            if (_isExpanded) ...[
              const SizedBox(width: 8), // Spasi antara icon dan tulisan
              const Flexible(
                child: Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // Potong teks jika overflow
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
