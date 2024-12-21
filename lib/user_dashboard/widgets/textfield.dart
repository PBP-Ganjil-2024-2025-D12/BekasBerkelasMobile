import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  final FormFieldValidator<String>? validator;
  final TextEditingController controller;
  final String text;

  const InputTextField({
    super.key,
    required this.validator,
    required this.text,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: const Color.fromARGB(255, 9, 68, 127),
      decoration: InputDecoration(
        labelText: text,
        labelStyle: const TextStyle(color: Color.fromARGB(255, 9, 68, 127)),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 9, 68, 127)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 9, 68, 127)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
      validator: validator,
      obscureText: text == 'Password Baru' || text == 'Konfirmasi Password Baru' || text == 'Password Lama', // jika password akan hidden
    );
  }
}