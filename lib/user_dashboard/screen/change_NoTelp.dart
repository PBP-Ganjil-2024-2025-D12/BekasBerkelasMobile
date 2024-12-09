import 'package:flutter/material.dart';

class ChangePhonePage extends StatefulWidget {
  @override
  _ChangePhonePageState createState() => _ChangePhonePageState();
}

class _ChangePhonePageState extends State<ChangePhonePage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String newPhone = _phoneController.text;
      print('Nomor telepon baru: $newPhone');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubah No Telp'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'No Telp Baru',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  } else if (!RegExp(r'^\+?[0-9]{7,15}$').hasMatch(value)) {
                    return 'Masukkan nomor telepon yang valid';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}