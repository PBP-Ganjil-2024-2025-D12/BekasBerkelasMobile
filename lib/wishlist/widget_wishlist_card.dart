import 'package:flutter/material.dart';
import 'package:bekas_berkelas_mobile/wishlist/model_wishlist_entry.dart';

class WishlistCard extends StatelessWidget {
  final WishlistEntry wishlist;

  const WishlistCard({required this.wishlist, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              wishlist.fields.car.fields.carName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff0728bb),
              ),
            ),
            const SizedBox(height: 8),
            // Brand Mobil
            Text(
              "Brand: ${wishlist.fields.car.fields.brand}",
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff174ff3),
              ),
            ),
            const SizedBox(height: 8),
            // Harga Mobil
            Text(
              "Price: Rp${wishlist.fields.car.fields.price}",
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff174ff3),
              ),
            ),
            const SizedBox(height: 8),
            // Priority
            Text(
              "Priority: ${wishlist.fields.priority}",
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff1eac9e),
              ),
            ),
          ],
        ),
      ),
    );
  }
}