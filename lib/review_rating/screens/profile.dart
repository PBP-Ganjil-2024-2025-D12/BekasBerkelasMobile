import 'package:bekas_berkelas_mobile/authentication/services/auth.dart';
import 'package:bekas_berkelas_mobile/review_rating/models/review_rating.dart';
import 'package:bekas_berkelas_mobile/review_rating/models/user.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bekas_berkelas_mobile/review_rating/widgets/review_card.dart';
import 'package:bekas_berkelas_mobile/review_rating/screens/reviews_page.dart';
import 'package:bekas_berkelas_mobile/review_rating/services/user_services.dart';

class ProfileScreen extends StatefulWidget {
  final String username; // Accepting username as a parameter

  const ProfileScreen({super.key, required this.username});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> profileUserFuture;
  late Future<SellerProfile> sellerFuture;
  late Future<BuyerProfile> buyerFuture;
  final authService = AuthService();
  String baseUrl = "http://localhost:8000";

  // Fetch the user data dynamically from the API
  Future<User> fetchProfileUser(CookieRequest request) async {
    return UserService().fetchUser(request, widget.username);
  }

  Future<SellerProfile> fetchSellerProfile(CookieRequest request) async {
    return UserService().fetchSellerInfo(request, widget.username);
  }

  Future<BuyerProfile> fetchBuyerProfile(CookieRequest request) async {
    return UserService().fetchBuyerInfo(request, widget.username);
  }

  Future<List<ReviewRating>> fetchReviews(CookieRequest request) async {
    try {
      final response = await request.get(
        '$baseUrl/profile/${widget.username}/show_json/',
      );
      var data = response;

      List<ReviewRating> listReview = [];
      for (var d in data) {
        if (d != null) {
          listReview.add(ReviewRating.fromJson(d));
        }
      }
      return listReview;
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  void _showReviewModal(BuildContext context) {
    final TextEditingController reviewController = TextEditingController();
    int _rating = 3; // Default rating

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Write a Review',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Rating Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                        onPressed: () {
                          // Update modal state
                          modalSetState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  // Review Text Field
                  TextField(
                    controller: reviewController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Write your review here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        String? currentUsername =
                            (await authService.getUserData())['username'];

                        await submitReview(
                          reviewedUsername: widget.username,
                          reviewerUsername: currentUsername!,
                          rating: _rating,
                          reviewText: reviewController.text,
                        );

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Review submitted successfully!'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to submit review: $e')),
                        );
                      }
                    },
                    child: const Text('Submit Review'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> submitReview({
    required String reviewedUsername,
    required String reviewerUsername,
    required int rating,
    required String reviewText,
  }) async {
    final request = CookieRequest();
    await request
        .post('$baseUrl/profile/${widget.username}/add_review_flutter/', {
      'reviewee_username': reviewedUsername,
      'reviewer_username': reviewerUsername,
      'rating': rating,
      'review': reviewText,
    });
  }

  @override
  void initState() {
    super.initState();
    profileUserFuture = fetchProfileUser(CookieRequest());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8E7FF),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF4C8BF5),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      FutureBuilder<User>(
                        future: profileUserFuture,
                        builder: (context, snapshot) {
                          // Check if snapshot has data
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircleAvatar(
                              radius: 48,
                              backgroundImage: AssetImage(
                                  'assets/default_profile_picture.png'),
                            );
                          } else if (snapshot.hasError) {
                            return const CircleAvatar(
                              radius: 48,
                              backgroundImage: AssetImage(
                                  'assets/default_profile_picture.png'),
                            );
                          } else if (snapshot.hasData) {
                            User user = snapshot
                                .data!; // Accessing data safely after checking hasData
                            UserProfile profile = user.userProfile;
                            if (profile.profilePicture != '') {
                              return CircleAvatar(
                                radius: 48,
                                backgroundImage:
                                    NetworkImage(profile.profilePicture),
                              );
                            } else {
                              return const CircleAvatar(
                                radius: 48,
                                backgroundImage: AssetImage(
                                    'assets/default_profile_picture.png'),
                              );
                            }
                          } else {
                            // Handle case where there is no data yet
                            return const CircleAvatar(
                              radius: 48,
                              backgroundImage: AssetImage(
                                  'assets/default_profile_picture.png'),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(widget.username,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),

                      // Display Rating for Seller Role
                      FutureBuilder<User>(
                        future: profileUserFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star, color: Colors.yellow),
                                Text('Loading...',
                                    style: TextStyle(fontSize: 16)),
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star, color: Colors.yellow),
                                Text('Error', style: TextStyle(fontSize: 16)),
                              ],
                            );
                          } else if (snapshot.hasData) {
                            User user = snapshot.data!;
                            if (user.role == 'SEL') {
                              sellerFuture =
                                  fetchSellerProfile(CookieRequest());
                              return FutureBuilder<SellerProfile>(
                                future: sellerFuture,
                                builder: (context, sellerSnapshot) {
                                  if (sellerSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (sellerSnapshot.hasError) {
                                    return const Text(
                                        'Error fetching seller profile');
                                  } else if (sellerSnapshot.hasData) {
                                    SellerProfile sellerProfile =
                                        sellerSnapshot.data!;
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.yellow),
                                        Text(
                                          sellerProfile.rating.toString(),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return const Text(
                                        'No seller profile available');
                                  }
                                },
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          } else {
                            return const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star, color: Colors.yellow),
                                Text('No data', style: TextStyle(fontSize: 16)),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                //  Reviews Section
                const Text('Reviews', style: TextStyle(fontSize: 24)),
                FutureBuilder<Map<String, String?>>(
                    future: authService.getUserData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!["role"] == 'BUY') {
                        return ElevatedButton(
                          onPressed: () {
                            _showReviewModal(context);
                          },
                          child: const Text('Review Seller'),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                FutureBuilder<List<ReviewRating>>(
                  future: fetchReviews(CookieRequest()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error loading reviews: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No reviews available.');
                    } else {
                      List<ReviewRating> reviews =
                          snapshot.data!.take(3).toList();

                      return Column(
                        children: [
                          ...reviews.map((review) {
                            return ReviewCard(
                              name: review.fields.reviewer.userProfile.name,
                              profilePicture: review
                                  .fields.reviewer.userProfile.profilePicture,
                              review: review.fields.review,
                              rating: review.fields.rating.toDouble(),
                            );
                          }).toList(),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ReviewsPage(username: widget.username),
                                ),
                              );
                            },
                            child: const Text('More Reviews'),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
