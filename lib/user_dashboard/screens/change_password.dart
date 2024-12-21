import 'dart:convert';
import 'package:bekas_berkelas_mobile/user_dashboard/widgets/button.dart';
import 'package:bekas_berkelas_mobile/user_dashboard/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';

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

      final response =
          await request.post('$baseUrl/change_password_flutter/', data);
      if (!mounted) return;

      if (response['status'] == 'success') {
        _showSnackbar(context, 'Password berhasil diubah');
      } else {
        _showSnackbar(
            context, 'Gagal mengubah password: ${response['message']}');
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
      appBar: appBar(context, 'Ubah Password', true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  }
                  return null;
                }, 
                text: 'Password Lama', 
                controller: _oldPasswordController
              ),
              const SizedBox(height: 20),
              InputTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password tidak boleh kosong';
                  } else if (value.length < 6) {
                    return 'Password harus terdiri dari minimal 6 karakter';
                  }
                  return null;
                }, 
                text: 'Password Baru', 
                controller: _passwordController
              ),
              const SizedBox(height: 20),
              InputTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password tidak boleh kosong';
                  } else if (value != _passwordController.text) {
                    return 'Password tidak cocok';
                  }
                  return null;
                },
                text: "Konfirmasi Password Baru", 
                controller: _confirmPasswordController
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
