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
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

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
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Detail Diskusi',
          style: TextStyle(
            color: Color(0xFF4C8BF5),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF4C8BF5)),
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

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                                      question.fields.title,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4C8BF5),
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
                              Row(
                                children: [
                                  Icon(Icons.person_outline,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    question.fields.username,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.access_time,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    formatDateTime(question.fields.createdAt),
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                question.fields.content,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              Text(
                                question.fields.content,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              if (question.fields.car != null) ...[
                                const SizedBox(height: 16),
                                FutureBuilder(
                                  future: fetchCarDetails(
                                      request, question.fields.car!),
                                  builder:
                                      (context, AsyncSnapshot carSnapshot) {
                                    if (carSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF4C8BF5)),
                                        ),
                                      );
                                    }

                                    if (!carSnapshot.hasData ||
                                        carSnapshot.hasError) {
                                      return const SizedBox.shrink();
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
                                              builder: (context) =>
                                                  CarDetailPage(
                                                      carEntry: carData),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: Colors.grey[200]!),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.directions_car,
                                                      size: 16,
                                                      color: Colors.grey[600]),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Mobil Terkait:',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                          color:
                                                              Colors.grey[200],
                                                          child: Icon(
                                                              Icons
                                                                  .broken_image,
                                                              color: Colors
                                                                  .grey[400]),
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
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xFF4C8BF5),
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
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                            Icon(
                                                              Icons
                                                                  .arrow_forward_ios,
                                                              size: 12,
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
                                    } catch (e) {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4C8BF5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.forum_outlined,
                              color: Color(0xFF4C8BF5),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Balasan (${replies.length})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4C8BF5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimationLimiter(
                        child: Column(
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 375),
                            childAnimationBuilder: (widget) => SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: widget,
                              ),
                            ),
                            children: replies
                                .map((reply) => Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      elevation: 1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor:
                                                      Colors.grey[100],
                                                  child: Text(
                                                    reply.fields.username[0]
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                      color: Colors.grey[800],
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
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
                                                        reply.fields.username,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        formatDateTime(reply
                                                            .fields.createdAt),
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (request.loggedIn)
                                                  FutureBuilder<
                                                      Map<String, String?>>(
                                                    future: AuthService()
                                                        .getUserData(),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData &&
                                                          (reply.fields.user
                                                                      .toString() ==
                                                                  snapshot.data?[
                                                                      'user_id'] ||
                                                              question.fields
                                                                      .user
                                                                      .toString() ==
                                                                  snapshot.data?[
                                                                      'user_id'] ||
                                                              snapshot.data?[
                                                                      'role'] ==
                                                                  'ADM')) {
                                                        return IconButton(
                                                          icon: const Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                              size: 20),
                                                          onPressed: () =>
                                                              _deleteReply(
                                                                  request,
                                                                  reply.pk),
                                                        );
                                                      }
                                                      return const SizedBox
                                                          .shrink();
                                                    },
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              reply.fields.content,
                                              style:
                                                  const TextStyle(height: 1.4),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (request.loggedIn)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _replyController,
                            decoration: InputDecoration(
                              hintText: 'Tambahkan balasan...',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFF4C8BF5)),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C8BF5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _submitReply(request),
                          child: const Row(
                            children: [
                              Icon(Icons.send, size: 18),
                              SizedBox(width: 8),
                              Text('Kirim'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
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
