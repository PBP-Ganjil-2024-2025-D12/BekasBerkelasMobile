import 'package:flutter/material.dart';
import 'funcs_katalog_produk.dart';

class CarListScreen extends StatelessWidget {
  final CarService carService = CarService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Car List")),
      body: FutureBuilder<List<dynamic>>(
        future: carService.fetchCars(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final cars = snapshot.data!;
            return ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return ListTile(
                  title: Text(car['car_name']),
                  subtitle: Text(car['brand']),
                  trailing: Text("\$${car['price']}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarDetailScreen(carId: car['id']),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return Center(child: Text("No cars available"));
          }
        },
      ),
    );
  }
}
