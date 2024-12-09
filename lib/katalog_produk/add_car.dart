import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AddCarFormPage extends StatefulWidget {
  const AddCarFormPage({super.key});

  @override
  State<AddCarFormPage> createState() => _AddCarFormPageState();
}

class _AddCarFormPageState extends State<AddCarFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers for each field
  TextEditingController _carNameController = TextEditingController();
  TextEditingController _brandController = TextEditingController();
  TextEditingController _yearController = TextEditingController();
  TextEditingController _mileageController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _transmissionController = TextEditingController();
  TextEditingController _plateTypeController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _instalmentController = TextEditingController();
  TextEditingController _imageUrlController = TextEditingController();

  // Boolean fields for switches
  Map<String, bool> features = {
    'rear_camera': false,
    'sun_roof': false,
    'auto_retract_mirror': false,
    'electric_parking_brake': false,
    'map_navigator': false,
    'vehicle_stability_control': false,
    'keyless_push_start': false,
    'sports_mode': false,
    'camera_360_view': false,
    'power_sliding_door': false,
    'auto_cruise_control': false,
  };

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Car'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildTextField(_carNameController, 'Car Name'),
              buildTextField(_brandController, 'Brand'),
              buildNumericTextField(_yearController, 'Year'),
              buildNumericTextField(_mileageController, 'Mileage'),
              buildTextField(_locationController, 'Location'),
              buildTextField(_transmissionController, 'Transmission'),
              buildTextField(_plateTypeController, 'Plate Type'),
              buildSwitches(),
              buildNumericTextField(_priceController, 'Price'),
              buildNumericTextField(_instalmentController, 'Instalment'),
              buildTextField(_imageUrlController, 'Image URL'),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      var data = {
                        'car_name': _carNameController.text,
                        'brand': _brandController.text,
                        'year': int.parse(_yearController.text),
                        'mileage': int.parse(_mileageController.text),
                        'location': _locationController.text,
                        'transmission': _transmissionController.text,
                        'plate_type': _plateTypeController.text,
                        'price': double.parse(_priceController.text),
                        'instalment': double.parse(_instalmentController.text),
                        'image_url': _imageUrlController.text,
                      };

                      features.forEach((key, value) {
                        data[key] = value;
                      });

                      final response = await request.postJson(

      "http://127.0.0.1:8000/katalog/create-flutter/",

                        jsonEncode(data),
                      );

                      if (response['status'] == 'success') {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Car successfully added!")));
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add car, please try again.")));
                      }
                    }
                  },
                  child: Text('Save Car', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }
          return null;
        },
      ),
    );
  }

  Widget buildNumericTextField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label cannot be empty';
          }
          if (double.tryParse(value) == null) {
            return '$label must be a number';
          }
          return null;
        },
      ),
    );
  }

  Widget buildSwitches() {
    return Column(
      children: features.keys.map((key) {
        return SwitchListTile(
          title: Text(key.replaceAll('_', ' ').toUpperCase()),
          value: features[key]!,
          onChanged: (bool value) {
            setState(() {
              features[key] = value;
            });
          },
        );
      }).toList(),
    );
  }
}
