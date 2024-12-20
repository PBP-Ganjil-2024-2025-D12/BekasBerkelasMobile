import 'dart:convert';
import 'package:bekas_berkelas_mobile/wishlist/screens/edit_wishlist.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bekas_berkelas_mobile/wishlist/models/wishlist_entry.dart';
import 'package:bekas_berkelas_mobile/wishlist/widgets/wishlist_card.dart';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';


class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final _formKey = GlobalKey<FormState>();
  String _collectionName = "";
  List<WishlistEntry> wishlists = [];

  @override
  void initState() {
    super.initState();
    fetchWishlist(context.read<CookieRequest>()).then((value) {
      setState(() {
        wishlists = value;
      });
    });
  }

  void refreshList() async {
    final request = context.read<CookieRequest>();
    final newWishlists = await fetchWishlist(request);
    setState(() {
      wishlists = newWishlists;
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

  Future<WishlistEntry?> fetchWishlistItem(CookieRequest request, String wishlistId) async {
    try {
      final response = await request.get('http://127.0.0.1:8000/wishlist/get_wishlist_item/$wishlistId/');
      if (response is Map<String, dynamic>) {
        return WishlistEntry.fromJson(response);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching wishlist item: $e');
    }
  }
    
  void showRemoveWishlistDialog(BuildContext context, String wishlistId) async {
    final request = context.read<CookieRequest>();

    final fetchedWishlist = await fetchWishlistItem(request, wishlistId);

    if (fetchedWishlist != null) {
      String wishlistName = fetchedWishlist.carName;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Remove wishlist $wishlistName?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Yakin akan menghapus wishlist ini?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final deleteResponse = await request.post(
                              'http://127.0.0.1:8000/wishlist/remove_wishlist/$wishlistId/',
                              jsonEncode(<String, String>{'delete': 'yes'}),
                            );

                            if (deleteResponse['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Wishlist successfully removed!")),
                              );
                              Navigator.pop(context);
                              setState(() {
                                wishlists.removeWhere((entry) => entry.id == wishlistId);
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("There seems to be an issue, please try again.")),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: ${e.toString()}")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
                        ),
                        child: const Text('Remove', style: TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wishlist not found.")),
      );
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
      drawer: const LeftDrawer(),
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
                var wishlistEntry = wishlists[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: WishlistCard(
                    key: ValueKey(wishlistEntry.id),
                    wishlist: wishlistEntry,
                    onEdit: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditWishlistFormPage(wishlistId: wishlistEntry.id),
                        ),
                      );
                      refreshList();
                    },
                    onDelete: (wishlistId) => showRemoveWishlistDialog(context, wishlistId),
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