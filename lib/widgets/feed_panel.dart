// lib/widgets/feed_panel.dart
// Guna ScrollController + Transform.rotate manual
// → roda penuh skrin, jarak rapat, tiada ruang kosong

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'feed_card.dart';

class FeedPanel extends StatefulWidget {
  const FeedPanel({Key? key}) : super(key: key);

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel> {
  final ScrollController _scrollController = ScrollController();

  // Tinggi setiap kad — tukar ni untuk ubah bilangan kad visible
  static const double _cardHeight = 100.0;
  // Jarak antara kad (0 = rapat, negatif = bertindih)
  static const double _cardGap = 0.0;
  static const double _itemStep = _cardHeight + _cardGap;

  // Seberapa kuat cylinder effect — lebih kecil = lebih melengkung
  static const double _cylinderRadius = 380.0;

  int _centerIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final double offset = _scrollController.offset;
    final int newCenter = (offset / _itemStep).round();
    if (newCenter != _centerIndex) {
      setState(() => _centerIndex = newCenter.clamp(0, _posts.length - 1));
    }
  }

  // Snap ke kad terdekat bila lepas scroll
  void _snapToNearest() {
    final double offset = _scrollController.offset;
    final int nearest = (offset / _itemStep).round();
    final double snapOffset = nearest.clamp(0, _posts.length - 1) * _itemStep;
    _scrollController.animateTo(
      snapOffset,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  final List<PostModel> _posts = const [
    PostModel(id: '101', type: 'video',   title: 'Kisah Hijrah Rasulullah ﷺ',         content: 'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda dari ancaman kaum Quraisy.',              author: 'Ustaz Don',        authorAge: '40', likes: 1240, time: '2j',  assetPath: 'assets/images/dummy_post1.jpg'),
    PostModel(id: '102', type: 'quote',   title: 'Kata Hikmah',                        content: 'Jangan bersedih, sesungguhnya Allah bersama kita. (At-Taubah: 40)',                                          author: "Imam Syafi'i",     authorAge: '',   likes: 850,  time: '5j'),
    PostModel(id: '103', type: 'article', title: 'Kelebihan Selawat',                  content: 'Barangsiapa berselawat ke atasku sekali, Allah balas sepuluh kali ganda rahmat kepadanya.',                  author: 'Habib Ali',        authorAge: '52', likes: 2100, time: '1h',  assetPath: 'assets/images/dummy_post2.jpg'),
    PostModel(id: '104', type: 'event',   title: 'Majlis Ilmu Perdana',                content: 'Jom sertai kami di Masjid Negeri untuk kupasan kitab Sirah Nabawiyah bersama ulama terkemuka.',              author: 'Admin iHijrah',    authorAge: '',   likes: 500,  time: '10j'),
    PostModel(id: '105', type: 'quote',   title: 'Pesan Imam Malik',                   content: 'Ilmu itu bukan pada apa yang dihafal, tetapi pada apa yang memberi manfaat kepada hati.',                    author: 'Imam Malik',       authorAge: '',   likes: 3200, time: '12j'),
    PostModel(id: '106', type: 'video',   title: 'Tajwid Asas: Al-Fatihah',            content: 'Mari perbaiki bacaan Al-Fatihah kita. Setiap huruf ada makhrajnya yang tersendiri.',                        author: 'Ustaz Azhar',      authorAge: '60', likes: 890,  time: '1h'),
    PostModel(id: '107', type: 'article', title: 'Rahsia Dhuha & Pintu Rezeki',        content: 'Konsistensi solat Dhuha membuka pintu rezeki yang tidak disangka-sangka oleh manusia biasa.',               author: 'Ustaz Wadi',       authorAge: '45', likes: 4500, time: '30m', assetPath: 'assets/images/dummy_post1.jpg'),
    PostModel(id: '108', type: 'quote',   title: 'Nasihat Imam Ghazali',               content: 'Ilmu tanpa amal itu gila, amal tanpa ilmu itu sia-sia. Carilah keduanya bersama.',                           author: 'Imam Ghazali',     authorAge: '',   likes: 5100, time: '2h'),
    PostModel(id: '109', type: 'article', title: 'Keutamaan Surah Al-Mulk',            content: 'Sesiapa yang membaca Al-Mulk setiap malam, ia akan dilindungi dari azab kubur oleh Allah.',                 author: 'Ustazah Noor',     authorAge: '38', likes: 1870, time: '3h',  assetPath: 'assets/images/dummy_post2.jpg'),
    PostModel(id: '110', type: 'event',   title: 'Kem Tahfiz Ramadan 1446H',           content: 'Daftar sekarang! Kem intensif hafazan Al-Quran 10 hari untuk semua peringkat umur.',                         author: 'Markaz Quran KL',  authorAge: '',   likes: 720,  time: '4h'),
    PostModel(id: '111', type: 'video',   title: 'Doa Pagi yang Mujarab',              content: 'Amalkan 7 doa ini setiap pagi. Nabi ﷺ sendiri mengajarkan kepada para sahabat baginda.',                     author: 'Dr Rozaimi',       authorAge: '47', likes: 3300, time: '5h',  assetPath: 'assets/images/dummy_post1.jpg'),
    PostModel(id: '112', type: 'quote',   title: 'Kata Ibn Qayyim',                    content: 'Hati yang kosong dari zikir adalah hati yang mati walaupun pemiliknya masih bernyawa.',                       author: 'Ibn Qayyim',       authorAge: '',   likes: 6200, time: '6h'),
    PostModel(id: '113', type: 'article', title: 'Adab Berdoa dalam Islam',            content: 'Berdoa bukan sekadar meminta. Ada adab, waktu mustajab dan cara yang diajar oleh Rasulullah ﷺ.',             author: 'Ust Hasrizal',     authorAge: '43', likes: 980,  time: '7h',  assetPath: 'assets/images/dummy_post2.jpg'),
    PostModel(id: '114', type: 'event',   title: 'Forum Muallaf: Jalan Menuju Islam',  content: 'Dengar kisah perjalanan rohani mereka yang menemui cahaya Islam dari seluruh dunia.',                         author: 'iHijrah Official', authorAge: '',   likes: 430,  time: '8h'),
    PostModel(id: '115', type: 'video',   title: 'Tafsir Surah Al-Kahfi Ayat 1-10',   content: 'Perlindungan dari fitnah Dajjal bermula dengan memahami 10 ayat pertama surah ini sepenuhnya.',              author: 'Ust Fathul Bari',  authorAge: '50', likes: 7800, time: '9h',  assetPath: 'assets/images/dummy_post1.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double viewportHeight = constraints.maxHeight;
        // Offset untuk push padding atas/bawah supaya kad pertama/terakhir boleh snap ke center
        final double centerOffset = (viewportHeight / 2) - (_cardHeight / 2);

        return GestureDetector(
          onVerticalDragEnd: (_) => _snapToNearest(),
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (_) {
              _snapToNearest();
              return false;
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Padding atas: supaya kad pertama boleh naik ke tengah skrin
                  SizedBox(height: centerOffset),

                  // Senarai kad
                  ...List.generate(_posts.length, (index) {
                    return AnimatedBuilder(
                      animation: _scrollController,
                      builder: (context, child) {
                        // Kiraan offset — berapa jauh kad ini dari center viewport
                        double scrollOffset = 0;
                        if (_scrollController.hasClients) {
                          scrollOffset = _scrollController.offset;
                        }

                        // Posisi kad ini relatif kepada center viewport
                        final double itemCenter = index * _itemStep + (_cardHeight / 2);
                        final double viewportCenter = scrollOffset + (viewportHeight / 2);
                        final double distFromCenter = itemCenter - viewportCenter;

                        // Cylinder angle — arcsin untuk kesan roda sebenar
                        // clamp supaya tak exceed -90° hingga 90°
                        final double ratio = (distFromCenter / _cylinderRadius).clamp(-1.0, 1.0);
                        final double angle = math.asin(ratio); // dalam radian

                        // Scale: center=1.0, makin jauh makin kecil
                        final double absDist = distFromCenter.abs();
                        final double scale = (1.0 - (absDist / (viewportHeight * 1.2))).clamp(0.80, 1.0);

                        // isCenter untuk FeedCard
                        final bool isCenter = index == _centerIndex;

                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001) // perspective
                            ..rotateX(angle),       // rotate mengikut posisi pada silinder
                          child: SizedBox(
                            height: _cardHeight,
                            child: Transform.scale(
                              scale: scale,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: FeedCard(
                        post: _posts[index],
                        isCenter: index == _centerIndex,
                        onTap: () {
                          // Scroll ke kad yang ditap
                          final double targetOffset = index * _itemStep;
                          _scrollController.animateTo(
                            targetOffset,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                          );
                        },
                      ),
                    );
                  }),

                  // Padding bawah: supaya kad terakhir boleh snap ke tengah
                  SizedBox(height: centerOffset),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
