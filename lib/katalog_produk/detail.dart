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

class CarDetailPage extends StatelessWidget {
  final CarEntry carEntry;

  const CarDetailPage({Key? key, required this.carEntry}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, 'Car details', true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Model: ${carEntry.model}', style: TextStyle(fontSize: 18)),
            Text('Primary Key: ${carEntry.pk}', style: TextStyle(fontSize: 18)),
            Text('Seller ID: ${carEntry.fields.seller}', style: TextStyle(fontSize: 18)),
            Text('Car Name: ${carEntry.fields.carName}', style: TextStyle(fontSize: 18)),
            Text('Brand: ${carEntry.fields.brand}', style: TextStyle(fontSize: 18)),
            Text('Year: ${carEntry.fields.year}', style: TextStyle(fontSize: 18)),
            Text('Mileage: ${carEntry.fields.mileage}', style: TextStyle(fontSize: 18)),
            Text('Location: ${carEntry.fields.location}', style: TextStyle(fontSize: 18)),
            Text('Transmission: ${carEntry.fields.transmission}', style: TextStyle(fontSize: 18)),
            Text('Plate Type: ${carEntry.fields.plateType}', style: TextStyle(fontSize: 18)),
            Text('Rear Camera: ${carEntry.fields.rearCamera ? "Yes" : "No"}', style: TextStyle(fontSize: 18)),
            Text('Sun Roof: ${carEntry.fields.sunRoof ? "Yes" : "No"}', style: TextStyle(fontSize: 18)),
            Text('Auto Retract Mirror: ${carEntry.fields.autoRetractMirror ? "Yes" : "No"}', style: TextStyle(fontSize: 18)),
            Text('Electric Parking Brake: ${carEntry.fields.electricParkingBrake ? "Yes" : "No"}', style: TextStyle(fontSize: 18)),
            Text('Map Navigator: ${carEntry.fields.mapNavigator ? "Yes" : "No"}', style: TextStyle(fontSize: 18)),
            Text('Vehicle Stability Control: ${carEntry.fields.vehicleStabilityControl ? "Yes" : "No"}', style: TextStyle(fontSize: 18)),
            Text('Keyless Push Start: ${carEntry.fields.keylessPushStart ? "Yes" : "No"}', style: TextStyle(fontSize: 18)),
            Text('Sports Mode: ${carEntry.fields.sportsMode ? "Yes" : "No"}', style: TextStyle(fontSize: 18)),
            Text('360° Camera View: ${carEntry.fields.camera360View ? "Yes" : "No"}', style: TextStyle(fontSize: 18)),
            Text('Power Sliding Door: ${carEntry.fields.powerSlidingDoor ? "Yes" : "No"}', style: TextStyle(fontSize: 18)),
            Text('Auto Cruise Control: ${carEntry.fields.autoCruiseControl ? "Yes" : "No"}', style: TextStyle(fontSize: 18)),
            Text('Price: ${carEntry.fields.price}', style: TextStyle(fontSize: 18)),
            Text('Instalment: ${carEntry.fields.instalment}', style: TextStyle(fontSize: 18)),
            Text('Image URL: ${carEntry.fields.imageUrl}', style: TextStyle(fontSize: 18)),
            carEntry.fields.imageUrl.isNotEmpty ? Image.network(carEntry.fields.imageUrl) : Container(),
            ElevatedButton(
                                onPressed: () async {
                                  // Fetch the seller's username using the car primary key (pk)
                                  String username = await fetchSellerUsername(carEntry.pk);
                                  // Navigate to the ProfileScreen with the fetched username
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProfileScreen(username: username),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Seller Profile',
                                  style: TextStyle(color: Color(0xFF0A39C4)),
                                ),
                              )
          ],
        ),
      ),
    );
  }
}
