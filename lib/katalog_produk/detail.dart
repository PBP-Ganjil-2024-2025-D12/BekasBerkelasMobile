import 'package:flutter/material.dart';
import 'Car_entry.dart';

class CarDetailPage extends StatelessWidget {
  final CarEntry carEntry;

  const CarDetailPage({Key? key, required this.carEntry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Details'),
      ),
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
          ],
        ),
      ),
    );
  }
}
