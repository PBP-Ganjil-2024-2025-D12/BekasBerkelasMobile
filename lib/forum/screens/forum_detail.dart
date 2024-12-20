import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../models/reply.dart';
import 'package:bekas_berkelas_mobile/katalog_produk/Car_entry.dart';
import 'package:bekas_berkelas_mobile/katalog_produk/detail.dart';
import 'show_forum.dart';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';
import 'package:bekas_berkelas_mobile/authentication/services/auth.dart';
import 'package:flutter/foundation.dart';

class ForumDetail extends StatefulWidget {
  final String questionId;

  const ForumDetail({Key? key, required this.questionId}) : super(key: key);

  @override
  _ForumDetailState createState() => _ForumDetailState();
}

class _ForumDetailState extends State<ForumDetail> {
  final _replyController = TextEditingController();

  String formatDateTime(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr).toLocal();
      String year = dateTime.year.toString();
      String month = dateTime.month.toString().padLeft(2, '0');
      String day = dateTime.day.toString().padLeft(2, '0');
      String hour = dateTime.hour.toString().padLeft(2, '0');
      String minute = dateTime.minute.toString().padLeft(2, '0');

      return "$day-$month-$year $hour:$minute";
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFEEF1FF),
      appBar: AppBar(
        title: const Text('Detail Diskusi'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ShowForum()),
          ),
        ),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder(
        future: fetchQuestionDetail(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Diskusi tidak ditemukan.'));
          }

          Question question = Question(
            model: 'forum.question',
            pk: widget.questionId,
            fields: QuestionFields.fromJson(snapshot.data['question']),
          );

          List<Reply> replies = (snapshot.data['replies'] as List? ?? [])
              .map((replyData) => Reply.fromJson(replyData))
              .toList();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    question.fields.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (request.loggedIn)
                                  FutureBuilder<Map<String, String?>>(
                                    future: AuthService().getUserData(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          (question.fields.user.toString() ==
                                                  snapshot.data?['user_id'] ||
                                              snapshot.data?['role'] ==
                                                  'ADM')) {
                                        return IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _deleteQuestion(request),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Oleh ${question.fields.username} • ${formatDateTime(question.fields.createdAt)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            Text(question.fields.content),
                            if (question.fields.car != null) ...[
                              const SizedBox(height: 16),
                              FutureBuilder(
                                future: fetchCarDetails(
                                    request, question.fields.car!),
                                builder: (context, AsyncSnapshot carSnapshot) {

                                  if (carSnapshot.hasError) {
                                    print(
                                        'FutureBuilder error: ${carSnapshot.error}');
                                    print(
                                        'FutureBuilder stack trace: ${carSnapshot.stackTrace}');
                                  }

                                  if (carSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  if (carSnapshot.hasError) {
                                    print('Showing error state');
                                    return Center(
                                        child: Text(
                                            'Error: ${carSnapshot.error}'));
                                  }

                                  try {
                                    final carData = CarEntry.fromJson({
                                      "model": "product_catalog.car",
                                      "pk": question.fields.car!,
                                      "fields": carSnapshot.data
                                    });

                                    return InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CarDetailPage(
                                                carEntry: carData),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Mobil Terkait:',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    carData.fields.imageUrl,
                                                    width: 100,
                                                    height: 75,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        width: 100,
                                                        height: 75,
                                                        color: Colors.grey[300],
                                                        child: const Icon(
                                                            Icons.broken_image),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${carData.fields.brand} ${carData.fields.carName}',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Tahun ${carData.fields.year}',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey[600]),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            'Lihat Detail',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .blue[700],
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .arrow_forward_ios,
                                                            size: 14,
                                                            color: Colors
                                                                .blue[700],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } catch (e, stackTrace) {
                                    print('Error creating CarEntry:');
                                    print('Error: $e');
                                    print('Stack trace: $stackTrace');
                                    return const Center(
                                        child:
                                            Text('Error loading car details'));
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Balasan (${replies.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...replies.map((reply) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Oleh ${reply.fields.username} • ${formatDateTime(reply.fields.createdAt)}',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                    if (request.loggedIn)
                                      FutureBuilder<Map<String, String?>>(
                                        future: AuthService().getUserData(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData &&
                                              (reply.fields.user.toString() ==
                                                      snapshot
                                                          .data?['user_id'] ||
                                                  question.fields.user
                                                          .toString() ==
                                                      snapshot
                                                          .data?['user_id'] ||
                                                  snapshot.data?['role'] ==
                                                      'ADM')) {
                                            return IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () => _deleteReply(
                                                  request, reply.pk),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(reply.fields.content),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              if (request.loggedIn)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          decoration: const InputDecoration(
                            hintText: 'Tambahkan balasan...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4C8BF5),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _submitReply(request),
                        child: const Text('Kirim'),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> fetchQuestionDetail(
      CookieRequest request) async {
    try {
      final response = await request
          .get('http://127.0.0.1:8000/forum/${widget.questionId}/');
      return response;
    } catch (e) {
      debugPrint('Error fetching question detail: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchCarDetails(
      CookieRequest request, String carId) async {

    try {
      final url = 'http://127.0.0.1:8000/katalog/detail/json/$carId/';

      final response = await request.get(url);

      if (response is Map<String, dynamic>) {
        return response;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e, stackTrace) {
      print('Error in fetchCarDetails:');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> _deleteQuestion(CookieRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Hapus Diskusi'),
        content: const Text('Apakah Anda yakin ingin menghapus diskusi ini?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Hapus'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        final response = await request.post(
          'http://127.0.0.1:8000/forum/${widget.questionId}/delete_question/',
          {},
        );

        if (response['status'] == 'success') {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ShowForum()),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Diskusi berhasil dihapus')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus diskusi')),
          );
        }
      }
    }
  }

  Future<void> _deleteReply(CookieRequest request, String replyId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Hapus Balasan'),
        content: const Text('Apakah Anda yakin ingin menghapus balasan ini?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Hapus'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        final response = await request.post(
          'http://127.0.0.1:8000/forum/${widget.questionId}/delete_reply/$replyId/',
          {},
        );

        if (response['status'] == 'success') {
          if (context.mounted) {
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Balasan berhasil dihapus')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus balasan')),
          );
        }
      }
    }
  }

  Future<void> _submitReply(CookieRequest request) async {
    if (_replyController.text.isEmpty) return;

    try {
      final response = await request.post(
        'http://127.0.0.1:8000/forum/${widget.questionId}/create_reply/',
        {'content': _replyController.text},
      );

      if (response['status'] == 'success') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Balasan berhasil ditambahkan')),
          );
          _replyController.clear();
          setState(() {});
        }
      } else {
        throw Exception(response['message'] ?? 'Unknown error');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan balasan: ${e.toString()}')),
        );
      }
    }
  }
}
