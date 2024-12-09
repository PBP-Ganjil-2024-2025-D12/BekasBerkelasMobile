import 'package:flutter/material.dart';
import 'Car_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'detail.dart'; 
import 'add_car.dart'; 

class CarEntryPage extends StatefulWidget {
  const CarEntryPage({super.key});

  @override
  State<CarEntryPage> createState() => _CarEntryPageState();
}

class _CarEntryPageState extends State<CarEntryPage> {
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

  void _addToWishlist(BuildContext context, String carName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$carName has been added to your wishlist!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showContactSellerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Seller'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Seller Name: Placeholder Name'),
                Text('Seller Email: placeholder@email.com'),
                Text('Seller Number: 123-456-7890'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
       appBar: AppBar(
        title: const Text('Car Entry List'),
        actions: <Widget>[
          TextButton(
            onPressed: () {Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddCarFormPage()),
            );
            },
            child: Text('Add Car', style: TextStyle(color: Colors.black)),  // Ensure text color contrasts with AppBar color
          ),
        ],
      ),
      body: FutureBuilder(
        future: fetchCar(request),
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
                                  builder: (context) => CarDetailPage(carEntry: CarEntry),
                                ),
                              );
                            },
                            child: const Text('Detail'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _addToWishlist(context, CarEntry.fields.carName),
                            child: const Text('Add to Wishlist'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _showContactSellerDialog(context),
                            child: const Text('Contact Seller'),
                          ),
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
    );
  }
}

class AddCarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Car'),
      ),
      body: Center(
        child: Text('Add Car Form Goes Here'),
      ),
    );
  }
}
