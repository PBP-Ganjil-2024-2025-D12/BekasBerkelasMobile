import 'dart:convert';
import 'package:bekas_berkelas_mobile/user_dashboard/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bekas_berkelas_mobile/user_dashboard/widgets/button.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  ChangeEmailPageState createState() => ChangeEmailPageState();
}

class ChangeEmailPageState extends State<ChangeEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final String baseUrl = 'http://10.0.2.2:8000/dashboard';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm(CookieRequest request) async {
    if (_formKey.currentState!.validate()) {
      String newEmail = _emailController.text;

      final data = jsonEncode({
        'email': newEmail,
      });

      final response = await request.post('$baseUrl/update_profile_flutter/', data);

      if (!mounted) return;

      if (response['status'] == 'success') {
        _showSnackbar(context, 'Email berhasil diubah');
      } else {
        _showSnackbar(context, 'Gagal mengubah Email: ${response['message']}');
      }

      Navigator.pop(context, newEmail);
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
    CookieRequest request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Email'),
      ),
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
                    return 'Email tidak boleh kosong';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Masukkan email yang valid';
                  }
                  return null;
                },
                text: 'Email Baru', 
                controller: _emailController),
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