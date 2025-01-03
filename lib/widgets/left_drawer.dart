import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bekas_berkelas_mobile/authentication/screens/homepage.dart';
import 'package:bekas_berkelas_mobile/katalog_produk/list_Carentry.dart';
import 'package:bekas_berkelas_mobile/wishlist/screens/list_wishlist.dart';
import 'package:bekas_berkelas_mobile/forum/screens/show_forum.dart';
import 'package:bekas_berkelas_mobile/user_dashboard/screens/dashboard.dart';
import 'package:bekas_berkelas_mobile/authentication/screens/login_screen.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});
  static const String baseUrl = 'https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/dashboard';

    Future<Map<String, dynamic>> _fetchData(CookieRequest request) async {
    try {
      final response = await request.post('$baseUrl/get_user_flutter/', {});
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
    final username = request.jsonData['username'] ?? 'User';

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchData(request),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading data'));
        } else {
          final imageUrl = snapshot.data!['profile_picture'] ?? '';

    return Drawer(
      child: Container(
        color: const Color(0xFF4C8BF5),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: CircleAvatar(
                            backgroundColor: Colors.white24,
                            radius: 30,
                            backgroundImage: imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading:
                        const Icon(Icons.home_outlined, color: Colors.white),
                    title: const Text('Halaman Utama',
                        style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.search, color: Colors.white),
                    title: const Text('Katalog',
                        style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CarEntryPage()),
                    ),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.favorite_outline, color: Colors.white),
                    title: const Text('Wishlist Saya',
                        style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WishlistPage()),
                    ),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.forum_outlined, color: Colors.white),
                    title: const Text('Forum',
                        style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ShowForum()),
                    ),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.person_outline, color: Colors.white),
                    title: const Text('Akun Saya',
                        style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardPage()),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () async {
                try {
                  final response = await request.post(
                    'https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/auth/logout/',
                    {},
                  );

                  if (response['status'] == 'success') {
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  }
                } catch (e) {
                  print('Logout error: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error during logout'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
            ),
            ],
          ),
        ),
      );
    }
  }
);
}
}


PreferredSizeWidget appBar(BuildContext context, String title, bool hasTitle) {
  return AppBar(
    title: hasTitle
        ? Row(
            children: [
              Image.asset(
                'assets/logo-only.png',
                height: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )
        : const SizedBox.shrink(),
    backgroundColor: Colors.white,
    leading: title == 'Detail Diskusi' 
        ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          )
        : null,
    automaticallyImplyLeading: title != 'Detail Diskusi', 
  );
}
