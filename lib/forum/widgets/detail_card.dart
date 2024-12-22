import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/question.dart';
import '../models/reply.dart';
import 'package:bekas_berkelas_mobile/katalog_produk/Car_entry.dart';
import 'package:bekas_berkelas_mobile/katalog_produk/detail.dart';
import 'package:bekas_berkelas_mobile/authentication/services/auth.dart';
import 'package:bekas_berkelas_mobile/review_rating/screens/profile.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ForumDetailCard extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Question question;
  final List<Reply> replies;
  final CookieRequest request;
  final TextEditingController replyController;
  final Function() onDeleteQuestion;
  final Function(String) onDeleteReply;
  final Function() onSubmitReply;
  final String Function(String) formatDateTime;

  const ForumDetailCard({
    Key? key,
    required this.fadeAnimation,
    required this.question,
    required this.replies,
    required this.request,
    required this.replyController,
    required this.onDeleteQuestion,
    required this.onDeleteReply,
    required this.onSubmitReply,
    required this.formatDateTime,
  }) : super(key: key);

  Future<Map<String, dynamic>> fetchCarDetails(CookieRequest request, String carId) async {
    try {
      final url = 'https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/katalog/detail/json/$carId/';
      final response = await request.get(url);
      if (response is Map<String, dynamic>) {
        return response;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      debugPrint('Error in fetchCarDetails: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                question.fields.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4C8BF5),
                                ),
                              ),
                            ),
                            if (request.loggedIn)
                              FutureBuilder<Map<String, String?>>(
                                future: AuthService().getUserData(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      (question.fields.user.toString() ==
                                              snapshot.data?['user_id'] ||
                                          snapshot.data?['role'] == 'ADM')) {
                                    return IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: onDeleteQuestion,
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileScreen(username: question.fields.username),
                                  ),
                                );
                              },
                              child: Text(
                                question.fields.username,
                                style: const TextStyle(
                                  color: Color(0xFF4C8BF5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              formatDateTime(question.fields.createdAt),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          question.fields.content,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        if (question.fields.car != null) ...[
                          const SizedBox(height: 16),
                          FutureBuilder(
                            future: fetchCarDetails(request, question.fields.car!),
                            builder: (context, AsyncSnapshot carSnapshot) {
                              if (carSnapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C8BF5)),
                                  ),
                                );
                              }

                              if (!carSnapshot.hasData || carSnapshot.hasError) {
                                return const SizedBox.shrink();
                              }

                              try {
                                final carData = CarEntry.fromJson({
                                  "model": "product_catalog.car",
                                  "pk": question.fields.car!,
                                  "fields": carSnapshot.data
                                });

                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CarDetailPage(carEntry: carData),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.directions_car,
                                                size: 16, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Mobil Terkait:',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                carData.fields.imageUrl,
                                                width: 100,
                                                height: 75,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    width: 100,
                                                    height: 75,
                                                    color: Colors.grey[200],
                                                    child: Icon(Icons.broken_image,
                                                        color: Colors.grey[400]),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${carData.fields.brand} ${carData.fields.carName}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF4C8BF5),
                                                    ),
                                                  ),
                                                  Text(
                                                    'Tahun ${carData.fields.year}',
                                                    style: TextStyle(color: Colors.grey[600]),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Lihat Detail',
                                                        style: TextStyle(
                                                          color: Colors.blue[700],
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 12,
                                                        color: Colors.blue[700],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } catch (e) {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C8BF5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.forum_outlined,
                        color: Color(0xFF4C8BF5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Balasan (${replies.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C8BF5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AnimationLimiter(
                  child: Column(
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: replies
                          .map((reply) => Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.grey[100],
                                            child: Text(
                                              reply.fields.username[0].toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProfileScreen(
                                                          username:
                                                              reply.fields.username,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    reply.fields.username,
                                                    style: const TextStyle(
                                                      color: Color(0xFF4C8BF5),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  formatDateTime(
                                                      reply.fields.createdAt),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (request.loggedIn)
                                            FutureBuilder<Map<String, String?>>(
                                              future: AuthService().getUserData(),
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData &&
                                                    (reply.fields.user.toString() ==
                                                            snapshot
                                                                .data?['user_id'] ||
                                                        question.fields.user
                                                                .toString() ==
                                                            snapshot
                                                                .data?['user_id'] ||
                                                        snapshot.data?['role'] ==
                                                            'ADM')) {
                                                  return IconButton(
                                                    icon: const Icon(Icons.delete,
                                                        color: Colors.red, size: 20),
                                                    onPressed: () =>
                                                        onDeleteReply(reply.pk),
                                                  );
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        reply.fields.content,
                                        style: const TextStyle(height: 1.4),
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (request.loggedIn)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: replyController,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan balasan...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF4C8BF5)),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C8BF5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onSubmitReply,
                    child: const Row(
                      children: [
                        Icon(Icons.send, size: 18),
                        SizedBox(width: 8),
                        Text('Kirim'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}