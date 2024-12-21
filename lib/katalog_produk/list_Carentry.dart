import 'package:flutter/material.dart';
import 'Car_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'detail.dart';
import 'add_car.dart';
import 'myacc.dart';
import 'dart:convert';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';
import 'mobilsaya.dart';
import '../review_rating/screens/profile.dart';
import 'package:http/http.dart' as http;

class CarEntryPage extends StatefulWidget {
  const CarEntryPage({super.key});

  @override
  State<CarEntryPage> createState() => _CarEntryPageState();
}

class _CarEntryPageState extends State<CarEntryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = "Car Name";
  List<CarEntry> cars = [];
  bool isLoading = true;
  late Future<List<CarEntry>> _carFuture;
  List<String> _wishlistCarIds = [];
  Map<String, bool> _wishlistStatus = {};
  
  @override
  void initState() {
    super.initState();
    _carFuture = fetchCar(context.read<CookieRequest>());
    _fetchWishlistCarIds();
  }

  final ButtonStyle addStyle = ElevatedButton.styleFrom(
    foregroundColor: const Color(0xFF0A39C4), backgroundColor: Colors.white,
  );

  final ButtonStyle removeStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white, backgroundColor: const Color(0xFF0A39C4),
  );
   Future<String> fetchSellerUsername(String carId) async {
    final String url = "http://127.0.0.1:8000/katalog/api/get-seller-username/$carId/";
    final response = await http.get(Uri.parse(url));  // This is the HTTP response

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);  // Decode JSON only after checking status code
      return data['seller_username'];  // Assuming the username is directly available
    } else {
      throw Exception('Failed to fetch seller username. Status Code: ${response.statusCode}');
    }
  }
  Future<Map<String, String>> fetchSellerContact(String carId) async {
  final String url = "http://127.0.0.1:8000/katalog/api/get-seller-contact/$carId/";
  final response = await http.get(Uri.parse(url));  // This is the HTTP response

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);  // Decode JSON only after checking status code
    return {
      'email': data['email'],  // Assuming 'seller_email' is the key for email in the JSON
      'phone_number': data['no_telp'],  // Assuming 'seller_phone_number' is the key for phone number
    };
  } else {
    throw Exception('Failed to fetch seller contact information. Status Code: ${response.statusCode}');
  }
}

  
  Future<List<CarEntry>> fetchCar(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/katalog/carsjson/');
    List<CarEntry> listCar = [];
    for (var d in response) {
      if (d != null) {
        listCar.add(CarEntry.fromJson(d));
      }
    }
    return listCar;
  }
  void showContactSellerDialog(BuildContext context, String carId) async {
  // Fetch the seller's contact details
  Map<String, String> contactInfo = await fetchSellerContact(carId);

  // Extract email and phone number
  String email = contactInfo['email'] ?? "Email not available";
  String phoneNumber = contactInfo['phone_number'] ?? "Phone number not available";

  // Show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Contact Seller'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Email: $email'),
            Text('Phone Number: $phoneNumber'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
Future<void> fetchFilteredCars() async {
  final request = context.read<CookieRequest>();

  // Build query parameters
  Map<String, String> queryParams = {};
  if (_searchController.text.isNotEmpty) {
    switch (_selectedFilter) {
      case "Car Name":
        queryParams['car_name'] = _searchController.text;
        break;
      case "Brand":
        queryParams['brand'] = _searchController.text;
        break;
      case "Year":
        queryParams['year'] = _searchController.text;
        break;
      case "Price Max":
        queryParams['price_max'] = _searchController.text;
        break;
      case "Plate Type":
        queryParams['plate_type'] = _searchController.text;
        break;
      default:
        break;
    }
  }

  final queryString = Uri(queryParameters: queryParams).query;

  // Assign a new future to _carFuture
  setState(() {
    _carFuture = request.get(
      'http://127.0.0.1:8000/katalog/api/cars/filter/?$queryString',
    ).then((response) {
      return (response as List).map((d) => CarEntry.fromJson(d)).toList();
    });
  });
}




  Future<void> _fetchWishlistCarIds() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('http://127.0.0.1:8000/wishlist/car_ids/');
      if (response is Map && response.containsKey('car_ids')) {
        List<String> carIds = List<String>.from(response['car_ids']);
        setState(() {
          _wishlistCarIds = carIds;
          _wishlistStatus = {
            for (var id in _wishlistCarIds) id: true
          };
        });
      } else {
        print('Unexpected response format: $response');
      }
    } catch (e) {
      print('Error fetching wishlist car IDs: $e');
    }
  }

  Future<void> _addToWishlist(BuildContext context, String carId, String carName, bool isInWishlist) async {
    setState(() {
      _wishlistStatus[carId] = !isInWishlist;
    });

    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/wishlist/add_wishlist/$carId/',
        jsonEncode(<String, String>{'add': !_wishlistStatus[carId]! ? 'yes' : 'no'}),
      );

      if (response['status'] == 'success') {
        String action = response['action'];
        String message = response['message'];

        // Customize the SnackBar message based on the action
        String snackBarMessage;
        if (action == 'added') {
          snackBarMessage = '$carName ditambahkan ke Wishlist';
        } else if (action == 'removed') {
          snackBarMessage = '$carName dihapus dari Wishlist';
        } else {
          snackBarMessage = '$carName $message';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackBarMessage),
            duration: const Duration(seconds: 2),
          ),
        );
        await _fetchWishlistCarIds();
      } else {
        setState(() {
          _wishlistStatus[carId] = isInWishlist;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response['message']}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _wishlistStatus[carId] = isInWishlist;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Entry List'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Implement navigation or functionality for "My Account"
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CarListScreen()), // Replace with your actual account page
              );
            },
            child: const Text(
              'Mobil Saya',
              style: TextStyle(color: Colors.black),
            ),
            ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCarFormPage()),
              );
            },
            child: const Text(
              'Add Car',
              style: TextStyle(color: Colors.black),
            ),
          ),
           TextButton(
            onPressed: () {
              // Implement navigation or functionality for "My Account"
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyAccountPage()), // Replace with your actual account page
              );
            },
            child: const Text(
              'My Account',
              style: TextStyle(color: Colors.black),
            ),
            ),
        ],
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by car name",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              onSubmitted: (_) => fetchFilteredCars(), // Trigger search on submit
            ),
          ),
          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _selectedFilter,
              isExpanded: true,
              items: <String>["Car Name", "Brand", "Year", "Plate Type", "Price Max"]
                  .map((filter) => DropdownMenuItem<String>(
                        value: filter,
                        child: Text(filter),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
            ),
          ),
          // List of Cars
          Expanded(
            child: FutureBuilder(
              future: _carFuture,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (_, index) {
                      final CarEntry = snapshot.data![index];
                      bool isInWishlist = _wishlistStatus[CarEntry.pk.toString()] ?? false;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CarEntry.fields.carName,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(CarEntry.fields.price),
                            const SizedBox(height: 10),
                            CarEntry.fields.imageUrl != null
                                ? Image.network(
                                    CarEntry.fields.imageUrl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : const Text('No image available'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CarDetailPage(carEntry: CarEntry),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Detail',
                                    style: TextStyle(color: const Color(0xFF0A39C4)),
                                    ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: isInWishlist ? removeStyle : addStyle,
                                  onPressed: () => _addToWishlist(context, CarEntry.pk.toString(), CarEntry.fields.carName, isInWishlist),
                                  child: Text(isInWishlist ? "Remove from Wishlist" : "Add to Wishlist"),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    showContactSellerDialog(context, CarEntry.pk); // Use CarEntry.pk for the car ID
                                  },
                                  child: Text(
                                    'Contact Seller',
                                    style: TextStyle(color: Color(0xFF0A39C4)),
                                  ),
)
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No Car entries found'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
