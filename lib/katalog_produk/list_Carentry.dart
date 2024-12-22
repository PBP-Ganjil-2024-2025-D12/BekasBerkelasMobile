import 'package:flutter/material.dart';
import 'Car_entry.dart';
import '../authentication/services/auth.dart'; 
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
  String role = '';
  
  @override
  void initState() {
    super.initState();
    _carFuture = fetchCar(context.read<CookieRequest>());
    _fetchWishlistCarIds();
  }
  Future<void> fetchUserData() async {
    try {
      final authService = AuthService();
      final userData = await authService.getUserData();
      setState(() {
        role = userData['role'] ?? ''; // Store the user's role
      });
    } catch (e) {
      print("An error occurred while fetching user data: $e");
    }
  }

  final ButtonStyle addStyle = ElevatedButton.styleFrom(
    foregroundColor: const Color(0xFF0A39C4), backgroundColor: Colors.white,
  );

  final ButtonStyle removeStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white, backgroundColor: const Color(0xFF0A39C4),
  );

   Future<String> fetchSellerVerif(String carId) async {
    final String url = "https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/katalog/api/get-seller-verif/$carId/";
    final response = await http.get(Uri.parse(url));  // This is the HTTP response

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);  // Decode JSON only after checking status code
      return data['seller_verif'];  // Assuming the username is directly available
    } else {
      throw Exception('Failed to fetch seller username. Status Code: ${response.statusCode}');
    }
  }
   Future<String> fetchSellerUsername(String carId) async {
    final String url = "https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/katalog/api/get-seller-username/$carId/";
    final response = await http.get(Uri.parse(url));  // This is the HTTP response

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);  // Decode JSON only after checking status code
      return data['seller_username'];  // Assuming the username is directly available
    } else {
      throw Exception('Failed to fetch seller username. Status Code: ${response.statusCode}');
    }
  }
  Future<Map<String, String>> fetchSellerContact(String carId) async {
  final String url = "https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/katalog/api/get-seller-contact/$carId/";
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
 Future<void> deleteCarAdmin(String carId) async {
  try {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final payload = jsonEncode({
      'car_id': carId,
    });

    final url = "https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/katalog/api/deleteAdmin/"; // Ensure this matches your actual API
    final response = await request.postJson(url, payload);

    // Handling text response directly
    _carFuture = fetchCar(context.read<CookieRequest>());

    // Check if the car with specific carId is still present in the list
    if (!cars.any((car) => car.pk == carId)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Car deleted successfully")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete car")));
    }
  } catch (e) {
    print("Error deleting the car: $e");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error occurred while deleting the car")));
  }
}
  
  Future<List<CarEntry>> fetchCar(CookieRequest request) async {
    final response = await request.get('https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/katalog/carsjson/');
    List<CarEntry> listCar = [];
    for (var d in response) {
      if (d != null) {
        listCar.add(CarEntry.fromJson(d));
      }
    }
    return listCar;
  }
  String formatCurrencyManually(String price) {
  // Parse the string to a double
  double parsedPrice = double.tryParse(price) ?? 0.0;

  // Split the price into whole and fractional parts
  List<String> parts = parsedPrice.toStringAsFixed(2).split('.');
  String wholePart = parts[0];
  String fractionalPart = parts[1];

  // Add thousand separators to the whole part
  String formattedWholePart = '';
  for (int i = wholePart.length - 1, j = 1; i >= 0; i--, j++) {
    formattedWholePart = wholePart[i] + formattedWholePart;
    if (j % 3 == 0 && i != 0) {
      formattedWholePart = '.' + formattedWholePart;
    }
  }

  // Combine the formatted whole part and fractional part
  return 'Rp$formattedWholePart,$fractionalPart';
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
      case "Transmission":
        queryParams['transmission'] = _searchController.text;
        break;
      default:
        break;
    }
  }

  final queryString = Uri(queryParameters: queryParams).query;

  // Assign a new future to _carFuture
  setState(() {
    _carFuture = request.get(
      'https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/katalog/api/cars/filter/?$queryString',
    ).then((response) {
      return (response as List).map((d) => CarEntry.fromJson(d)).toList();
    });
  });
}

  Future<void> _fetchWishlistCarIds() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/wishlist/car_ids/');
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
        'https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/wishlist/add_wishlist/$carId/',
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
      title: Row(
        children: [
          Image.asset(
            'assets/logo-only.png',
            height: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'Car Entry List',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
      elevation: 2,
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CarListScreen()),
            );
          },
          child: const Text(
            'Mobil Saya',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
    drawer: const LeftDrawer(),
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search by ...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(color: Colors.blueAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
            onSubmitted: (_) => fetchFilteredCars(),
          ),
          const SizedBox(height: 8), // Space between search bar and dropdown
          // Filter Dropdown
          DropdownButton<String>(
            value: _selectedFilter,
            isExpanded: true,
            items: <String>["Car Name", "Brand", "Year", "Plate Type", "Price Max", "Transmission"]
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
          const SizedBox(height: 8), // Space between dropdown and list
          // List of Cars
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
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Car Image
                 CarEntry.fields.imageUrl != null && CarEntry.fields.imageUrl.isNotEmpty
    ? Image.network(
        CarEntry.fields.imageUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          // This fallback will be used if loading the network image fails
          return Image.asset(
            'assets/logo-only.png', // Path to your local fallback image
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          );
        },
      )
    : Image.asset(
        'assets/logo-only.png', // Path to your local fallback image
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
                  const SizedBox(width: 16), // Space between image and text
                  // Car Details
                  Expanded(
                    child: Column(
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
                        Text(
                          'Price: ${formatCurrencyManually(CarEntry.fields.price)}',
  style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CarDetailPage(carEntry: CarEntry),
                                  ),
                                );
                              },
                              child: const Text('Detail'),
                            ),
                            const SizedBox(width: 4),
                            
                            ElevatedButton(
                              style: isInWishlist ? removeStyle : addStyle,
                              onPressed: () => _addToWishlist(context, CarEntry.pk.toString(), CarEntry.fields.carName, isInWishlist),
                              child: Text(isInWishlist ? "Remove" : "Add"),
                            ),
                            const SizedBox(width: 4),
                            ElevatedButton(
                              onPressed: () {
                                showContactSellerDialog(context, CarEntry.pk);
                              },
                              child: const Text('Contact'),
                            ),
                            if (role == 'ADM') ...[
                            const SizedBox(width: 4),
                            ElevatedButton(
                              onPressed: () {
                                deleteCarAdmin(CarEntry.pk);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                          ],
                        ),
                      ],
                    ),
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
    ),
  );
}}