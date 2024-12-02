import 'package:flutter/material.dart';
import 'screens/menu.dart';
import 'package:screens/list_wishlist.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wishlist App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Menu(),
      routes: {
        '/list_wishlist': (context) => ListWishlist(),
      },
    );
  }
}
