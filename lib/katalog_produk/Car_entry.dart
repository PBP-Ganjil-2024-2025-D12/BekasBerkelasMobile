// To parse this JSON data, do
//
//     final CarEntry = CarEntryFromJson(jsonString);

import 'dart:convert';

List<CarEntry> CarEntryFromJson(String str) => List<CarEntry>.from(json.decode(str).map((x) => CarEntry.fromJson(x)));

String CarEntryToJson(List<CarEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CarEntry {
    String model;
    String pk;
    Fields fields;

    CarEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory CarEntry.fromJson(Map<String, dynamic> json) => CarEntry(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int seller;
    String carName;
    String brand;
    int year;
    int mileage;
    String location;
    String transmission;
    String plateType;
    bool rearCamera;
    bool sunRoof;
    bool autoRetractMirror;
    bool electricParkingBrake;
    bool mapNavigator;
    bool vehicleStabilityControl;
    bool keylessPushStart;
    bool sportsMode;
    bool camera360View;
    bool powerSlidingDoor;
    bool autoCruiseControl;
    String price;
    String instalment;
    String imageUrl;

    Fields({
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
        required this.imageUrl,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        seller: json["seller"],
        carName: json["car_name"],
        brand: json["brand"],
        year: json["year"],
        mileage: json["mileage"],
        location: json["location"],
        transmission: json["transmission"],
        plateType: json["plate_type"],
        rearCamera: json["rear_camera"],
        sunRoof: json["sun_roof"],
        autoRetractMirror: json["auto_retract_mirror"],
        electricParkingBrake: json["electric_parking_brake"],
        mapNavigator: json["map_navigator"],
        vehicleStabilityControl: json["vehicle_stability_control"],
        keylessPushStart: json["keyless_push_start"],
        sportsMode: json["sports_mode"],
        camera360View: json["camera_360_view"],
        powerSlidingDoor: json["power_sliding_door"],
        autoCruiseControl: json["auto_cruise_control"],
        price: json["price"],
        instalment: json["instalment"],
        imageUrl: json["image_url"],
    );

    Map<String, dynamic> toJson() => {
        "seller": seller,
        "car_name": carName,
        "brand": brand,
        "year": year,
        "mileage": mileage,
        "location": location,
        "transmission": transmission,
        "plate_type": plateType,
        "rear_camera": rearCamera,
        "sun_roof": sunRoof,
        "auto_retract_mirror": autoRetractMirror,
        "electric_parking_brake": electricParkingBrake,
        "map_navigator": mapNavigator,
        "vehicle_stability_control": vehicleStabilityControl,
        "keyless_push_start": keylessPushStart,
        "sports_mode": sportsMode,
        "camera_360_view": camera360View,
        "power_sliding_door": powerSlidingDoor,
        "auto_cruise_control": autoCruiseControl,
        "price": price,
        "instalment": instalment,
        "image_url": imageUrl,
    };
}