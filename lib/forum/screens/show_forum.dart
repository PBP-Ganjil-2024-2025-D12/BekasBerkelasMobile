import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/question.dart';
import 'forum_detail.dart';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';

class ShowForum extends StatefulWidget {
  const ShowForum({Key? key}) : super(key: key);

  @override
  _ShowForumState createState() => _ShowForumState();
}

class _ShowForumState extends State<ShowForum> {
  String _sortBy = 'terbaru';
  String _category = '';
  String _searchQuery = '';
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFEEF1FF),
      appBar: AppBar(
        title: const Text('Forum'),
        backgroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari Diskusi...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _currentPage = 1;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _category,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: '', child: Text('Semua Kategori')),
                          DropdownMenuItem(value: 'UM', child: Text('Umum')),
                          DropdownMenuItem(
                              value: 'JB', child: Text('Jual Beli')),
                          DropdownMenuItem(
                              value: 'TT', child: Text('Tips & Trik')),
                          DropdownMenuItem(value: 'SA', child: Text('Santai')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _category = value ?? '';
                            _currentPage = 1;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sortBy,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'terbaru', child: Text('Terbaru')),
                          DropdownMenuItem(
                              value: 'populer', child: Text('Populer')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value ?? 'terbaru';
                            _currentPage = 1;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchQuestions(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data['questions'].isEmpty) {
                  return const Center(child: Text('Tidak ada diskusi.'));
                }

                var questions = snapshot.data['questions']
                    .map((item) => Question(
                        model: item['model'],
                        pk: item['pk'],
                        fields: Fields.fromJson(item['fields'])))
                    .toList();

                return ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    var question = questions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          question.fields.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(question.fields.content),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(question.fields.createdAt.toString()),
                                const Spacer(),
                                Text('${question.fields.category} • '),
                                Text(
                                    '${question.fields.replyCount ?? 0} balasan'),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ForumDetail(questionId: question.pk),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4C8BF5),
        child: const Icon(Icons.add),
        onPressed: () {
          _showCreateQuestionDialog(context, request);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> fetchQuestions(CookieRequest request) async {
    final response = await request.get(
        'http://127.0.0.1:8000/forum/get_questions_json/?page=$_currentPage&sort=$_sortBy&category=$_category&search=$_searchQuery');
    return response;
  }

  void _showCreateQuestionDialog(BuildContext context, CookieRequest request) {
    String title = '';
    String content = '';
    String category = 'UM';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Buat Diskusi Baru'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Judul'),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Judul tidak boleh kosong'
                      : null,
                  onSaved: (value) => title = value ?? '',
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Konten'),
                  maxLines: 3,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Konten tidak boleh kosong'
                      : null,
                  onSaved: (value) => content = value ?? '',
                ),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: const [
                    DropdownMenuItem(value: 'UM', child: Text('Umum')),
                    DropdownMenuItem(value: 'JB', child: Text('Jual Beli')),
                    DropdownMenuItem(value: 'TT', child: Text('Tips & Trik')),
                    DropdownMenuItem(value: 'SA', child: Text('Santai')),
                  ],
                  onChanged: (value) => category = value ?? 'UM',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Simpan'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  try {
                    final response = await request.post(
                      'http://127.0.0.1:8000/forum/create_question/',
                      {
                        'title': title,
                        'content': content,
                        'category': category,
                      },
                    );

                    if (response['status'] == 'success') {
                      Navigator.pop(context);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Diskusi berhasil dibuat')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                response['message'] ?? 'Terjadi kesalahan')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Terjadi kesalahan saat membuat diskusi')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
