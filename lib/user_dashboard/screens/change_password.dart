import 'dart:convert';
import 'package:bekas_berkelas_mobile/user_dashboard/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ChangePasswordPageState createState() => ChangePasswordPageState();
}

class ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final String baseUrl = 'http://10.0.2.2:8000/dashboard';

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm(CookieRequest request) async {
    if (_formKey.currentState!.validate()) {
      String oldPassword = _oldPasswordController.text;
      String newPassword1 = _passwordController.text;
      String newPassword2 = _confirmPasswordController.text;

      final data = jsonEncode({
        'old_password': oldPassword,
        'new_password1': newPassword1,
        'new_password2': newPassword2,
      });
    
      final response = await request.post('$baseUrl/change_password_flutter/', data);
      if (!mounted) return;

      if (response['status'] == 'success') {
        _showSnackbar(context, 'Password berhasil diubah');
      } else {
        _showSnackbar(context, 'Gagal mengubah password: ${response['message']}');
      }

      Navigator.pop(context);
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _oldPasswordController,
                cursorColor: const Color.fromARGB(255, 9, 68, 127),
                decoration: const InputDecoration(
                  labelText: 'Password Lama',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 9, 68, 127)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 9, 68, 127)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 9, 68, 127)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)
                  )
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                cursorColor: const Color.fromARGB(255, 9, 68, 127),
                decoration: const InputDecoration(
                  labelText: 'Password Baru',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 9, 68, 127)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 9, 68, 127)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 9, 68, 127)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)
                  )
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  } else if (value.length < 6) {
                    return 'Password harus terdiri dari minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,cursorColor: const Color.fromARGB(255, 9, 68, 127),
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  labelStyle: TextStyle(color: Color.fromARGB(255, 9, 68, 127)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 9, 68, 127)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 9, 68, 127)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)
                  )
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password tidak boleh kosong';
                  } else if (value != _passwordController.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: SubmitButton(onPressed: () => _submitForm(request), text: 'Simpan')
              ),
            ],
          ),
        ),
      ),
    );
  }
}