import 'package:flutter/material.dart';
import 'package:bekas_berkelas_mobile/user_dashboard/models/rating.dart'; 

class RatingDetailPage extends StatelessWidget {
  final Rating rating;

  const RatingDetailPage({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Rating'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: rating.reviewerPicture.isNotEmpty
                    ? NetworkImage(rating.reviewerPicture)
                    : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
                backgroundColor: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        flex: 1,
                        child: Text('Reviewer', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(rating.reviewer, style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                        flex: 1,
                        child: Text('Rating', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          children: [
                            Text('${rating.rating}', style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Center(
                    child: Text('Komentar', style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 91, 90, 90))),
                    ),
                  const SizedBox(height: 4),
                  Text(rating.review, style: const TextStyle(fontSize: 16)),
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}
