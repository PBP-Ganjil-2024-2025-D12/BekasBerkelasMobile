import 'dart:convert';
import 'package:bekas_berkelas_mobile/user_dashboard/widgets/button.dart';
import 'package:bekas_berkelas_mobile/user_dashboard/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ChangePhonePage extends StatefulWidget {
  @override
  _ChangePhonePageState createState() => _ChangePhonePageState();
}

class _ChangePhonePageState extends State<ChangePhonePage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final String baseUrl = 'http://10.0.2.2:8000/dashboard';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm(CookieRequest request) async {
    if (_formKey.currentState!.validate()) {
      String newPhoneNum = _phoneController.text;

      final data = jsonEncode({
        'no_telp': newPhoneNum,
      });

      final response = await request.post('$baseUrl/update_profile_flutter/', data);

      if (!mounted) return;

      if (response['status'] == 'success') {
        _showSnackbar(context, 'Nomor Telp berhasil diubah');
      } else {
        _showSnackbar(context, 'Gagal mengubah Nomor Telp: ${response['message']}');
      }

      Navigator.pop(context, newPhoneNum);
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
        title: const Text('Ubah No Telp'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            InputTextField(
              validator:  (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  } else if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                    return 'Masukkan nomor telepon yang valid';
                  }
                  return null;
                }, 
              text: 'No Telp Baru', 
              controller: _phoneController),
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