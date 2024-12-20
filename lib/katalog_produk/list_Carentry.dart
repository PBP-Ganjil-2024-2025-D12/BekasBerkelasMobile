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

class CarEntryPage extends StatefulWidget {
  const CarEntryPage({super.key});

  @override
  State<CarEntryPage> createState() => _CarEntryPageState();
}

class _CarEntryPageState extends State<CarEntryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = "All";
  late Future<List<CarEntry>> _carFuture;
  List<String> _wishlistCarIds = [];
  Map<String, bool> _wishlistStatus = {};
  
  @override
  void initState() {
    super.initState();
    _carFuture = fetchCar(context.read<CookieRequest>());
    _fetchWishlistCarIds();
  }

  final ButtonStyle addStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.deepPurple, backgroundColor: Colors.white,
  );

  final ButtonStyle removeStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
  );
  
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

  Future<void> _fetchWishlistCarIds() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get('http://127.0.0.1:8000/wishlist/car_ids/');
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
        'http://127.0.0.1:8000/wishlist/add_wishlist/$carId/',
        jsonEncode(<String, String>{'add': !_wishlistStatus[carId]! ? 'yes' : 'no'}),
      );

      if (response['status'] == 'success') {
        String action = response['action'];
        String message = response['message'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$carName $message'),
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
            onPressed: () {
              // Implement navigation or functionality for "My Account"
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CarListScreen()), // Replace with your actual account page
              );
            },
            child: const Text(
              'Mobil Saya',
              style: TextStyle(color: Colors.black),
            ),
            ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCarFormPage()),
              );
            },
            child: const Text(
              'Add Car',
              style: TextStyle(color: Colors.black),
            ),
          ),
           TextButton(
            onPressed: () {
              // Implement navigation or functionality for "My Account"
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyAccountPage()), // Replace with your actual account page
              );
            },
            child: const Text(
              'My Account',
              style: TextStyle(color: Colors.black),
            ),
            ),
        ],
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by car name",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _selectedFilter,
              isExpanded: true,
              items: <String>["All", "Brand", "Year"]
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
          ),
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
                                        builder: (context) =>
                                            CarDetailPage(carEntry: CarEntry),
                                      ),
                                    );
                                  },
                                  child: const Text('Detail'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: isInWishlist ? removeStyle : addStyle,
                                  onPressed: () => _addToWishlist(context, CarEntry.pk.toString(), CarEntry.fields.carName, isInWishlist),
                                  child: Text(isInWishlist ? "Remove from Wishlist" : "Add to Wishlist"),
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
          ),
        ],
      ),
    );
  }
}
