import 'package:flutter/material.dart';
import 'package:bekas_berkelas_mobile/wishlist/models/wishlist_entry.dart';

class WishlistCard extends StatelessWidget {
  final WishlistEntry wishlist;
  final VoidCallback onEdit;

  const WishlistCard({required this.wishlist, required this.onEdit, super.key});

  String formatPrice(int price) {
    String priceStr = price.toString();
    return 'Rp ' + priceStr.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (Match m) => '${m.group(1)}.');
  }

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section
                  Row(
                    children: [
                      Image.network(
                        wishlist.imageUrl ?? '',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.car_rental),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wishlist.carName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatPrice(wishlist.price.toInt()),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF0A39C4),
                                ),
                              ),
                              Text(
                                wishlist.brand,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF000000),
                                ),
                              ),
                              Text(
                                "${wishlist.year}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF000000),
                                ),
                              ),
                              Text(
                                "${wishlist.mileage} km",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF000000),
                                ),
                              ),
                              Text(
                                "Prioritas: ${wishlist.priorityName}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1EAC9E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}