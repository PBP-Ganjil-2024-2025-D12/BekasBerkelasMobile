import 'package:bekas_berkelas_mobile/review_rating/models/review_rating.dart';
import 'package:bekas_berkelas_mobile/review_rating/models/user.dart';
import 'package:flutter/material.dart';
import 'package:bekas_berkelas_mobile/katalog_produk/model_katalog_produk.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String username;  // Accepting username as a parameter

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
        'http://localhost:8000/profile/${widget.username}/show_user_json',
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
        'http://localhost:8000/profile/${widget.username}/show_user_json',
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
        'http://localhost:8000/profile/${widget.username}/show_user_json',
      );
      
      var data = response;
      return BuyerProfile.fromJson(data);

    } catch (e) {
      throw Exception('Error fetching buyer profile: $e');
    }
  }

  Future<void> _showReviewModal() async {
    double rating = 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review Penjual'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: index < rating.toInt() ? Colors.yellow : Colors.grey,
                  ),
                  onPressed: () {},
                );
              }),
            ),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Write your review here...',
                border: OutlineInputBorder(),
                labelText: 'Review',
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle Review Submission
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    userFuture = fetchUser(CookieRequest());
    if (userFuture != null) {
      userFuture.then((user) {
        if (user.role == 'SEL') {
          sellerFuture = fetchSellerProfile(CookieRequest());
        } else if (user.role == 'BUY') {
          buyerFuture = fetchBuyerProfile(CookieRequest());
        }
      });
    }
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
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircleAvatar(
                            radius: 48,
                            backgroundImage: AssetImage('assets/default_profile_picture.png'),
                          );
                        // } else if (snapshot.hasError) {
                        //   // return const CircleAvatar(
                        //   //   radius: 48,
                        //   //   backgroundImage: AssetImage('assets/default_profile_picture.png'),
                        //   // );
                        } else if (snapshot.hasData) {
                          return CircleAvatar(
                            radius: 48,
                            backgroundImage: NetworkImage(snapshot.data!.userProfile.profilePicture ?? 'assets/default_profile_picture.png'),
                          );
                        } else {
                          return const CircleAvatar(
                            radius: 48,
                            backgroundImage: AssetImage('assets/default_profile_picture.png'),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(widget.username,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    FutureBuilder<User>(
                      future: userFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star, color: Colors.yellow),
                              Text('Loading...', style: TextStyle(fontSize: 16)),
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

                          // Check if the user is a seller and if the rating is available
                          if (user.role == 'SEL' && user.userProfile is SellerProfile) {
                            SellerProfile sellerProfile = user.userProfile as SellerProfile;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star, color: Colors.yellow),
                                Text(
                                  sellerProfile.rating.toString(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            );
                          } else {
                            return const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star, color: Colors.yellow),
                                Text('No rating available', style: TextStyle(fontSize: 16)),
                              ],
                            );
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
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // // Cars Section (Show dynamically for Seller)
              // FutureBuilder<User>(
              //   future: userFuture,
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return Center(child: CircularProgressIndicator());
              //     } else if (snapshot.hasError) {
              //       return Center(child: Text('Error: ${snapshot.error}'));
              //     } else if (!snapshot.hasData || snapshot.data == null) {
              //       return Center(child: Text('No data available.'));
              //     }

              //     var user = snapshot.data!;
              //     // Check if the user is a seller
              //     if (user.role == 'SEL') {
              //       var sellerProfile = user.userProfile as SellerProfile;
              //       return Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           const Text('Mobil yang Dijual',
              //               style: TextStyle(
              //                   fontSize: 20, fontWeight: FontWeight.bold)),
              //           const SizedBox(height: 12),
              //           sellerProfile.cars.isNotEmpty
              //               ? GridView.builder(
              //                   shrinkWrap: true,
              //                   gridDelegate:
              //                       const SliverGridDelegateWithFixedCrossAxisCount(
              //                     crossAxisCount: 2,
              //                     crossAxisSpacing: 12,
              //                     mainAxisSpacing: 12,
              //                     childAspectRatio: 3 / 4,
              //                   ),
              //                   itemCount: sellerProfile.cars.length,
              //                   itemBuilder: (context, index) {
              //                     return Card(
              //                       elevation: 4,
              //                       shape: RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.circular(12),
              //                       ),
              //                       child: Column(
              //                         crossAxisAlignment: CrossAxisAlignment.start,
              //                         children: [
              //                           Image.asset(
              //                             sellerProfile.cars[index].imageUrl ??
              //                                 'assets/default_car_image.png',
              //                             height: 100,
              //                             width: double.infinity,
              //                             fit: BoxFit.cover,
              //                           ),
              //                           Padding(
              //                             padding: const EdgeInsets.all(8.0),
              //                             child: Column(
              //                               crossAxisAlignment:
              //                                   CrossAxisAlignment.start,
              //                               children: [
              //                                 Text(
              //                                   sellerProfile.cars[index].carName,
              //                                   style: const TextStyle(
              //                                       fontWeight: FontWeight.bold,
              //                                       overflow: TextOverflow.ellipsis),
              //                                 ),
              //                                 Text(
              //                                   'Rp${sellerProfile.cars[index].price}',
              //                                   style: const TextStyle(
              //                                       color: Colors.blue),
              //                                 ),
              //                               ],
              //                             ),
              //                           ),
              //                         ],
              //                       ),
              //                     );
              //                   },
              //                 )
              //               : const Text('Penjual belum menjual mobil.'),
              //         ],
              //       );
              //     } else {
              //       return const Center(child: Text('This user is not a seller.'));
              //     }
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
