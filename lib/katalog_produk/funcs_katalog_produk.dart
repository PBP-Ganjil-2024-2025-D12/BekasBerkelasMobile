import 'dart:convert';
import 'package:http/http.dart' as http;

class CarService {
  final String baseUrl = "http://127.0.0.1:8000/product_catalog"; //sementara

  Future<List<dynamic>> fetchCars() async {
    final response = await http.get(Uri.parse('$baseUrl/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Fail");
    }
  }

  Future<List<dynamic>> fetchSellerCars() async {
    final response = await http.get(Uri.parse('$baseUrl/mobil_saya/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Fail");
    }
  }

  Future<Map<String, dynamic>> fetchCarDetails(String carId) async {
    final response = await http.get(Uri.parse('$baseUrl/detail/$carId/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Fail");
    }
  }

  Future<void> deleteCar(String carId) async {
    final response = await http.delete(Uri.parse('$baseUrl/delete_car/$carId/'));
    if (response.statusCode != 204) {
      throw Exception("Fail");
    }
  }

  Future<Map<String, dynamic>> contactSeller(String carId) async {
    final response = await http.get(Uri.parse('$baseUrl/car/$carId/contact/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Fail");
    }
  }

  Future<void> createCar(Map<String, dynamic> carData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create_car/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(carData),
    );
    if (response.statusCode != 201) {
      throw Exception("Fail");
    }
  }
}
