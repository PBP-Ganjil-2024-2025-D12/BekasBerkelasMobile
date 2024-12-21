import 'package:bekas_berkelas_mobile/user_dashboard/screens/rating_detail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bekas_berkelas_mobile/user_dashboard/models/rating.dart'; // Ganti dengan path yang sesuai

class RatingListPage extends StatefulWidget {
  const RatingListPage({super.key});

  @override
  _RatingListPageState createState() => _RatingListPageState();
}

class _RatingListPageState extends State<RatingListPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Rating> _ratings = [];
  bool _isLoading = false;
  int _currentPage = 1;
  final String baseUrl = 'http://10.0.2.2:8000/dashboard';

  @override
  void initState() {
    super.initState();
    _fetchRatings();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent && !_isLoading) {
        _fetchRatings();
      }
    });
  }

  Future<void> _fetchRatings() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    if(!mounted) return;

    final request = Provider.of<CookieRequest>(context, listen: false);
    final response = await request.get('$baseUrl/rating_list_flutter/?page=$_currentPage');

    if (response['status'] == 'success') {
      if(response['data']['has_review'] == 0) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final data = response['data']['daftar_review'] as Map<String, dynamic>;

      List<Rating> newRatings = data.entries.map((entry) {
        final ratingData = entry.value as Map<String, dynamic>;
        return Rating.fromJson(ratingData);
      }).toList();

      setState(() {
        _currentPage++;
        _ratings.addAll(newRatings);
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
        title: const Text('Detail Rating'),
      ),
      body: _ratings.isEmpty && !_isLoading
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Icon(Icons.thumb_up, size: 50, color: Colors.grey),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text('Oops, Anda belum memiliki ulasan.', style: TextStyle(fontSize: 15,color: Colors.grey)),
                ),
              ],
            )
          : Stack(
              children: [
                if (_isLoading && _currentPage == 1)...[
                  const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                ]
                else...[
                  ListView.separated(
                    controller: _scrollController,
                    itemCount: _ratings.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _ratings.length  && _currentPage > 1) {
                        return const Center(child: CircularProgressIndicator(color: Colors.blue));
                      }
                      final rating = _ratings[index];
                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RatingDetailPage(rating: rating,),
                          ),
                        ),
                        child: Container(
                          color: Colors.transparent,
                          child: ListTile(
                            title: Text('Reviewer: ${rating.reviewer}', style: const TextStyle(fontSize: 16),),
                            subtitle: Row(children: [ 
                              Text('Rating: ${rating.rating}'),
                              const Icon(Icons.star, color: Colors.amber, size: 16,),
                            ]),
                            trailing: Column(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: rating.reviewerPicture.isNotEmpty
                                      ? NetworkImage(rating.reviewerPicture)
                                      : const AssetImage('assets/default_profile_picture.png') as ImageProvider,
                                  backgroundColor: Colors.blue[900],
                                ),
                              ],
                            ),
                          )
                        )
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(color: Colors.grey,),
                  ),
                ],
              ]
            ),
    );
  }
}