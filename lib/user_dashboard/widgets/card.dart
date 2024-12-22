import 'package:flutter/material.dart';
import 'package:bekas_berkelas_mobile/user_dashboard/models/rating.dart';
import 'package:bekas_berkelas_mobile/review_rating/models/user.dart';

class UserCard extends StatelessWidget {
  final SellerProfile seller;

  const UserCard({
    super.key,
    required this.seller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 0, // Menambahkan bayangan yang lebih menonjol
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: seller.userProfile.profilePicture.isNotEmpty
                  ? NetworkImage(seller.userProfile.profilePicture)
                  : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
              backgroundColor: Colors.blue[900],
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.userProfile.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  seller.userProfile.email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RatingCard extends StatelessWidget {
  final Rating rating;

  const RatingCard({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 0, // Menambahkan bayangan yang lebih menonjol
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                    radius: 30,
                    backgroundImage: rating.reviewerPicture.isNotEmpty
                        ? NetworkImage(rating.reviewerPicture)
                        : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
                    backgroundColor: Colors.blue[900],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      rating.reviewer,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ... List.generate(
                      rating.rating,
                      (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
                    ),
                    ...List.generate(
                      5 - rating.rating,
                      (index) => const Icon(Icons.star_border, color: Colors.grey, size: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.createdAt,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ]
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Text(
                    rating.review,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],)
              ],
            ),
          ],
        ),
      ),
    );
  }
}