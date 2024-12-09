import 'package:bekas_berkelas_mobile/main.dart';
import 'package:bekas_berkelas_mobile/user_dashboard/screen/dashboard.dart';
import 'package:flutter/material.dart';


class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
              children: [
                Text(
                  'BekasBerkelas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Padding(padding: EdgeInsets.all(8)),
                Text(
                  "(Kata-kata disini!)",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.normal
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Halaman Utama'),
            // Bagian redirection ke MyHomePage
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyHomePage(title: 'Home'),
                ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Katalog'),
            // Bagian redirection ke MoodEntryFormPage
            onTap: () {


            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Mobil Saya'),
            onTap: () {


            },
          ),
          ListTile(
            leading: const Icon(Icons.forum),
            title: const Text('Forum'),
            onTap: () {


            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Akun Saya'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardPage(),
                ));

            },
          ),
        ],
      ),
    );
  }
}