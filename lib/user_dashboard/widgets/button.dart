import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const SubmitButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Warna latar belakang tombol
        foregroundColor: Colors.white, // Warna teks tombol// Warna tombol saat tidak aktif
        shadowColor: Colors.black, // Warna bayangan tombol
        elevation: 0, // Ketinggian bayangan tombol
        minimumSize: const Size(double.infinity, 50), // Ukuran minimum tombol
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Bentuk border tombol
        ),
        overlayColor: Colors.black, // Warna efek material saat tombol ditekan
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, color: Colors.white),
      ),
    );
  }
}

class SelectionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  final Color? color;

  const SelectionButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      icon: Icon(
        icon,
        color: color ?? const Color.fromARGB(255, 9, 68, 127),
      ),
      label: Text(
        text,
        style: TextStyle(fontSize: 15, color: color ?? const Color.fromARGB(255, 9, 68, 127)),
      ),
    );
  }
}

