import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bekas_berkelas_mobile/wishlist/models/wishlist_entry.dart';

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
        'http://127.0.0.1:8000/wishlist/get_wishlist_item/${widget.wishlistId}/',
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
    appBar: AppBar(
      backgroundColor: const Color(0xFFC5D3FC),
      title: Text(
        'Edit Wishlist',
        style: TextStyle(color: Color(0xFF0A39C4), fontWeight: FontWeight.bold),
      ),
    ),
    body: Padding(
      padding: EdgeInsets.all(16.0),
      child: _wishlist != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prioritas Saat Ini: ${_wishlist!.priorityName}',
                  style: TextStyle(fontSize: 16, color: Color(0xFF1EAC9E)),
                ),
                SizedBox(height: 16),
                Text(
                  'Prioritas Baru:',
                  style: TextStyle(fontSize: 16, fontWeight:FontWeight.w600, color: Color(0xFF000000)),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF0A39C4)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedPriority,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedPriority = newValue!;
                      });
                    },
                    items: priorityMap.keys.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                    style: TextStyle(color: Colors.black),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                    underline: Container(), // Remove default underline
                  ),
                ),                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Red background
                        foregroundColor: Colors.white, // White text
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        // save logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0A39C4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text('Save'),
                    ),
                  ],
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    ),
  );
}
}