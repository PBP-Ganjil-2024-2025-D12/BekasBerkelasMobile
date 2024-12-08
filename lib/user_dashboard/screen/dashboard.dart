import 'package:flutter/material.dart';
import 'change_name.dart';
import 'change_email.dart';
import 'change_NoTelp.dart';
import 'change_password.dart';

class DashboardPage extends StatelessWidget {
  final String name = "Tes";
  final String email = "Tes@gmail.com";
  final String phoneNumber = "+12345";
  final String imageUrl = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Column(
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
                      width: 300, // Atur lebar sesuai kebutuhan
                      child: Row(
                        children: [
                          const Text(
                            'Name',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(width: 10), // Memberikan jarak seperti tab
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
                      width: 300, // Atur lebar sesuai kebutuhan
                      child: Row(
                        children: [
                          const Text(
                            'Email',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(width: 10), // Memberikan jarak seperti tab
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
                      width: 300, // Atur lebar sesuai kebutuhan
                      child: Row(
                        children: [
                          const Text(
                            'Phone Number',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(width: 10), // Memberikan jarak seperti tab
                          Text(
                            ': $phoneNumber',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChangeNamePage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50), // Lebar penuh dan tinggi 50
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Sudut membulat sedikit
                            ),
                          ),
                          icon: Icon(Icons.person),
                          label: Text('Ubah Nama'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChangeEmailPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50), // Lebar penuh dan tinggi 50
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Sudut membulat sedikit
                            ),
                          ),
                          icon: Icon(Icons.email),
                          label: Text('Ubah Email'),
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
                            minimumSize: Size(double.infinity, 50), // Lebar penuh dan tinggi 50
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Sudut membulat sedikit
                            ),
                          ),
                          icon: Icon(Icons.phone),
                          label: Text('Ubah No Telp'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50), // Lebar penuh dan tinggi 50
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Sudut membulat sedikit
                            ),
                          ),
                          icon: Icon(Icons.lock),
                          label: Text('Ubah Password'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // Navigasi ke halaman Dashboard
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(double.infinity, double.infinity), // Mengisi seluruh lebar dan tinggi
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.center,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Sudut membulat sedikit
                      ),
                    ),
                    child: Text('Dashboard'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // Navigasi ke halaman Home
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(double.infinity, double.infinity), // Mengisi seluruh lebar dan tinggi
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.center,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Sudut membulat sedikit
                      ),
                    ),
                    child: Text('Home'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}