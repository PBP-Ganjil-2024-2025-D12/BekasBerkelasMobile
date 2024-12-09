import 'package:bekas_berkelas_mobile/katalog_produk/Car_entry.dart';
import 'dart:convert';

List<WishlistEntry> wishlistEntryFromJson(String str) => List<WishlistEntry>.from(
    json.decode(str).map((x) => WishlistEntry.fromJson(x)));

String wishlistEntryToJson(List<WishlistEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WishlistEntry {
  String model;
  String pk;
  WishlistFields fields;

  WishlistEntry({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory WishlistEntry.fromJson(Map<String, dynamic> json) => WishlistEntry(
        model: json["model"],
        pk: json["pk"],
        fields: WishlistFields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
      };
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

  factory WishlistFields.fromJson(Map<String, dynamic> json) => WishlistFields(
        user: json["user"].toString(),
        car: CarEntry.fromJson(json["car"]), 
        priority: json["priority"],
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "car": car,
        "priority": priority,
      };
}
