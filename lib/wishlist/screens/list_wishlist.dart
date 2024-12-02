import 'package:flutter/material.dart';
import 'package:wishlist/models/wishlist_entry.dart';

class ListWishlistEntry extends StatelessWidget {
  final List<Wishlist> wishlist = [
    Wishlist(name: 'Item 1', description: 'Deskripsi Item 1'),
    Wishlist(name: 'Item 2', description: 'Deskripsi Item 2'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist'),
      ),
      body: ListView.builder(
        itemCount: wishlist.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(wishlist[index].name),
            subtitle: Text(wishlist[index].description),
          );
        },
      ),
    );
  }
}
