import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bekas_berkelas_mobile/wishlist/models/wishlist_entry.dart';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';

class EditWishlistFormPage extends StatefulWidget {
  final String wishlistId;

  const EditWishlistFormPage({Key? key, required this.wishlistId}) : super(key: key);

  @override
  State<EditWishlistFormPage> createState() => _EditWishlistFormPageState();
}

class _EditWishlistFormPageState extends State<EditWishlistFormPage> {
  WishlistEntry? _wishlist;
  String _selectedPriority = '';
  Map<String, int> priorityMap = {
    'Rendah': 1,
    'Sedang': 2,
    'Tinggi': 3,
  };

  @override
  void initState() {
    super.initState();
    _fetchWishlistItem();
  }

  Future<void> _fetchWishlistItem() async {
    try {
      final request = context.read<CookieRequest>();
      final response = await request.get(
        'https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/wishlist/get_wishlist_item/${widget.wishlistId}/',
      );

      setState(() {
        _wishlist = WishlistEntry(
          id: response['id'],
          imageUrl: response['image_url'],
          carName: response['car_name'],
          price: double.parse(response['price']),
          brand: response['brand'],
          year: response['year'],
          mileage: response['mileage'],
          priority: response['priority'],
        );
        _selectedPriority = _getPriorityName(_wishlist!.priority);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load wishlist item: $e')),
      );
    }
  }

  String _getPriorityName(int priority) {
    switch (priority) {
      case 1:
        return 'Rendah';
      case 2:
        return 'Sedang';
      case 3:
        return 'Tinggi';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, 'Edit Wishlist', true),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _wishlist != null
            ? SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Directly display the text without Card and Padding
                    Text(
                      'Prioritas Saat Ini: ${_wishlist!.priorityName}',
                      style: TextStyle(fontSize: 16, color: Color(0xFF1EAC9E)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Prioritas Baru:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF000000)),
                    ),
                    DropdownButton<String>(
                      value: _selectedPriority,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPriority = newValue!;
                        });
                      },
                      items: priorityMap.keys.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF0A39C4),
                          ),
                          onPressed: () async {
                            if (_selectedPriority.isNotEmpty && _wishlist != null) {
                              int newPriority = priorityMap[_selectedPriority]!;
                              final request = context.read<CookieRequest>();
                              try {
                                final response = await request.post(
                                  'https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/wishlist/edit_wishlist/${_wishlist!.id}/',
                                  {'priority': newPriority.toString()},
                                );
                                if (response['status'] == 'success') {
                                  Navigator.pop(context, true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Berhasil mengedit wishlist')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal mengedit wishlist')),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error updating priority: $e')),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Choose priority')),
                              );
                            }
                          },
                          child: Text(
                            'Save',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
                            ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }
}