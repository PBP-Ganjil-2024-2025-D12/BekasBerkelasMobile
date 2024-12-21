import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:bekas_berkelas_mobile/review_rating/screens/profile.dart';

class ReviewCard extends StatelessWidget {
  final String name;
  final String? profilePicture;
  final String review;
  final int rating;
  final bool canDelete;
  final String reviewId;
  final VoidCallback deleteReview;
  final String baseUrl = 'http://localhost:8000';

  const ReviewCard({
    Key? key,
    required this.name,
    this.profilePicture,
    required this.review,
    required this.rating,
    required this.canDelete,
    required this.reviewId,
    required this.deleteReview,
  }) : super(key: key);

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating) {
          if (index < rating.floor()) {
            // Full star
            return const Icon(
              Icons.star,
              color: Colors.amber,
              size: 20,
            );
          } else {
            return const Icon(
              Icons.star_half,
              color: Colors.amber,
              size: 20,
            );
          }
        } else {
          return const Icon(
            Icons.star_border,
            color: Colors.grey,
            size: 20,
          );
        }
      }),
    );
  }

  Future<bool> _isValidProfilePicture(String? url) async {
    if (url == null || url.isEmpty) return false;

    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200 &&
          response.headers['content-type']?.startsWith('image/') == true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
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
                FutureBuilder<bool>(
                  future: _isValidProfilePicture(profilePicture),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            AssetImage('assets/default_profile_picture.png'),
                      );
                    } else if (snapshot.data == true) {
                      return CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(profilePicture!),
                      );
                    } else {
                      return const CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            AssetImage('assets/default_profile_picture.png'),
                      );
                    }
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      GestureDetector(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                username: name,
                              ),
                            ),
                          );
                        },
                      ),
                      // Star Rating
                      _buildStarRating(rating),
                    ],
                  ),
                ),
                if (canDelete)
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: deleteReview,
                  ),
              ],
            ),
            const SizedBox(height: 12),
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
