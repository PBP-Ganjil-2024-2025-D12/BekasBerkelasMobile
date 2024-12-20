import 'package:flutter/material.dart';
import '../authentication/services/auth.dart';  // Adjust this import path to where your AuthService is located

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
      ),
      body: FutureBuilder<Map<String, String?>>(
        future: authService.getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final userData = snapshot.data!;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Username: ${userData['username']}'),
                    const SizedBox(height: 10),
                    Text('User Role: ${userData['role']}'),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('Failed to load user data.'));
            }
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
