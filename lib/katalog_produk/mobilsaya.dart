import 'dart:convert';
import 'package:flutter/material.dart';
import '../authentication/services/auth.dart';  // Adjust the import path to where AuthService is located
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'Car_entry.dart';

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




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cars Sold by You'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return ListTile(
                  title: Text('${car.fields.carName} - \$${car.fields.price}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteCar(car.pk, index),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: fetchFilter,
            child: Text('Fetch Filtered Cars'),
          ),
        ],
      ),
    );
  }
}