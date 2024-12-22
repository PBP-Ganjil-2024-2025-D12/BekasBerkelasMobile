import 'package:bekas_berkelas_mobile/katalog_produk/Car_entry.dart';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:bekas_berkelas_mobile/katalog_produk/detail.dart';

class CarsPage extends StatelessWidget {
  final List<CarEntry> cars;

  const CarsPage({
    super.key,
    required this.cars,
  });

  String formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, 'All Cars', true),
      body: cars.isEmpty
          ? const Center(
              child: Text(
                'No cars available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12, // Reduced from 16
                  mainAxisSpacing: 12, // Reduced from 16
                  childAspectRatio:
                      0.75, // Adjusted from 0.8 to give more vertical space
                ),
                itemCount: cars.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Container(
                              height: 110, // Reduced from 120
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Image.network(
                                cars[index].fields.imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF4C8BF5)),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.directions_car,
                                      size: 40, // Reduced from 50
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(8), // Reduced from 12
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 36, // Reduced from 40
                                    child: Text(
                                      cars[index].fields.carName,
                                      style: const TextStyle(
                                        fontSize: 13, // Reduced from 14
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF333333),
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Rp ${formatPrice(double.parse(cars[index].fields.price))}',
                                    style: const TextStyle(
                                      fontSize: 14, // Reduced from 16
                                      color: Color(0xFF4C8BF5),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6), // Reduced from 8
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6, // Reduced from 8
                                      vertical: 3, // Reduced from 4
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF4C8BF5),
                                          Color(0xFF6AA6F8)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'For Sale',
                                      style: TextStyle(
                                        fontSize: 11, // Reduced from 12
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarDetailPage(
                            carEntry: cars[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
