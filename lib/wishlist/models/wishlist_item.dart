// import 'car.dart';

class WishlistItem {
  final String id;
  final String userId;
  // final Car car;
  final int priority;

  WishlistItem({
    required this.id,
    required this.userId,
    //required this.car,
    required this.priority,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'].toString(),
      userId: json['user'].toString(),
      // car: Car.fromJson(json['car']),
      priority: json['priority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      //'car': car.toJson(),
      'priority': priority,
    };
  }
}
