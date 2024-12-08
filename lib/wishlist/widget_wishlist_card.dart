import 'package:flutter/material.dart';

class WishlistPage extends StatelessWidget {
  WishlistPage({super.key});

  // Data statis untuk wishlist
  final List<Wishlist> wishlist = [
    Wishlist(name: 'Item 1', description: 'Deskripsi untuk Item 1'),
    Wishlist(name: 'Item 2', description: 'Deskripsi untuk Item 2'),
    Wishlist(name: 'Item 3', description: 'Deskripsi untuk Item 3'),
    Wishlist(name: 'Item 4', description: 'Deskripsi untuk Item 4'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: wishlist.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wishlist[index].name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      wishlist[index].description,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Wishlist {
  final String name;
  final String description;

  Wishlist({
    required this.name,
    required this.description,
  });
}
