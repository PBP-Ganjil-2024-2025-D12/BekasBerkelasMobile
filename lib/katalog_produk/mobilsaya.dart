import 'dart:convert';
import 'package:flutter/material.dart';
import '../authentication/services/auth.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'Car_entry.dart';
import 'add_car.dart';
import 'package:http/http.dart' as http;


class CarFiltered {
  final String name;
  final double price;

  CarFiltered({required this.name, required this.price});

  // Factory constructor to create a CarFiltered object from JSON
  factory CarFiltered.fromJson(Map<String, dynamic> json) {
    return CarFiltered(
      name: json['car_name'],  // Adjust key names based on your JSON structure
      price: double.tryParse(json['price'].toString()) ?? 0.0,
    );
  }
}

class CarListScreen extends StatefulWidget {
  @override
  _CarListScreenState createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  late List<CarEntry> cars = [];
  String role = '';
  bool verif = false;
  String uname = '';
  @override
  void initState() {
    super.initState();
    fetchUserData();
    
  }
  Future<void> fetchUserData() async {
    try {
      final authService = AuthService();
      final userData = await authService.getUserData();
      uname = userData['username'] ?? '';
      await fetchSellerVerif(uname);
      setState(() {
        role = userData['role'] ?? ''; // Store the user's role
        if (verif) {
            fetchFilter(); // Fetch cars only if verification is true
          } else {
            print('Seller is not verified.');
          }
      });
    } catch (e) {
      print("An error occurred while fetching user data: $e");
    }
  }
Future<void> fetchSellerVerif(String username) async {
    final String url = "http://127.0.0.1:8000/katalog/api/get-seller-verif/$username/";
    final response = await http.get(Uri.parse(url));  // This is the HTTP response

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);  // Decode JSON only after checking status code
      verif = data['seller_verif'];  // Assuming the username is directly available
    } else {
      throw Exception('Failed to fetch seller username. Status Code: ${response.statusCode}');
    }
  }

  Future<void> fetchFilter() async {
    try {
      print("Fetching filtered cars...");
      final request = Provider.of<CookieRequest>(context, listen: false);
      final authService = AuthService();
      final userData = await authService.getUserData();
      final username = userData['username'] ?? "defaultUsername";
      final payload = jsonEncode({'username': username});

      print("Payload being sent: $payload");

      final url = "http://127.0.0.1:8000/katalog/api/mobilsaya/";
      final response = await request.postJson(url, payload);

      // Parse the response
      List<CarEntry> fetchedCars = [];
      for (var car in response) {
        fetchedCars.add(CarEntry.fromJson(car));
      }

      setState(() {
        cars = fetchedCars;
      });
    } catch (e) {
      print("An error occurred while fetching filtered cars: $e");
    }
  }

  Future<void> deleteCar(String carId, int index) async {
  try {
    final request = Provider.of<CookieRequest>(context, listen: false);
    final userData = await AuthService().getUserData();
    final username = userData['username'] ?? "defaultUsername";
    final payload = jsonEncode({
      'car_id': carId,
      'username': username,
    });

    final url = "http://127.0.0.1:8000/katalog/api/mobilsaya/delete/"; // Ensure this matches your actual API
    final response = await request.postJson(url, payload);

    // Handling text response directly
     await fetchFilter();

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



Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
  title: Row(
    children: [
      Image.asset(
        'assets/logo-only.png',  // Make sure the logo asset is correctly placed in your assets folder
        height: 20,         // Adjust size as necessary
      ),
      const SizedBox(width: 10),  // Space between logo and title
      const Text(
        'Cars Sold by You',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  ),
  elevation: 2,
  actions: (role == 'SEL' && verif) ? [
    IconButton(
      icon: const Icon(Icons.add),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddCarFormPage()),
        );
      },
      tooltip: 'Add Car',
    ),
  ] : null,
),
    body: (role == 'SEL' && verif) ? buildFilteredCarsList() : buildRoleError(),
  );
}

Widget buildRoleError() {
  return Center(
    child: Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Access Restricted',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You must be a verified seller to view this content.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildFilteredCarsList() {
  if (cars.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Cars Listed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start selling by adding your first car',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  return ListView.builder(
    padding: const EdgeInsets.all(8),
    itemCount: cars.length,
    itemBuilder: (context, index) {
      final car = cars[index];
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.directions_car,
              color: Colors.blue[400],
              size: 32,
            ),
          ),
          title: Text(
            car.fields.carName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                '${car.fields.brand} ${car.fields.year}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\Rp${car.fields.price}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.red[400],
            iconSize: 28,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Car'),
                  content: const Text(
                    'Are you sure you want to delete this car listing?'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () {
                        deleteCar(car.pk, index);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'DELETE',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}}