import 'dart:convert';
import 'package:bekas_berkelas_mobile/katalog_produk/Car_entry.dart';

List<WishlistEntry> wishlistEntryFromJson(String str) {
  return List<WishlistEntry>.from(
    json.decode(str).map((x) => WishlistEntry.fromJson(x)),
  );
}

String wishlistEntryToJson(List<WishlistEntry> data) {
  return json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}

class WishlistEntry {
  String id;
  String imageUrl;
  String carName;
  double price;
  String brand;
  int year;
  int mileage;
  int priority;

  WishlistEntry({
    required this.id,
    required this.imageUrl,
    required this.carName,
    required this.price,
    required this.brand,
    required this.year,
    required this.mileage,
    required this.priority,
  });

  factory WishlistEntry.fromJson(Map<String, dynamic> json) {
    return WishlistEntry(
      id: json["id"],
      imageUrl: json["image_url"],
      carName: json["car_name"],
      price: double.tryParse(json["price"] ?? "") ?? 0.0,
      brand: json["brand"],
      year: json["year"] ?? 0,
      mileage: json["mileage"] ?? 0,
      priority: json["priority"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "image_url": imageUrl,
      "car_name": carName,
      "price": price,
      "brand": brand,
      "year": year,
      "mileage": mileage,
      "priority": priority,
    };
  }

  String get priorityName {
    switch (priority) {
      case 1:
        return 'Rendah';
      case 2:
        return 'Sedang';
      case 3:
        return 'Tinggi';
      default:
        return 'Unknown';
    }
  }
}
class WishlistFields {
  String user;
  CarEntry car;
  int priority;

  WishlistFields({
    required this.user,
    required this.car,
    required this.priority,
  });

  factory WishlistFields.fromJson(Map<String, dynamic> json) {
    return WishlistFields(
      user: json["user"].toString(),
      car: CarEntry.fromJson(json["car"]),
      priority: json["priority"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user": user,
      "car": car.toJson(),
      "priority": priority,
    };
  }
}