import 'dart:convert';
import 'package:bekas_berkelas_mobile/user_dashboard/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';
import 'package:bekas_berkelas_mobile/user_dashboard/widgets/button.dart';
import 'package:bekas_berkelas_mobile/user_dashboard/utils/constant.dart';

class ChangeNamePage extends StatefulWidget {
  const ChangeNamePage({super.key});

  @override
  ChangeNamePageState createState() => ChangeNamePageState();
}

class ChangeNamePageState extends State<ChangeNamePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm(CookieRequest request) async {
    if (_formKey.currentState!.validate()) {
      String newName = _nameController.text;

      final data = jsonEncode({
        'name': newName,
      });

      final response =
          await request.post('$baseUrl/update_profile_flutter/', data);

      if (!mounted) return;

      if (response['status'] == 'success') {
        _showSnackbar(context, 'Nama berhasil diubah');
      } else {
        _showSnackbar(context, 'Gagal mengubah nama: ${response['message']}');
      }

      Navigator.pop(context, newName);
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
      appBar: appBar(context, 'Ubah Nama', true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InputTextField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                }, 
                text: 'Nama Baru', 
                controller: _nameController
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
