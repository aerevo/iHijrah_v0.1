// lib/widgets/feed_panel.dart
// Apple Vision Pro Style Carousel — Horizontal, Smooth, Zero 3D Bugs.
//
// CARA IA BERFUNGSI:
//   - Guna PageView standard Flutter (sangat stabil).
//   - Kira jarak kad dari tengah (_currentIndex).
//   - Kad tengah: Scale 1.0, Opacity 1.0.
//   - Kad tepi: Scale 0.85, Opacity 0.5 (Nampak depth tanpa 3D matrix).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';
import 'feed_card.dart';
import 'daily_card.dart';

// ── ITEM MODELS ───────────────────────────────────────────────
abstract class _FeedItem {}
class _PostItem   extends _FeedItem { final PostModel post;      _PostItem(this.post); }
class _HadithItem extends _FeedItem { final HadithToday hadith;  _HadithItem(this.hadith); }
class _AmalanItem extends _FeedItem { final AmalanToday amalan;  final int idx; _AmalanItem(this.amalan, this.idx); }
class _SirahItem  extends _FeedItem { final SirahToday sirah;    _SirahItem(this.sirah); }

// ── FEED PANEL ────────────────────────────────────────────────
class FeedPanel extends StatefulWidget {
  final void Function(bool scrollingDown)? onScrollDirection;
  const FeedPanel({Key? key, this.onScrollDirection}) : super(key: key);

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _cached = false;
  List<_FeedItem> _items = [];

