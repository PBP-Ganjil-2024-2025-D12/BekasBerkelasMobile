import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../models/reply.dart';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';
import 'show_forum.dart';
import '../widgets/detail_card.dart';

class ForumDetail extends StatefulWidget {
  final String questionId;

  const ForumDetail({Key? key, required this.questionId}) : super(key: key);

  @override
  _ForumDetailState createState() => _ForumDetailState();
}

class _ForumDetailState extends State<ForumDetail>
    with SingleTickerProviderStateMixin {
  final _replyController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
      appBar: appBar(context, 'Detail Diskusi', true),
      drawer: const LeftDrawer(),
      body: FutureBuilder(
        future: fetchQuestionDetail(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C8BF5)),
              ),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Diskusi tidak ditemukan',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          Question question = Question(
            model: 'forum.question',
            pk: widget.questionId,
            fields: QuestionFields.fromJson(snapshot.data['question']),
          );

          List<Reply> replies = (snapshot.data['replies'] as List? ?? [])
              .map((replyData) => Reply.fromJson(replyData))
              .toList();

          return ForumDetailCard(
            fadeAnimation: _fadeAnimation,
            question: question,
            replies: replies,
            request: request,
            replyController: _replyController,
            onDeleteQuestion: () => _deleteQuestion(request),
            onDeleteReply: (replyId) => _deleteReply(request, replyId),
            onSubmitReply: () => _submitReply(request),
            formatDateTime: formatDateTime,
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> fetchQuestionDetail(CookieRequest request) async {
    try {
      final response = await request.get('https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/forum/${widget.questionId}/');
      return response;
    } catch (e) {
      debugPrint('Error fetching question detail: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchCarDetails(CookieRequest request, String carId) async {
    try {
      final response = await request.get('https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/katalog/detail/json/$carId/');
      if (response is Map<String, dynamic>) {
        return response;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      debugPrint('Error in fetchCarDetails: $e');
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
          'https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/forum/${widget.questionId}/delete_question/',
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
          'https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/forum/${widget.questionId}/delete_reply/$replyId/',
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
        'https://steven-setiawan-bekasberkelasmobile.pbp.cs.ui.ac.id/forum/${widget.questionId}/create_reply/',
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