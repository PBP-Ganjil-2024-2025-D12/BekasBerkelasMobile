import 'dart:convert';
import 'package:flutter/material.dart';
import '../authentication/services/auth.dart';  // Adjust the import path to where AuthService is located
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';

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
  late List<CarFiltered> cars = [];

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
      List<CarFiltered> fetchedCars = [];
      for (var car in response['cars']) {
        fetchedCars.add(CarFiltered.fromJson(car));
      }

      setState(() {
        cars = fetchedCars;
      });
    } catch (e) {
      print("An error occurred while fetching filtered cars: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, 'My Cars', true),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return ListTile(
                  title: Text('${car.name} - \$${car.price.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: fetchFilter,  // Calls fetchFilter directly when button is pressed
            child: Text('Fetch Filtered Cars'),
          ),
        ],
      ),
    );
  }
}
