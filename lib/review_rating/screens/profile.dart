import 'package:bekas_berkelas_mobile/review_rating/models/review_rating.dart';
import 'package:bekas_berkelas_mobile/review_rating/models/user.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';
import 'package:bekas_berkelas_mobile/review_rating/widgets/review_card.dart';

class ProfileScreen extends StatefulWidget {
  final String username; // Accepting username as a parameter

  const ProfileScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> userFuture;
  late Future<SellerProfile> sellerFuture;
  late Future<BuyerProfile> buyerFuture;

  // Fetch the user data dynamically from the API
  Future<User> fetchUser(CookieRequest request) async {
    try {
      final response = await request.get(
        'http://localhost:8000/profile/${widget.username}/show_user_json/',
      );
      var data = response;
      return User.fromJson(data);
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  Future<SellerProfile> fetchSellerProfile(CookieRequest request) async {
    try {
      final response = await request.get(
        'http://localhost:8000/profile/${widget.username}/show_user_json/',
      );
      var data = response;
      return SellerProfile.fromJson(data);
    } catch (e) {
      throw Exception('Error fetching seller profile: $e');
    }
  }

  Future<BuyerProfile> fetchBuyerProfile(CookieRequest request) async {
    try {
      final response = await request.get(
        'http://localhost:8000/profile/${widget.username}/show_user_json/',
      );
      var data = response;
      return BuyerProfile.fromJson(data);
    } catch (e) {
      throw Exception('Error fetching buyer profile: $e');
    }
  }

  Future<List<ReviewRating>> fetchReviews(CookieRequest request) async {
    try {
      final response = await request.get(
        'http://localhost:8000/profile/${widget.username}/show_json/',
      );
      var data = response;
      List<ReviewRating> reviews = [];
      for (var review in data) {
        if (review != null) {
          reviews.add(ReviewRating.fromJson(review));
        }
      }
      return reviews;
    } catch (e) {
      throw Exception('Error fetching reviews: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    userFuture = fetchUser(CookieRequest());
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
                      future: userFuture,
                      builder: (context, snapshot) {
                        User user = snapshot.data!;
                        UserProfile profile = user.userProfile;
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
                        } else if (snapshot.hasData &&
                            profile.profilePicture != '') {
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
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(widget.username,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),

                    // Display Rating for Seller Role
                    FutureBuilder<User>(
                      future: userFuture,
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
                            sellerFuture = fetchSellerProfile(CookieRequest());
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                    //  Reviews Section
                    FutureBuilder<List<ReviewRating>>(
                      future: fetchReviews(CookieRequest()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text('Error loading reviews');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('No reviews available.');
                        } else {
                          // Display first 3 reviews
                          List<ReviewRating> reviews = snapshot.data!.take(3).toList();

                          return Column(
                            children: [
                              ...reviews.map((review) {
                                return ReviewCard(
                                  name: review.fields.reviewer.userProfile.name,
                                  profilePicture: review.fields.reviewer.userProfile.profilePicture,
                                  review: review.fields.review,
                                  rating: review.fields.rating.toDouble(),
                                );
                              }).toList(),
                              // "More" button to navigate to reviews page
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReviewsPage(username: widget.username),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewsPage extends StatelessWidget {
  final String username;

  const ReviewsPage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reviews'),
        backgroundColor: const Color(0xFF4C8BF5),
      ),
      body: Center(
        child: Text('All reviews for $username will be shown here.'),
      ),
    );
  }
}
