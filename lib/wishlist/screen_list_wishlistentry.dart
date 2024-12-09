// wishlist/screen_list_wishlist.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bekas_berkelas_mobile/wishlist/model_wishlist.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  Future<List<WishlistEntry>> fetchWishlist(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/wishlist/show_wishlist/');

    List<WishlistEntry> wishlist = [];
    for (var d in response) {
      if (d != null) {
        wishlist.add(WishlistEntry.fromJson(d));
      }
    }

    return wishlist;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: FutureBuilder<List<WishlistEntry>>(
        future: fetchWishlist(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Center(
                child: Text(
                  'Belum ada data wishlist',
                  style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) {
                  var wishlistEntry = snapshot.data![index];

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${wishlistEntry.fields.car.carName}",
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("Brand: ${wishlistEntry.fields.car.brand}"),
                        const SizedBox(height: 10),
                        Text("Price: Rp${wishlistEntry.fields.car.price}"),
                        const SizedBox(height: 10),
                        Text("Priority: ${wishlistEntry.fields.priority}"),
                      ],
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}
