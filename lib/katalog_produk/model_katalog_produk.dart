class Car {
  final String id;
  final String seller;
  final String carName;
  final String brand;
  final int year;
  final int mileage;
  final String location;
  final String transmission;
  final String plateType;
  final bool rearCamera;
  final bool sunRoof;
  final bool autoRetractMirror;
  final bool electricParkingBrake;
  final bool mapNavigator;
  final bool vehicleStabilityControl;
  final bool keylessPushStart;
  final bool sportsMode;
  final bool camera360View;
  final bool powerSlidingDoor;
  final bool autoCruiseControl;
  final double price;
  final double instalment;
  final String? imageUrl;

  Car({
    required this.id,
    required this.seller,
    required this.carName,
    required this.brand,
    required this.year,
    required this.mileage,
    required this.location,
    required this.transmission,
    required this.plateType,
    required this.rearCamera,
    required this.sunRoof,
    required this.autoRetractMirror,
    required this.electricParkingBrake,
    required this.mapNavigator,
    required this.vehicleStabilityControl,
    required this.keylessPushStart,
    required this.sportsMode,
    required this.camera360View,
    required this.powerSlidingDoor,
    required this.autoCruiseControl,
    required this.price,
    required this.instalment,
    this.imageUrl,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      seller: json['seller'],
      carName: json['car_name'],
      brand: json['brand'],
      year: json['year'],
      mileage: json['mileage'],
      location: json['location'],
      transmission: json['transmission'],
      plateType: json['plate_type'],
      rearCamera: json['rear_camera'],
      sunRoof: json['sun_roof'],
      autoRetractMirror: json['auto_retract_mirror'],
      electricParkingBrake: json['electric_parking_brake'],
      mapNavigator: json['map_navigator'],
      vehicleStabilityControl: json['vehicle_stability_control'],
      keylessPushStart: json['keyless_push_start'],
      sportsMode: json['sports_mode'],
      camera360View: json['camera_360_view'],
      powerSlidingDoor: json['power_sliding_door'],
      autoCruiseControl: json['auto_cruise_control'],
      price: json['price'],
      instalment: json['instalment'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller': seller,
      'car_name': carName,
      'brand': brand,
      'year': year,
      'mileage': mileage,
      'location': location,
      'transmission': transmission,
      'plate_type': plateType,
      'rear_camera': rearCamera,
      'sun_roof': sunRoof,
      'auto_retract_mirror': autoRetractMirror,
      'electric_parking_brake': electricParkingBrake,
      'map_navigator': mapNavigator,
      'vehicle_stability_control': vehicleStabilityControl,
      'keyless_push_start': keylessPushStart,
      'sports_mode': sportsMode,
      'camera_360_view': camera360View,
      'power_sliding_door': powerSlidingDoor,
      'auto_cruise_control': autoCruiseControl,
      'price': price,
      'instalment': instalment,
      'image_url': imageUrl,
    };
  }
}
