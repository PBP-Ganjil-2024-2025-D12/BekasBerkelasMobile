import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import 'package:bekas_berkelas_mobile/katalog_produk/Car_entry.dart';
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
                        fields: QuestionFields.fromJson(item['fields'])))
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
                          Navigator.pushReplacement(
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

  Future<List<CarEntry>> fetchCars(CookieRequest request) async {
    try {
      final response =
          await request.get('http://127.0.0.1:8000/katalog/carsjson/');
      if (response is List) {
        return response.map((car) => CarEntry.fromJson(car)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching cars: $e');
      return [];
    }
  }

  void _showCreateQuestionDialog(BuildContext context, CookieRequest request) {
    String title = '';
    String content = '';
    String category = 'UM';
    String? selectedCarId;
    String carSearchQuery = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Buat Diskusi Baru',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Judul',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            onChanged: (value) => title = value,
                            decoration: InputDecoration(
                              hintText: 'Masukkan judul',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kategori',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: category,
                                isExpanded: true,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'UM', child: Text('Umum')),
                                  DropdownMenuItem(
                                      value: 'JB', child: Text('Jual Beli')),
                                  DropdownMenuItem(
                                      value: 'TT', child: Text('Tips & Trik')),
                                  DropdownMenuItem(
                                      value: 'SA', child: Text('Santai')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    category = value ?? 'UM';
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder(
                        future: fetchCars(request),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          List<CarEntry> cars = snapshot.data ?? [];

                          CarEntry? selectedCar;
                          if (selectedCarId != null) {
                            selectedCar = cars.cast<CarEntry?>().firstWhere(
                                  (car) => car?.pk == selectedCarId,
                                  orElse: () => null,
                                );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pilih Mobil',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                readOnly: true,
                                controller: TextEditingController(
                                  text: selectedCar != null
                                      ? '${selectedCar.fields.brand} ${selectedCar.fields.carName}'
                                      : '',
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Cari mobil...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey[600],
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => StatefulBuilder(
                                      builder: (context, setModalState) {
                                        List<CarEntry> filteredCars =
                                            cars.where((car) {
                                          String searchStr =
                                              '${car.fields.brand} ${car.fields.carName}'
                                                  .toLowerCase();
                                          return searchStr.contains(
                                              carSearchQuery.toLowerCase());
                                        }).toList();

                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.8,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            children: [
                                              TextField(
                                                autofocus: true,
                                                decoration: InputDecoration(
                                                  hintText: 'Cari mobil...',
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey[400],
                                                  ),
                                                  prefixIcon: Icon(
                                                    Icons.search,
                                                    color: Colors.grey[600],
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.grey[50],
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color:
                                                            Colors.grey[300]!),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    borderSide: BorderSide(
                                                        color:
                                                            Colors.grey[300]!),
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  setModalState(() {
                                                    carSearchQuery = value;
                                                  });
                                                },
                                              ),
                                              const SizedBox(height: 12),
                                              Expanded(
                                                child: ListView.builder(
                                                  itemCount:
                                                      filteredCars.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final car =
                                                        filteredCars[index];
                                                    return ListTile(
                                                      title: Text(
                                                        '${car.fields.brand} ${car.fields.carName}',
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      subtitle: Text(
                                                        'Tahun ${car.fields.year}',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        setState(() {
                                                          selectedCarId =
                                                              car.pk;
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Konten',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            onChanged: (value) => content = value,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Masukkan konten diskusi...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'Batal',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'Simpan',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                if (title.isEmpty || content.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Judul dan konten harus diisi'),
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  final response = await request.post(
                                    'http://127.0.0.1:8000/forum/create_question/',
                                    {
                                      'title': title,
                                      'content': content,
                                      'category': category,
                                      'car_id': selectedCarId ?? '',
                                    },
                                  );

                                  if (response['status'] == 'success') {
                                    Navigator.pop(context);
                                    setState(() {});
                                    if (context.mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ShowForum(),
                                        ),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Diskusi berhasil dibuat'),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Gagal membuat diskusi'),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
