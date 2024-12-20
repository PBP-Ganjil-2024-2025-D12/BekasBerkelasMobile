import 'dart:convert';
import 'package:bekas_berkelas_mobile/user_dashboard/widgets/button.dart';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'change_name.dart';
import 'change_email.dart';
import 'change_NoTelp.dart';
import 'change_password.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final String baseUrl = 'http://10.0.2.2:8000';
  late int id;
  late String name = '';
  late String email = '';
  late String phoneNumber = '';
  late String imageUrl = '';
  late String role = '';
  late String statusAkun = '';
  bool isLoading = false;

  Future<Map<String, dynamic>> _fetchData(CookieRequest request) async {
    try {
      final response = await request.post('$baseUrl/dashboard/get_user_flutter/', {});
      if (response['status'] == 'success') {
        return response;  
      } else {
        throw Exception('Failed to load data: ${response['status']}');
      }
    } catch (e) {
      throw Exception('Failed to parse JSON: $e');
    }
  }

  Future<void> _pickImage(CookieRequest request, int id) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _uploadImageToCloudinary(image.path, request, id);
    }
  }

  Future<void> _uploadImageToCloudinary(String imagePath, CookieRequest cookieRequest, int id) async {
    setState(() {
      isLoading = true; // Tampilkan indikator pemuatan
    });

    try {
      const cloudinaryUrl = "https://api.cloudinary.com/v1_1/dknxfk0qc/image/upload";
      const preset = 'TK_PBP_D12';
      final userid = id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
        ..fields['upload_preset'] = preset
        ..fields['public_id'] = 'profile_picture_user_${userid}_$timestamp'
        ..files.add(await http.MultipartFile.fromPath('file', imagePath));

      final response = await request.send();

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);

        final data = jsonEncode({
          'profile_picture_url': jsonResponse['secure_url'],
          'profile_picture_id': jsonResponse['public_id'],
        });

        final backendResponse = await cookieRequest.post("$baseUrl/dashboard/upload_profile_picture_flutter/", data);

        if (!mounted) return;

        if (backendResponse['status'] == 'success') {
          setState(() {
            imageUrl = jsonResponse['secure_url'];
          });
          _showSnackbar(context, 'Gambar berhasil diunggah.');
        } else {
          _showSnackbar(context, 'Gagal memperbarui gambar: ${backendResponse['message']}');
        }
      } else {
        _showSnackbar(context, 'Gagal mengunggah gambar: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackbar(context, 'Terjadi kesalahan: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchData(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: $snapshot'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            id = data['id'];
            name = data['nama'];
            email = data['email'];
            phoneNumber = data['no_telp'];
            imageUrl = data['profile_picture'];
            role = data['role'];
            statusAkun = data['status_akun'];

            return Stack(
              children : [
                Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: GestureDetector(
                                onTap: () => _pickImage(request, id),
                                child: const Text(
                                  'Ubah Foto Profil',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 9, 68, 127),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: SizedBox(
                                width: 300,
                                child: Row(
                                  children: [
                                    const Text(
                                      'Nama',
                                      style: TextStyle(fontSize: 18, color: Colors.grey),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      ': $name',
                                      style: const TextStyle(fontSize: 18, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: SizedBox(
                                width: 300,
                                child: Row(
                                  children: [
                                    const Text(
                                      'Email',
                                      style: TextStyle(fontSize: 18, color: Colors.grey),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      ': $email',
                                      style: const TextStyle(fontSize: 18, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: SizedBox(
                                width: 300,
                                child: Row(
                                  children: [
                                    const Text(
                                      'No Telp',
                                      style: TextStyle(fontSize: 18, color: Colors.grey),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      ': $phoneNumber',
                                      style: const TextStyle(fontSize: 18, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (role == "SEL" || role == "Seller")...[
                              const SizedBox(height: 10),
                              Center(
                                child: SizedBox(
                                  width: 300,
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Status',
                                        style: TextStyle(fontSize: 18, color: Colors.grey),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        ': $statusAkun',
                                        style: const TextStyle(fontSize: 18, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 40),
                            Center(
                              child: Column(
                                children: [
                                  SelectionButton(
                                    onPressed: () async {
                                      final newName = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ChangeNamePage()),
                                      );
                                      if (newName != null){
                                        setState(() {
                                          name = newName;
                                        });
                                      }
                                    }, 
                                    text: "Ubah Nama", 
                                    icon: Icons.person),
                                  const SizedBox(height: 10),
                                  SelectionButton(
                                    onPressed: () async {
                                      final newEmail = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const ChangeEmailPage()),
                                      );
                                      if (newEmail != null){
                                        setState(() {
                                          email = newEmail;
                                        });
                                      }
                                    }, 
                                    text: "Ubah Email", 
                                    icon: Icons.email),
                                  const SizedBox(height: 10),
                                  SelectionButton(
                                    onPressed: () async {
                                      final newPhoneNum = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ChangePhonePage()),
                                      );
                                      if (newPhoneNum != null) {
                                        setState(() {
                                          phoneNumber = newPhoneNum;
                                        });
                                      }
                                    },
                                    text: 'Ubah No Telp',
                                    icon: Icons.phone,
                                  ),
                                  if (role != 'Admin' && role != 'ADM')...[
                                    const SizedBox(height: 10),
                                    SelectionButton(onPressed: () => {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                                        )
                                      }, 
                                      text: "Ubah Password", 
                                      icon: Icons.lock)
                                  ],
                                  const Divider(
                                    color: Colors.grey,
                                    height: 40,
                                    thickness: 1,
                                    indent: 10,
                                    endIndent: 10,
                                  ),
                                  if (role == 'SEL' || role == 'Seller')...[
                                    SelectionButton(
                                      onPressed:() {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                                        );
                                      }, 
                                      text: "Ulasan Saya", 
                                      icon: Icons.reviews,
                                      color: Colors.black
                                    )
                                  ] else if (role == 'Admin' || role == 'ADM')...[
                                    SelectionButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                                        );
                                      }, 
                                      text: "Verifikasi User", 
                                      icon: Icons.verified_user,
                                      color: Colors.black
                                      )
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoading)...[
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ]
              ]
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}