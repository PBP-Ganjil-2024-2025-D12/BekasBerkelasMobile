import 'dart:convert';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../authentication/services/auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For mobile-specific features
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:http/http.dart' as http;

class AddCarFormPage extends StatefulWidget {
  const AddCarFormPage({super.key});

  @override
  State<AddCarFormPage> createState() => _AddCarFormPageState();
}

class _AddCarFormPageState extends State<AddCarFormPage> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? userData; // Field to store user data
  @override
  void initState() {
    super.initState();
    _loadUserData(); // Call async function
  }
  final ImagePicker _picker = ImagePicker();
bool isLoading = false; // For showing a loading indicator

Future<void> _pickImage(CookieRequest request, int id) async {
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    final String? uploadedUrl = await _uploadImageToCloudinary(image.path, request, id);

    if (uploadedUrl != null) {
      setState(() {
        _imageUrlController.text = uploadedUrl; // Set the Cloudinary URL to the controller
      });
    }
  }
}

Future<String?> _uploadImageToCloudinary(String imagePath, CookieRequest cookieRequest, int id) async {
  setState(() {
    isLoading = true; // Show loading indicator
  });

  try {
    const cloudinaryUrl = "https://api.cloudinary.com/v1_1/dknxfk0qc/image/upload";
    const preset = 'TK_PBP_D12';
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
      ..fields['upload_preset'] = preset
      ..fields['public_id'] = 'gambarmobil_${id}_$timestamp'
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);
      return jsonResponse['secure_url']; // Return the Cloudinary URL
    } else {
      _showSnackbar(context, 'Failed to upload image: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    _showSnackbar(context, 'Error occurred: $e');
    return null;
  } finally {
    setState(() {
      isLoading = false; // Hide loading indicator
    });
  }
}
void _showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

  Future<void> _loadUserData() async {
    final authService = AuthService();
    final data = await authService.getUserData();
    setState(() {
      userData = data; // Store user data and trigger UI update
    });
  }

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
      appBar: appBar(context, 'Add New Car', true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
    buildTextField(_carNameController, 'Car Name'),
    buildTextField(_brandController, 'Brand'),
    buildNumericTextField(_yearController, 'Year'),
    buildNumericTextField(_mileageController, 'Mileage'),
    buildLocationDropdown(), 
    buildTransmissionDropdown(), 
    buildPlateTypeDropdown(),
    buildSwitches(),
    buildNumericTextField(_priceController, 'Price'),
    buildNumericTextField(_instalmentController, 'Instalment'),
    buildImagePicker(), // New Image Picker Widget
  
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      var data = {
                        'username': userData!['username'], // Add username to the data
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
                      print(jsonEncode(data));

                      final response = await request.postJson(

      "https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/katalog/create-flutter/",

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
                  child: Text('Save Car', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildImagePicker() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image URL',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Pick Image'),
              onPressed: () async {
                final CookieRequest request = Provider.of<CookieRequest>(context, listen: false);
                await _pickImage(request, int.parse(userData!["user_id"])); // Replace `1` with the actual user ID
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _imageUrlController,
                readOnly: true, // Prevent manual editing
                decoration: const InputDecoration(
                  hintText: 'URL will appear here...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please upload an image.';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        if (isLoading) const CircularProgressIndicator(),
      ],
    ),
  );
}
  Widget buildPlateTypeDropdown() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Plate Type',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
      value: _plateTypeController.text.isNotEmpty ? _plateTypeController.text : null,
      items: const [
        DropdownMenuItem(
          value: 'Odd Plate',
          child: Text('Odd Plate'),
        ),
        DropdownMenuItem(
          value: 'Even Plate',
          child: Text('Even Plate'),
        ),
      ],
      onChanged: (String? newValue) {
        setState(() {
          _plateTypeController.text = newValue!; // Update the controller with the selected value
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a plate type';
        }
        return null;
      },
    ),
  );
}

Widget buildTransmissionDropdown() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Transmission',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
      value: _transmissionController.text.isNotEmpty ? _transmissionController.text : null,
      items: const [
        DropdownMenuItem(
          value: 'Manual',
          child: Text('Manual'),
        ),
        DropdownMenuItem(
          value: 'Automatic',
          child: Text('Automatic'),
        ),
      ],
      onChanged: (String? newValue) {
        setState(() {
          _transmissionController.text = newValue!; // Update the controller with the selected value
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a transmission type';
        }
        return null;
      },
    ),
  );
}

Widget buildLocationDropdown() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Location',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
      value: _locationController.text.isNotEmpty ? _locationController.text : null,
      items: const [
        DropdownMenuItem(
          value: 'Jakarta Pusat',
          child: Text('Jakarta Pusat'),
        ),
        DropdownMenuItem(
          value: 'Jakarta Barat',
          child: Text('Jakarta Barat'),
        ),
        DropdownMenuItem(
          value: 'Jakarta Timur',
          child: Text('Jakarta Timur'),
        ),
        DropdownMenuItem(
          value: 'Jakarta Utara',
          child: Text('Jakarta Utara'),
        ),
        DropdownMenuItem(
          value: 'Jakarta Selatan',
          child: Text('Jakarta Selatan'),
        ),
      ],
      onChanged: (String? newValue) {
        setState(() {
          _locationController.text = newValue!; // Update the controller with the selected value
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a location';
        }
        return null;
      },
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
