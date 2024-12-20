import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import 'package:bekas_berkelas_mobile/katalog_produk/Car_entry.dart';
import 'forum_detail.dart';
import 'package:bekas_berkelas_mobile/widgets/left_drawer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ShowForum extends StatefulWidget {
  const ShowForum({Key? key}) : super(key: key);

  @override
  _ShowForumState createState() => _ShowForumState();
}

class _ShowForumState extends State<ShowForum>
    with SingleTickerProviderStateMixin {
  String _sortBy = 'terbaru';
  String _category = '';
  String _searchQuery = '';
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String getCategoryFullName(String code) {
    switch (code) {
      case 'UM':
        return 'Diskusi Umum';
      case 'JB':
        return 'Forum Jual Beli';
      case 'TT':
        return 'Diskusi Tips & Trik';
      case 'SA':
        return 'Ruang Santai';
      default:
        return code;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFEEF1FF),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Forum Diskusi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C8BF5),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF4C8BF5)),
      ),
      drawer: const LeftDrawer(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE4E7F5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari Diskusi...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _currentPage = 1;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _category,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: '', child: Text('Semua Kategori')),
                              DropdownMenuItem(
                                  value: 'UM', child: Text('Diskusi Umum')),
                              DropdownMenuItem(
                                  value: 'JB', child: Text('Forum Jual Beli')),
                              DropdownMenuItem(
                                  value: 'TT',
                                  child: Text('Diskusi Tips & Trik')),
                              DropdownMenuItem(
                                  value: 'SA', child: Text('Ruang Santai')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _category = value ?? '';
                                _currentPage = 1;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _sortBy,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF4C8BF5)),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data['questions'].isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.forum_outlined,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada diskusi',
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

                  var questions = snapshot.data['questions']
                      .map((item) => Question(
                          model: item['model'],
                          pk: item['pk'],
                          fields: QuestionFields.fromJson(item['fields'])))
                      .toList();

                  return AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        var question = questions[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ForumDetail(
                                            questionId: question.pk),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          question.fields.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4C8BF5),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          question.fields.content,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            height: 1.3,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time,
                                                size: 16,
                                                color: Colors.grey[500]),
                                            const SizedBox(width: 4),
                                            Text(
                                              question.fields.createdAt
                                                  .toString(),
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                getCategoryFullName(
                                                    question.fields.category),
                                                style: const TextStyle(
                                                  color: Color(0xFF4C8BF5),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(Icons.comment_outlined,
                                                size: 16,
                                                color: Colors.grey[500]),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${question.fields.replyCount ?? 0}',
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fadeAnimation,
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF4C8BF5),
          icon: const Icon(Icons.add),
          label: const Text('Buat Diskusi'),
          onPressed: () {
            _showCreateQuestionDialog(context, request);
          },
        ),
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
