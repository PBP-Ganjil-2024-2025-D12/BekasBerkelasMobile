import 'package:bekas_berkelas_mobile/authentication/services/auth.dart';
import 'dart:convert';
import 'package:bekas_berkelas_mobile/review_rating/models/review_rating.dart';
import 'package:bekas_berkelas_mobile/review_rating/models/user.dart';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bekas_berkelas_mobile/review_rating/widgets/review_card.dart';
import 'package:bekas_berkelas_mobile/review_rating/services/user_services.dart';
import 'package:provider/provider.dart';
import 'package:bekas_berkelas_mobile/katalog_produk/Car_entry.dart';
import 'package:bekas_berkelas_mobile/review_rating/widgets/car_listing.dart';
import 'package:bekas_berkelas_mobile/review_rating/screens/all_reviews.dart';

class ProfileScreen extends StatefulWidget {
  final String username;

  const ProfileScreen({super.key, required this.username});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late Future<SellerProfile> sellerFuture;
  late Future<BuyerProfile> buyerFuture;
  late Future<List<ReviewRating>> reviewsFuture;
  late List<CarEntry> cars = [];
  final authService = AuthService();
  String baseUrl = "https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id";

  @override
  initState() {
    super.initState();
    refreshData();
  }

  Future<void> refreshData() async {
    final request = Provider.of<CookieRequest>(context, listen: false);
    User user = await fetchProfileUser(request);

    setState(() {
      if (user.role == 'SEL') {
        sellerFuture = fetchSellerProfile(request);
        reviewsFuture = fetchReviews(request);
        fetchFilter();
      }
    });
  }

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

  Future<void> fetchFilter() async {
    try {
      final request = Provider.of<CookieRequest>(context, listen: false);
      final username = widget.username;
      final payload = jsonEncode({'username': username});

      final url = "$baseUrl/katalog/api/mobilsaya/";
      final response = await request.postJson(url, payload);

      List<CarEntry> fetchedCars = [];
      for (var car in response) {
        fetchedCars.add(CarEntry.fromJson(car));
      }

      setState(() {
        cars = fetchedCars;
      });
    } catch (e) {
      throw Exception("An error occurred while fetching filtered cars: $e");
    }
  }

  void _showReviewModal(BuildContext context, CookieRequest request) {
    final TextEditingController reviewController = TextEditingController();
    int _rating = 0;
    String? errorMessage;

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
                          modalSetState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: reviewController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Write your review here...',
                      border: const OutlineInputBorder(),
                      errorText: errorMessage, // Show error message
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      modalSetState(() {
                        errorMessage = null; // Clear previous error
                      });

                      // Validate inputs
                      if (_rating == 0) {
                        modalSetState(() {
                          errorMessage = 'Please select a rating.';
                        });
                        return;
                      }

                      if (reviewController.text.trim().isEmpty) {
                        modalSetState(() {
                          errorMessage = 'Review text cannot be empty.';
                        });
                        return;
                      }

                      try {
                        String? currentUsername =
                            (await authService.getUserData())['username'];

                        await submitReview(
                          request: request,
                          reviewedUsername: widget.username,
                          reviewerUsername: currentUsername!,
                          rating: _rating,
                          reviewText: reviewController.text.trim(),
                        );

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Review submitted successfully!')),
                        );
                      } catch (e) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to submit review: $e')),
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
    required CookieRequest request,
    required String reviewedUsername,
    required String reviewerUsername,
    required int rating,
    required String reviewText,
  }) async {
    await request.post(
      '$baseUrl/profile/$reviewedUsername/add_review_flutter/',
      {
        'reviewee_username': reviewedUsername,
        'reviewer_username': reviewerUsername,
        'rating': rating.toString(),
        'review': reviewText,
      },
    );
    refreshData();
  }

  void _deleteReview(
      BuildContext context, CookieRequest request, String reviewId) async {
    try {
      final response = await request
          .post('$baseUrl/profile/delete_review_flutter/$reviewId/', {});

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Review deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        refreshData();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void showDeleteConfirmationDialog(
      String reviewId, BuildContext context, CookieRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Review'),
          content: const Text('Are you sure you want to delete this review?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(dialogContext).pop();

                // Trigger review deletion
                _deleteReview(context, request, reviewId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFD8E7FF),
      appBar: appBar(context, '', false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                        future: fetchProfileUser(request),
                        builder: (context, snapshot) {
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
                            User user = snapshot.data!;
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
                      FutureBuilder<User>(
                        future: fetchProfileUser(request),
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
                              sellerFuture = fetchSellerProfile(request);
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
                                          sellerProfile.rating
                                              .toStringAsFixed(2),
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
                FutureBuilder<User>(
                  future: fetchProfileUser(request),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      User user = snapshot.data!;
                      if (user.role == 'SEL') {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            CarListingWidget(cars: cars),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Reviews',
                                  style: TextStyle(fontSize: 24),
                                ),
                                FutureBuilder<Map<String, String?>>(
                                  future: authService.getUserData(),
                                  builder: (context, userSnapshot) {
                                    if (!userSnapshot.hasData) {
                                      return const SizedBox.shrink();
                                    }

                                    String? currentUserRole =
                                        userSnapshot.data!['role'];
                                    bool canReview = currentUserRole == 'BUY';

                                    if (canReview) {
                                      return ElevatedButton(
                                        onPressed: () =>
                                            _showReviewModal(context, request),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                            horizontal: 30,
                                          ),
                                          backgroundColor: const Color.fromARGB(
                                              255, 105, 153, 225),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'Review Seller',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            FutureBuilder<List<ReviewRating>>(
                              key: ValueKey(DateTime.now()),
                              future: fetchReviews(request),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text(
                                      'Error loading reviews: ${snapshot.error}');
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return const Text('No reviews available.');
                                }

                                List<ReviewRating> reviews = snapshot.data!;
                                List<ReviewRating> displayedReviews =
                                    reviews.take(3).toList();

                                return Column(
                                  children: [
                                    ...displayedReviews.map((review) {
                                      return FutureBuilder<
                                          Map<String, String?>>(
                                        future: authService.getUserData(),
                                        builder: (context, userSnapshot) {
                                          if (!userSnapshot.hasData) {
                                            return const SizedBox.shrink();
                                          }

                                          String? currentUsername =
                                              userSnapshot.data!['username'];
                                          String? currentUserRole =
                                              userSnapshot.data!['role'];
                                          bool canDelete = currentUsername ==
                                                  review.fields.reviewer
                                                      .userProfile.name ||
                                              currentUserRole == 'ADM';

                                          return ReviewCard(
                                            name: review.fields.reviewer
                                                .userProfile.name,
                                            profilePicture: review
                                                .fields
                                                .reviewer
                                                .userProfile
                                                .profilePicture,
                                            review: review.fields.review,
                                            rating: review.fields.rating,
                                            canDelete: canDelete,
                                            reviewId: review.fields.id,
                                            deleteReview: () {
                                              showDeleteConfirmationDialog(
                                                  review.fields.id,
                                                  context,
                                                  request);
                                            },
                                          );
                                        },
                                      );
                                    }).toList(),
                                    if (reviews.length > 3)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AllReviewsScreen(
                                                  username: widget.username,
                                                  reviews: reviews,
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 15,
                                              horizontal: 30,
                                            ),
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 105, 153, 225),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'View All Reviews',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }
                    return const Text('Error: Could not fetch user data.');
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
