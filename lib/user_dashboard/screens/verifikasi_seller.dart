import 'package:bekas_berkelas_mobile/user_dashboard/screens/verifikasi_seller_detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bekas_berkelas_mobile/review_rating/models/user.dart'; 
class VerifikasiSellerPage extends StatefulWidget {
  const VerifikasiSellerPage({super.key});

  @override
  _VerifikasiSellerPageState createState() => _VerifikasiSellerPageState();
}

class _VerifikasiSellerPageState extends State<VerifikasiSellerPage> {
  final ScrollController _scrollController = ScrollController();
  final List<SellerProfile> _sellers = [];
  final Map<int, SellerProfile> _sellerMap = {};
  bool _isLoading = false;
  int _currentPage = 1;
  final String baseUrl = 'http://10.0.2.2:8000/dashboard';

  @override
  void initState() {
    super.initState();
    _fetchSellers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent && !_isLoading) {
        _fetchSellers();
      }
    });
  }

  Future<void> _fetchSellers() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    final request = Provider.of<CookieRequest>(context, listen: false);
    final response = await request.get('$baseUrl/verifikasi_penjual_flutter/?page=$_currentPage');

    if (response['status'] == 'success') {
      final data = response['data'] as Map<String, dynamic>;
      List<SellerProfile> newSellers = data.entries.map((entry) {
        final sellerData = entry.value as Map<String, dynamic>;
        final sellerProfile = SellerProfile.fromJson(sellerData);
        _sellerMap[int.parse(entry.key)] = sellerProfile;
        return sellerProfile;
      }).toList();

      setState(() {
        _currentPage++;
        _sellers.addAll(newSellers);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Seller'),
      ),
      body: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: _sellerMap.keys.length + (_isLoading && _currentPage > 1 ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _sellerMap.keys.length) {
                return const Center(child: CircularProgressIndicator(color: Colors.blue));
              }
              final sellerId = _sellerMap.keys.elementAt(index);
              final seller = _sellerMap[sellerId]!;
              return ListTile(
                title: Text(seller.userProfile.name),
                subtitle: Text(seller.userProfile.email),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VerifikasiSellerDetailPage(seller: seller, id: sellerId)),
                    );
                    if (result == true) {
                      setState(() {
                        _sellers.remove(seller);
                        _sellerMap.remove(sellerId);
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    shadowColor: Colors.black,
                    overlayColor: Colors.black,
                  ),
                  child: const Text('Verifikasi'),
                ),
              );
            },
          ),
          if (_isLoading && _currentPage == 1)
            const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            ),
        ],
      ),
    );
  }
}