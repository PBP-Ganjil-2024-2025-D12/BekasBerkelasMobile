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
  String _selectedFilter = 'Semua Prioritas';

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
      final response = await request.get('https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/wishlist/json');
      var data = response;

      List<WishlistEntry> listWishlist = [];
      for (var d in data) {
        if (d != null) {
          listWishlist.add(WishlistEntry.fromJson(d));
        }
      }
      return listWishlist;
    } catch (e) {
      throw Exception('Error fetching wishlist: $e');
    }
  }

  Future<WishlistEntry?> fetchWishlistItem(CookieRequest request, String wishlistId) async {
    try {
      final response = await request
          .get('https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/wishlist/get_wishlist_item/$wishlistId/');
      if (response is Map<String, dynamic>) {
        return WishlistEntry.fromJson(response);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error fetching wishlist item: $e');
    }
  }

  List<WishlistEntry> get _filteredWishlists {
    if (_selectedFilter == 'Semua Prioritas') {
      return wishlists;
    } else {
      return wishlists.where((wishlist) {
        return wishlist.priorityName == _selectedFilter;
      }).toList();
    }
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text('Semua Prioritas'),
              onTap: () {
                setState(() {
                  _selectedFilter = 'Semua Prioritas';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Tinggi'),
              onTap: () {
                setState(() {
                  _selectedFilter = 'Tinggi';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Sedang'),
              onTap: () {
                setState(() {
                  _selectedFilter = 'Sedang';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Rendah'),
              onTap: () {
                setState(() {
                  _selectedFilter = 'Rendah';
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
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
                    'Hapus $wishlistName dari wishlist?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9.0)),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final deleteResponse = await request.post(
                              'https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/wishlist/remove_wishlist/$wishlistId/',
                              jsonEncode(<String, String>{'delete': 'yes'}),
                            );

                            if (deleteResponse['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Berhasil menghapus wishlist")),
                              );
                              Navigator.pop(context);
                              setState(() {
                                wishlists.removeWhere(
                                    (entry) => entry.id == wishlistId);
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Terjadi error, harap coba kembali")),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: ${e.toString()}")),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A39C4),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9.0)),
                        ),
                        child: const Text('Remove',
                            style: TextStyle(fontSize: 14)),
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
        const SnackBar(content: Text("Wishlist tidak ditemukan")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFEEF1FF),
      appBar: appBar(context, 'Wishlist', true),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _showFilterOptions(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedFilter,
                            style: TextStyle(color: Color(0xFF000000)),
                          ),
                          Row(
                            children: [
                              Icon(Icons.arrow_drop_down_outlined,
                                  color: Color(0xFF0A39C4)),
                              SizedBox(width: 4.0),
                              Container(
                                width: 1.0,
                                height: 16.0,
                                color: const Color(0xFF000000),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchWishlist(request),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 60,
                          color: Color(0xFF07288B),
                        ),
                        SizedBox(height: 16), 
                        Text(
                          'Belum ada wishlist',
                          style: TextStyle(fontSize: 20, color: Color(0xFF07288B)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                } else {
                  wishlists = snapshot.data as List<WishlistEntry>;
                  List<WishlistEntry> filteredWishlists = _filteredWishlists;
                  if (filteredWishlists.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada wishlist dengan prioritas ini',
                        style: TextStyle(fontSize: 16, color: Color(0xFF07288B)),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: filteredWishlists.length,
                      itemBuilder: (_, index) {
                        var wishlistEntry = filteredWishlists[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                          child: WishlistCard(
                            key: ValueKey(wishlistEntry.id),
                            wishlist: wishlistEntry,
                            onEdit: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditWishlistFormPage(
                                    wishlistId: wishlistEntry.id),
                                ),
                              );
                              refreshList();
                            },
                            onDelete: (wishlistId) =>
                              showRemoveWishlistDialog(context, wishlistId),
                          ),
                        );
                      },
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
