import 'dart:convert';

import 'package:bekas_berkelas_mobile/review_rating/models/user.dart';
import 'package:bekas_berkelas_mobile/user_dashboard/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class VerifikasiSellerDetailPage extends StatefulWidget {
  final SellerProfile seller;
  final int id;

  const VerifikasiSellerDetailPage({
    super.key,
    required this.seller,
    required this.id,
  });

  @override
  _VerifikasiSellerDetailPageState createState() => _VerifikasiSellerDetailPageState();
}

class _VerifikasiSellerDetailPageState extends State<VerifikasiSellerDetailPage> {
  bool _isLoading = false;
  final String baseUrl = 'http://10.0.2.2:8000/dashboard';

  Future<void> _verifySeller() async {
    setState(() {
      _isLoading = true;
    });
    final data = jsonEncode({
      'idUser': widget.id,
    });

    final request = Provider.of<CookieRequest>(context, listen: false);
    final response = await request.post('$baseUrl/verifikasi_penjual_flutter/', data);

    setState(() {
      _isLoading = false;
    });

    if(!mounted) return;

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil Verifikasi Penjual')),
      );
      Navigator.of(context).pop(true); // Kembali ke halaman sebelumnya dengan hasil true
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal Verifikasi Penjual')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Seller'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue,))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: widget.seller.userProfile.profilePicture.isNotEmpty
                          ? NetworkImage(widget.seller.userProfile.profilePicture)
                          : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
                      backgroundColor: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Id', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text('${widget.id}', style: const TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                                                Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Nama', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(widget.seller.userProfile.name, style: const TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Email', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(widget.seller.userProfile.email, style: const TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('No Telp', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(widget.seller.userProfile.noTelp, style: const TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Total Penjualan', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text('${widget.seller.totalSales}', style: const TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                                                Row(
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Text('Rating', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text('${widget.seller.rating}', style: const TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SubmitButton(onPressed: _verifySeller, text: 'Verifikasi', elevation: 4,),
                  ),
                ],
              ),
            ),
    );
  }
}