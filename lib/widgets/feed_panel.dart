// lib/widgets/feed_panel.dart
// PageView vertical — padEnds: false buang ruang kosong atas/bawah
// viewportFraction < 1.0 tunjuk kad tepi (efek roda)

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'feed_card.dart';

class FeedPanel extends StatefulWidget {
  const FeedPanel({Key? key}) : super(key: key);

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel> {
  late final PageController _controller;
  int _currentIndex = 0;

  // viewportFraction: 0.18 = setiap kad ambil 18% tinggi skrin
  // → ~5-6 kad nampak serentak, tiada ruang kosong
  static const double _viewportFraction = 0.18;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: _viewportFraction);
    _controller.addListener(() {
      final int newIndex = _controller.page?.round() ?? 0;
      if (newIndex != _currentIndex) {
        setState(() => _currentIndex = newIndex);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<PostModel> _posts = const [
    PostModel(id: '101', type: 'video',   title: 'Kisah Hijrah Rasulullah ﷺ',         content: 'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda dari ancaman kaum Quraisy.',              author: 'Ustaz Don',        authorAge: '40', likes: 1240, time: '2j',  assetPath: 'assets/images/dummy_post1.jpg'),
    PostModel(id: '102', type: 'quote',   title: 'Kata Hikmah',                        content: 'Jangan bersedih, sesungguhnya Allah bersama kita. (At-Taubah: 40)',                                          author: "Imam Syafi'i",     authorAge: '',   likes: 850,  time: '5j'),
    PostModel(id: '103', type: 'article', title: 'Kelebihan Selawat',                  content: 'Barangsiapa berselawat ke atasku sekali, Allah balas sepuluh kali ganda rahmat kepadanya.',                  author: 'Habib Ali',        authorAge: '52', likes: 2100, time: '1h',  assetPath: 'assets/images/dummy_post2.jpg'),
    PostModel(id: '104', type: 'event',   title: 'Majlis Ilmu Perdana',                content: 'Jom sertai kami di Masjid Negeri untuk kupasan kitab Sirah Nabawiyah bersama ulama.',                        author: 'Admin iHijrah',    authorAge: '',   likes: 500,  time: '10j'),
    PostModel(id: '105', type: 'quote',   title: 'Pesan Imam Malik',                   content: 'Ilmu itu bukan pada apa yang dihafal, tetapi pada apa yang memberi manfaat kepada hati.',                    author: 'Imam Malik',       authorAge: '',   likes: 3200, time: '12j'),
    PostModel(id: '106', type: 'video',   title: 'Tajwid Asas: Al-Fatihah',            content: 'Mari perbaiki bacaan Al-Fatihah kita. Setiap huruf ada makhrajnya yang tersendiri.',                        author: 'Ustaz Azhar',      authorAge: '60', likes: 890,  time: '1h'),
    PostModel(id: '107', type: 'article', title: 'Rahsia Dhuha & Pintu Rezeki',        content: 'Konsistensi solat Dhuha membuka pintu rezeki yang tidak disangka-sangka oleh manusia biasa.',               author: 'Ustaz Wadi',       authorAge: '45', likes: 4500, time: '30m', assetPath: 'assets/images/dummy_post1.jpg'),
    PostModel(id: '108', type: 'quote',   title: 'Nasihat Imam Ghazali',               content: 'Ilmu tanpa amal itu gila, amal tanpa ilmu itu sia-sia. Carilah keduanya bersama.',                           author: 'Imam Ghazali',     authorAge: '',   likes: 5100, time: '2h'),
    PostModel(id: '109', type: 'article', title: 'Keutamaan Surah Al-Mulk',            content: 'Sesiapa yang membaca Al-Mulk setiap malam, ia akan dilindungi dari azab kubur.',                             author: 'Ustazah Noor',     authorAge: '38', likes: 1870, time: '3h',  assetPath: 'assets/images/dummy_post2.jpg'),
    PostModel(id: '110', type: 'event',   title: 'Kem Tahfiz Ramadan 1446H',           content: 'Daftar sekarang! Kem intensif hafazan Al-Quran 10 hari untuk semua peringkat umur.',                         author: 'Markaz Quran KL',  authorAge: '',   likes: 720,  time: '4h'),
    PostModel(id: '111', type: 'video',   title: 'Doa Pagi yang Mujarab',              content: 'Amalkan 7 doa ini setiap pagi. Nabi ﷺ sendiri mengajarkan kepada para sahabat baginda.',                     author: 'Dr Rozaimi',       authorAge: '47', likes: 3300, time: '5h',  assetPath: 'assets/images/dummy_post1.jpg'),
    PostModel(id: '112', type: 'quote',   title: 'Kata Ibn Qayyim',                    content: 'Hati yang kosong dari zikir adalah hati yang mati walaupun pemiliknya masih bernyawa.',                       author: 'Ibn Qayyim',       authorAge: '',   likes: 6200, time: '6h'),
    PostModel(id: '113', type: 'article', title: 'Adab Berdoa dalam Islam',            content: 'Berdoa bukan sekadar meminta. Ada adab, waktu mustajab dan cara yang diajar oleh Rasulullah ﷺ.',             author: 'Ust Hasrizal',     authorAge: '43', likes: 980,  time: '7h',  assetPath: 'assets/images/dummy_post2.jpg'),
    PostModel(id: '114', type: 'event',   title: 'Forum Muallaf: Jalan Menuju Islam',  content: 'Dengar kisah perjalanan rohani mereka yang menemui cahaya Islam dari seluruh dunia.',                         author: 'iHijrah Official', authorAge: '',   likes: 430,  time: '8h'),
    PostModel(id: '115', type: 'video',   title: 'Tafsir Surah Al-Kahfi Ayat 1-10',   content: 'Perlindungan dari fitnah Dajjal bermula dengan memahami 10 ayat pertama surah ini sepenuhnya.',              author: 'Ust Fathul Bari',  authorAge: '50', likes: 7800, time: '9h',  assetPath: 'assets/images/dummy_post1.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double cardHeight = screenHeight * _viewportFraction;

    return SizedBox.expand(
      child: PageView.builder(
        controller: _controller,
        scrollDirection: Axis.vertical,
        // ✅ INI yang buang ruang kosong atas & bawah
        padEnds: false,
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double page = _currentIndex.toDouble();
              if (_controller.hasClients && _controller.page != null) {
                page = _controller.page!;
              }
              final double diff = page - index;
              final double absDiff = diff.abs();

              // Cylinder rotation — makin jauh dari center, makin bengkok ke belakang
              // 0.8 radian (~46°) bila 1 kad jauh = kesan roda yang jelas
              final double angle = diff * 0.75;

              // Scale: center=1.0, tepi mengecil
              final double scale = (1.0 - absDiff * 0.06).clamp(0.82, 1.0);

              // Opacity: center terang, tepi sedikit malap
              final double opacity = (1.0 - absDiff * 0.25).clamp(0.4, 1.0);

              return Opacity(
                opacity: opacity,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.003)   // perspective depth
                    ..rotateX(angle),          // putar pada paksi X — kesan silinder
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                ),
              );
            },
            child: SizedBox(
              height: cardHeight,
              child: FeedCard(
                post: _posts[index],
                isCenter: index == _currentIndex,
                onTap: () {
                  _controller.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
