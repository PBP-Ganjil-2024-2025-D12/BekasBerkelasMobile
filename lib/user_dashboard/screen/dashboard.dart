import 'dart:convert';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'change_name.dart';
import 'change_email.dart';
import 'change_NoTelp.dart';
import 'change_password.dart';
import 'package:bekas_berkelas_mobile/authentication/services/auth.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final String baseUrl = 'http://127.0.0.1:8000';
  late String name = '';
  late String email = '';
  late String phoneNumber = '';
  late String imageUrl = '';
  late String role = '';
  late String statusAkun = '';

  Future<Map<String, dynamic>> fetchData(CookieRequest request) async {
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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchData(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: $snapshot'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            name = data['nama'];
            email = data['email'];
            phoneNumber = data['no_telp'];
            imageUrl = data['profile_picture'];
            role = data['role'];
            statusAkun = data['status_akun'];

            return Column(
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
                            backgroundImage: NetworkImage(imageUrl),
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
                        if (role == "SEL")...[
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
                              ElevatedButton.icon(
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
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.person),
                                label: const Text('Ubah Nama'),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
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
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.email),
                                label: const Text('Ubah Email'),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ChangePhonePage()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.phone),
                                label: const Text('Ubah No Telp'),
                              ),
                              if (role != 'Admin')...[
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.lock),
                                  label: const Text('Ubah Password'),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}