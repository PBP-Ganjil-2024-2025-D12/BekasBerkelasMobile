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
    final String url = "https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/katalog/api/get-seller-username/$carId/";
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
    appBar: appBar(context, 'Car Detail', true),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(context),
          const SizedBox(height: 20),
          _buildImage(),
          const SizedBox(height: 20),
          _buildSellerButton(context),
        ],
      ),
    ),
  );
}

Widget _buildInfoCard(BuildContext context) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCarBasicInfo(),
          const Divider(height: 24),
          _buildCarFeatures(),
          const Divider(height: 24),
          _buildPricingInfo(),
        ],
      ),
    ),
  );
}

Widget _buildCarBasicInfo() {
  // Wrap the basic car information in a blue box with a title "Main Info"
  return _buildBlueBox(
    title: "Main Info",
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,  // Maintain left alignment for details
        children: [
          _buildDetailItem('Car Name', carEntry.fields.carName),
          _buildDetailItem('Brand', carEntry.fields.brand),
          _buildDetailItem('Year', carEntry.fields.year.toString()),  // Ensure data types are handled correctly
          _buildDetailItem('Mileage', '${carEntry.fields.mileage} km'),  // Format mileage with units
          _buildDetailItem('Location', carEntry.fields.location),
          _buildDetailItem('Transmission', carEntry.fields.transmission),
          _buildDetailItem('Plate Type', carEntry.fields.plateType),
        ],
      ),
    ),
  );
}


Widget _buildCarFeatures() {
  final features = {
    'Rear Camera': carEntry.fields.rearCamera,
    'Sun Roof': carEntry.fields.sunRoof,
    'Auto Retract Mirror': carEntry.fields.autoRetractMirror,
    'Electric Parking Brake': carEntry.fields.electricParkingBrake,
    'Map Navigator': carEntry.fields.mapNavigator,
    'Vehicle Stability Control': carEntry.fields.vehicleStabilityControl,
    'Keyless Push Start': carEntry.fields.keylessPushStart,
    'Sports Mode': carEntry.fields.sportsMode,
    '360° Camera View': carEntry.fields.camera360View,
    'Power Sliding Door': carEntry.fields.powerSlidingDoor,
    'Auto Cruise Control': carEntry.fields.autoCruiseControl,
  };

  // Encapsulate features into the blue box with a title
  return _buildBlueBox(
    title: "Features",
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,  // Use center for aligning the features nicely
        children: features.entries
            .map((e) => _buildDetailItem(e.key, e.value ? "Yes" : "No"))
            .toList(),
      ),
    ),
  );
}

Widget _buildBlueBox({required Widget child, required String title}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.blue[50], // Light blue background
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.blue[300]!, width: 1), // Adds a light blue border
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800])),
        ),
        child,
      ],
    ),
  );
}


Widget _buildPricingInfo() {
  // This uses the _buildBlueBox method to wrap the pricing info with a blue background and a title
  return _buildBlueBox(
    title: "Pricing",  // Title for the pricing section
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem('Price', 'Rp ' + carEntry.fields.price.toString()),
          _buildDetailItem('Instalment', 'Rp ' + carEntry.fields.instalment.toString()),
        ],
      ),
    ),
  );
}


Widget _buildImage() {
  return carEntry.fields.imageUrl.isNotEmpty
      ? ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            carEntry.fields.imageUrl,
            fit: BoxFit.cover,
            height: 200,
            width: double.infinity,
            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
              // Log the error, optionally
              print('Failed to load network image, loading asset image instead.');

              return Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  'assets/logo-only.png', // Specify the fallback asset image
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        )
      : Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(child: Text('No Image Available')),
        );
}


Widget _buildSellerButton(BuildContext context) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ),
    onPressed: () async {
      final username = await fetchSellerUsername(carEntry.pk);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(username: username),
        ),
      );
    },
    child: const Text(
      'Seller Profile',
      style: TextStyle(fontSize: 16),
    ),
  );
}

Widget _buildDetailItem(String label, dynamic value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      '$label: $value',
      style: const TextStyle(fontSize: 16),
    ),
  );
}}