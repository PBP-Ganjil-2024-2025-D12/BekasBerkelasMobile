import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bekas_berkelas_mobile/wishlist/models/wishlist_entry.dart';

class EditWishlistFormPage extends StatefulWidget {
  final WishlistEntry wishlist;

  const EditWishlistFormPage({required this.wishlist, super.key});

  @override
  State<EditWishlistFormPage> createState() => _EditWishlistFormPageState();
}

class _EditWishlistFormPageState extends State<EditWishlistFormPage> {
  String _selectedPriority = '';
  Map<String, int> priorityMap = {
    'Rendah': 1,
    'Sedang': 2,
    'Tinggi': 3,
  };

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.wishlist.priorityName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Wish List'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prioritas Saat Ini: ${widget.wishlist.priorityName}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Prioritas Baru:',
              style: TextStyle(fontSize: 16),
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_selectedPriority.isNotEmpty) {
                      widget.wishlist.priority = priorityMap[_selectedPriority]!;

                      final request = context.read<CookieRequest>();
                      final response = await request.post('http://127.0.0.1:8000/wishlist/edit_wishlist',
                        {
                          'id': widget.wishlist.id.toString(),
                          'priority': widget.wishlist.priority.toString(),
                        },
                      );

                      if (response['status'] == 'success') {
                        Navigator.pop(context, true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Berhasil melakukan edit.')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal memperbarui prioritas.')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Silakan pilih prioritas.')),
                      );
                    }
                  },
                  child: Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}