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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color.fromARGB(255, 9, 68, 127)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color.fromARGB(255, 0, 64, 117)),
        ),
      ),
      validator: validator,
      obscureText: text == 'Password Baru' || text == 'Konfirmasi Password Baru' || text == 'Password Lama', // jika password akan hidden
    );
  }
}