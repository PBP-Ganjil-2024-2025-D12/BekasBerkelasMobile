import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final String name;
  final String? profilePicture;
  final String review;
  final double rating;

  const ReviewCard({
    Key? key,
    required this.name,
    this.profilePicture,
    required this.review,
    required this.rating,
  }) : super(key: key);

  // Method to generate star rating widget
  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        // Determine star state
        if (index < rating) {
          if (index < rating.floor()) {
            // Full star
            return const Icon(
              Icons.star,
              color: Colors.amber,
              size: 20,
            );
          } else {
            // Partial/half star
            return const Icon(
              Icons.star_half,
              color: Colors.amber,
              size: 20,
            );
          }
        } else {
          // Empty star
          return const Icon(
            Icons.star_border,
            color: Colors.grey,
            size: 20,
          );
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 25,
                  backgroundImage: profilePicture != null 
                    ? NetworkImage(profilePicture!) 
                    : null,
                  child: profilePicture == null 
                    ? const Icon(Icons.person) 
                    : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Star Rating
                      _buildStarRating(rating),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Review Text
            Text(
              '"$review"',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}