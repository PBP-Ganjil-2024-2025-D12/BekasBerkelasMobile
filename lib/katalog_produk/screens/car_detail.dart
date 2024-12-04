import 'package:flutter/material.dart';
import '../service.dart';

class CarDetailScreen extends StatelessWidget {
  final String carId;

  CarDetailScreen({required this.carId});

  final CarService _carService = CarService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Car Details"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _carService.fetchCarDetails(carId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return Center(child: Text("Car details not available"));
          }

          final car = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car['name'] ?? "Unknown Car",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text("Price: ${car['price'] ?? 'N/A'}"),
                SizedBox(height: 10),
                Text("Description: ${car['description'] ?? 'No description'}"),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                  },
                  child: Text("Contact Seller"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
