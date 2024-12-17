import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../models/reply.dart';
import 'show_forum.dart';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';
import 'package:bekas_berkelas_mobile/authentication/services/auth.dart';

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
            MaterialPageRoute(
              builder: (context) => const ShowForum(),
            ),
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

          Question question = Question.fromJson({
            'model': 'forum.question',
            'pk': widget.questionId,
            'fields': {
              'user': snapshot.data['question']['user'],
              'car': snapshot.data['question']['car'],
              'title': snapshot.data['question']['title'],
              'content': snapshot.data['question']['content'],
              'category': snapshot.data['question']['category'],
              'created_at': snapshot.data['question']['created_at'],
              'updated_at': snapshot.data['question']['updated_at'],
              'username': snapshot.data['question']['username'],
              'reply_count': snapshot.data['question']['reply_count'],
            }
          });

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
                                          constraints:
                                              const BoxConstraints(),
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
                    ...replies
                        .map((reply) => Card(
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
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        ),
                                        if (request.loggedIn)
                                          FutureBuilder<Map<String, String?>>(
                                            future: AuthService().getUserData(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData &&
                                                  (reply.fields.user
                                                              .toString() ==
                                                          snapshot.data?[
                                                              'user_id'] ||
                                                      question.fields.user
                                                              .toString() ==
                                                          snapshot.data?[
                                                              'user_id'] ||
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
                            ))
                        .toList(),
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
                      )
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
      print('Error fetching question detail: $e');
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
              MaterialPageRoute(
                builder: (context) => const ShowForum(),
              ),
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
