import 'package:flutter/material.dart';

class ChangeNamePage extends StatefulWidget {
  @override
  _ChangeNamePageState createState() => _ChangeNamePageState();
}

class _ChangeNamePageState extends State<ChangeNamePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Lakukan sesuatu dengan nama baru, misalnya simpan ke database
      String newName = _nameController.text;
      // Contoh: simpan nama baru ke database atau backend
      print('Nama baru: $newName');
      // Kembali ke halaman sebelumnya
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubah Nama'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Baru',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // Lebar penuh dan tinggi 50
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Sudut membulat sedikit
                    )
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}