  static const List<PostModel> _posts = [
    PostModel(id:'101',type:'video',  title:'Kisah Hijrah Rasulullah ﷺ',       content:'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda.',                         author:'Ustaz Don',      authorAge:'40',likes:1240,time:'2j', assetPath:'assets/images/dummy_post1.jpg'),
    PostModel(id:'102',type:'quote',  title:'Kata Hikmah',                      content:'Jangan bersedih, sesungguhnya Allah bersama kita. (At-Taubah: 40)',                           author:"Imam Syafi'i",   authorAge:'',  likes:850, time:'5j'),
    PostModel(id:'103',type:'article',title:'Kelebihan Selawat',                content:'Barangsiapa berselawat ke atasku sekali, Allah balas sepuluh kali ganda rahmat kepadanya.',  author:'Habib Ali',      authorAge:'52',likes:2100,time:'1h', assetPath:'assets/images/dummy_post2.jpg'),
    PostModel(id:'104',type:'event',  title:'Majlis Ilmu Perdana',              content:'Jom sertai kami di Masjid Negeri untuk kupasan kitab Sirah Nabawiyah.',                       author:'Admin iHijrah',  authorAge:'',  likes:500, time:'10j'),
    PostModel(id:'105',type:'quote',  title:'Pesan Imam Malik',                 content:'Ilmu itu bukan pada apa yang dihafal, tetapi memberi manfaat kepada hati.',                  author:'Imam Malik',     authorAge:'',  likes:3200,time:'12j'),
    PostModel(id:'106',type:'video',  title:'Tajwid Asas: Al-Fatihah',          content:'Mari perbaiki bacaan Al-Fatihah kita. Setiap huruf ada makhrajnya.',                        author:'Ustaz Azhar',    authorAge:'60',likes:890, time:'1h'),
    PostModel(id:'107',type:'article',title:'Rahsia Dhuha & Pintu Rezeki',      content:'Konsistensi solat Dhuha membuka pintu rezeki yang tidak disangka-sangka.',                  author:'Ustaz Wadi',     authorAge:'45',likes:4500,time:'30m',assetPath:'assets/images/dummy_post1.jpg'),
    PostModel(id:'108',type:'quote',  title:'Nasihat Imam Ghazali',             content:'Ilmu tanpa amal itu gila, amal tanpa ilmu itu sia-sia.',                                     author:'Imam Ghazali',   authorAge:'',  likes:5100,time:'2h'),
    PostModel(id:'109',type:'article',title:'Keutamaan Surah Al-Mulk',          content:'Sesiapa yang membaca Al-Mulk setiap malam, dilindungi dari azab kubur.',                    author:'Ustazah Noor',   authorAge:'38',likes:1870,time:'3h', assetPath:'assets/images/dummy_post2.jpg'),
    PostModel(id:'110',type:'event',  title:'Kem Tahfiz Ramadan 1446H',         content:'Daftar sekarang! Kem intensif hafazan 10 hari untuk semua peringkat umur.',                  author:'Markaz Quran KL',authorAge:'',  likes:720, time:'4h'),
    PostModel(id:'111',type:'video',  title:'Doa Pagi yang Mujarab',            content:'Amalkan 7 doa ini setiap pagi. Nabi  mengajarkan kepada para sahabat.',                   author:'Dr Rozaimi',     authorAge:'47',likes:3300,time:'5h', assetPath:'assets/images/dummy_post1.jpg'),
    PostModel(id:'112',type:'quote',  title:'Kata Ibn Qayyim',                  content:'Hati yang kosong dari zikir adalah hati yang mati walaupun bernyawa.',                      author:'Ibn Qayyim',     authorAge:'',  likes:6200,time:'6h'),
    PostModel(id:'115',type:'video',  title:'Tafsir Surah Al-Kahfi Ayat 1-10', content:'Perlindungan dari fitnah Dajjal bermula dengan 10 ayat pertama surah ini.',                  author:'Ust Fathul Bari',authorAge:'50',likes:7800,time:'9h', assetPath:'assets/images/dummy_post1.jpg'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8); // 0.8 = Nampak sikit kad tepi
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<_FeedItem> _buildItems(DailyContentProvider d) {
    final items = <_FeedItem>[];
    if (d.todayHadith != null) items.add(_HadithItem(d.todayHadith!));
    for (int i = 0; i < d.todayAmalanList.length && i < 3; i++) {
      items.add(_AmalanItem(d.todayAmalanList[i], i));
    }
    if (d.todaySirah != null) items.add(_SirahItem(d.todaySirah!));
    for (final p in _posts) items.add(_PostItem(p));
    return items;
  }

  // ── BUILD ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final daily = context.watch<DailyContentProvider>();

    if (daily.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryGold),
          strokeWidth: 1.5,
        ),
      );
    }

    if (!_cached) {
      _items = _buildItems(daily);
      _cached = true;
    }

    if (_items.isEmpty) {
      return const Center(child: Text('Tiada konten', style: TextStyle(color: Colors.white)));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          widget.onScrollDirection?.call(scrollNotification.scrollDelta! > 0);
        }
        return false;
      },
      child: PageView.builder(
        controller: _pageController,
        itemCount: _items.length,
        // Guna PageMetrics untuk kira offset scroll secara real-time
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          // Kira jarak dari kad tengah
          double pageOffset = 0;
          if (_pageController.position.haveDimensions && _pageController.page != null) {
            pageOffset = (_pageController.page! - index).abs();
          } else {
            pageOffset = (_currentIndex - index).abs().toDouble();
          }

          // Apple Vision Pro Math: 
          // Kad tengah (offset 0) = Scale 1.0
          // Kad tepi (offset 1) = Scale 0.85
          double scale = 1.0 - (pageOffset * 0.15);
          scale = scale.clamp(0.85, 1.0);

          // Opacity: Kad tengah 1.0, Kad tepi 0.4
          double opacity = 1.0 - (pageOffset * 0.6);
          opacity = opacity.clamp(0.4, 1.0);

          final bool isFront = (index == _currentIndex);

          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              return Opacity(
                opacity: opacity,
                child: Transform(
                  alignment: Alignment.center,
                  // Sedikit rotate Y untuk rasa 3D tanpa guna Matrix4 berat
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // Perspective ringan
                    ..rotateY(pageOffset * 0.15 * (index < _currentIndex ? 1 : -1)),
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                ),
              );
            },
            child: _buildCardWidget(index, isFront, daily),
          );
        },
      ),
    );
  }

  Widget _buildCardWidget(int dataIdx, bool isFront, DailyContentProvider daily) {
    final item = _items[dataIdx];
    
    // Wrapper dengan padding & alignment supaya kad duduk cantik di tengah skrin
    return Center(
      child: Container(
        width: double.infinity,
        height: 400, // Boleh adjust tinggi kad di sini
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _getCardContent(item, isFront, daily),
        ),
      ),
    );
  }

  Widget _getCardContent(_FeedItem item, bool isFront, DailyContentProvider daily) {
    if (item is _HadithItem) {
      return DailyHadithCard(hadith: item.hadith, isCenter: isFront);
    } else if (item is _AmalanItem) {
      return DailyAmalanCard(
        amalan: item.amalan,
        isCenter: isFront,
        onToggle: () => daily.toggleAmalan(item.amalan.id),
      );
    } else if (item is _SirahItem) {
      return DailySirahCard(sirah: item.sirah, isCenter: isFront);
    } else {
      return FeedCard(
        post: (item as _PostItem).post,
        isCenter: isFront,
      );
    }
  }
}
