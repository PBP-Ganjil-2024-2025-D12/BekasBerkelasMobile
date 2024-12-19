import 'dart:convert';
import 'package:bekas_berkelas_mobile/wishlist/screens/edit_wishlist.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bekas_berkelas_mobile/katalog_produk/Car_entry.dart';
import 'package:bekas_berkelas_mobile/wishlist/models/wishlist_entry.dart';
import 'package:bekas_berkelas_mobile/wishlist/widgets/wishlist_card.dart';
import 'package:bekas_berkelas_mobile/wishlist/screens/edit_wishlist.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final _formKey = GlobalKey<FormState>();
  String _collectionName = "";

  void refreshList() {
    final request = context.read<CookieRequest>();
    setState(() {
      fetchWishlist(request);
    });
  }

  Future<List<WishlistEntry>> fetchWishlist(CookieRequest request) async {
    try {
      final response = await request.get('http://127.0.0.1:8000/wishlist/json');
      var data = response;

      List<WishlistEntry> listWishlist = [];
      for (var d in data) {
        if (d != null) {
          listWishlist.add(WishlistEntry.fromJson(d));
        }
      }
      return listWishlist;
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wish List',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A39C4),
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: fetchWishlist(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data wishlist',
                style: TextStyle(fontSize: 20, color: Color(0xFF07288B)),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) {
                var wishlistEntry = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: WishlistCard(
                    wishlist: wishlistEntry,
                    onEdit: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditWishlistFormPage(wishlistId: wishlistEntry.id),
                        ),
                      );
                      if (result == true) {
                        refreshList();
                      }
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}