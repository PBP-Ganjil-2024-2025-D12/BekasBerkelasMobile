import 'package:flutter/material.dart';
import 'package:bekas_berkelas_mobile/wishlist/model_wishlist_entry.dart';

class WishlistCard extends StatelessWidget {
  final WishlistEntry wishlist;

  const WishlistCard({required this.wishlist, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFF9FAFB),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              wishlist.fields.car.fields.carName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Brand: ${wishlist.fields.car.fields.brand}",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0A39C4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Price: Rp${wishlist.fields.car.fields.price}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w100,
                color: Color(0xFF000000),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Priority: ${wishlist.fields.priority}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w100,
                color: Color(0xFF1EAC9E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
