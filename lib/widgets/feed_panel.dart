// lib/widgets/feed_panel.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';
import 'feed_card.dart';
import 'daily_card.dart';

// ── MODEL ─────────────────────────────────────────────────────
// Item dalam wheel — boleh jadi FeedPost atau DailyItem
abstract class _WheelItem {}

class _FeedItem extends _WheelItem {
  final PostModel post;
  _FeedItem(this.post);
}

class _DailyHadithItem extends _WheelItem {
  final HadithToday hadith;
  _DailyHadithItem(this.hadith);
}

class _DailyAmalanItem extends _WheelItem {
  final AmalanToday amalan;
  final int index;
  _DailyAmalanItem(this.amalan, this.index);
}

class _DailySirahItem extends _WheelItem {
  final SirahToday sirah;
  _DailySirahItem(this.sirah);
}

// ── FEED PANEL ────────────────────────────────────────────────
class FeedPanel extends StatefulWidget {
  const FeedPanel({Key? key}) : super(key: key);

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel> {
  late final FixedExtentScrollController _controller;
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  static const double _diameterRatio = 1.8;

  static const List<PostModel> _posts = [
    PostModel(id: '101', type: 'video',   title: 'Kisah Hijrah Rasulullah ﷺ',        content: 'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda dari ancaman kaum Quraisy.',             author: 'Ustaz Don',        authorAge: '40', likes: 1240, time: '2j',  assetPath: 'assets/images/dummy_post1.jpg'),
    PostModel(id: '102', type: 'quote',   title: 'Kata Hikmah',                       content: 'Jangan bersedih, sesungguhnya Allah bersama kita. (At-Taubah: 40)',                                         author: "Imam Syafi'i",     authorAge: '',   likes: 850,  time: '5j'),
    PostModel(id: '103', type: 'article', title: 'Kelebihan Selawat',                 content: 'Barangsiapa berselawat ke atasku sekali, Allah balas sepuluh kali ganda rahmat kepadanya.',                 author: 'Habib Ali',        authorAge: '52', likes: 2100, time: '1h',  assetPath: 'assets/images/dummy_post2.jpg'),
    PostModel(id: '104', type: 'event',   title: 'Majlis Ilmu Perdana',               content: 'Jom sertai kami di Masjid Negeri untuk kupasan kitab Sirah Nabawiyah bersama ulama.',                       author: 'Admin iHijrah',    authorAge: '',   likes: 500,  time: '10j'),
    PostModel(id: '105', type: 'quote',   title: 'Pesan Imam Malik',                  content: 'Ilmu itu bukan pada apa yang dihafal, tetapi pada apa yang memberi manfaat kepada hati.',                   author: 'Imam Malik',       authorAge: '',   likes: 3200, time: '12j'),
    PostModel(id: '106', type: 'video',   title: 'Tajwid Asas: Al-Fatihah',           content: 'Mari perbaiki bacaan Al-Fatihah kita. Setiap huruf ada makhrajnya yang tersendiri.',                       author: 'Ustaz Azhar',      authorAge: '60', likes: 890,  time: '1h'),
    PostModel(id: '107', type: 'article', title: 'Rahsia Dhuha & Pintu Rezeki',       content: 'Konsistensi solat Dhuha membuka pintu rezeki yang tidak disangka-sangka oleh manusia biasa.',              author: 'Ustaz Wadi',       authorAge: '45', likes: 4500, time: '30m', assetPath: 'assets/images/dummy_post1.jpg'),
    PostModel(id: '108', type: 'quote',   title: 'Nasihat Imam Ghazali',              content: 'Ilmu tanpa amal itu gila, amal tanpa ilmu itu sia-sia. Carilah keduanya bersama.',                          author: 'Imam Ghazali',     authorAge: '',   likes: 5100, time: '2h'),
    PostModel(id: '109', type: 'article', title: 'Keutamaan Surah Al-Mulk',           content: 'Sesiapa yang membaca Al-Mulk setiap malam, ia akan dilindungi dari azab kubur.',                            author: 'Ustazah Noor',     authorAge: '38', likes: 1870, time: '3h',  assetPath: 'assets/images/dummy_post2.jpg'),
    PostModel(id: '110', type: 'event',   title: 'Kem Tahfiz Ramadan 1446H',          content: 'Daftar sekarang! Kem intensif hafazan Al-Quran 10 hari untuk semua peringkat umur.',                        author: 'Markaz Quran KL',  authorAge: '',   likes: 720,  time: '4h'),
    PostModel(id: '111', type: 'video',   title: 'Doa Pagi yang Mujarab',             content: 'Amalkan 7 doa ini setiap pagi. Nabi ﷺ sendiri mengajarkan kepada para sahabat baginda.',                   author: 'Dr Rozaimi',       authorAge: '47', likes: 3300, time: '5h',  assetPath: 'assets/images/dummy_post1.jpg'),
    PostModel(id: '112', type: 'quote',   title: 'Kata Ibn Qayyim',                   content: 'Hati yang kosong dari zikir adalah hati yang mati walaupun pemiliknya masih bernyawa.',                      author: 'Ibn Qayyim',       authorAge: '',   likes: 6200, time: '6h'),
    PostModel(id: '113', type: 'article', title: 'Adab Berdoa dalam Islam',           content: 'Berdoa bukan sekadar meminta. Ada adab, waktu mustajab dan cara yang diajar oleh Rasulullah ﷺ.',            author: 'Ust Hasrizal',     authorAge: '43', likes: 980,  time: '7h',  assetPath: 'assets/images/dummy_post2.jpg'),
    PostModel(id: '114', type: 'event',   title: 'Forum Muallaf: Jalan Menuju Islam', content: 'Dengar kisah perjalanan rohani mereka yang menemui cahaya Islam dari seluruh dunia.',                        author: 'iHijrah Official', authorAge: '',   likes: 430,  time: '8h'),
    PostModel(id: '115', type: 'video',   title: 'Tafsir Surah Al-Kahfi Ayat 1-10',  content: 'Perlindungan dari fitnah Dajjal bermula dengan memahami 10 ayat pertama surah ini sepenuhnya.',             author: 'Ust Fathul Bari',  authorAge: '50', likes: 7800, time: '9h',  assetPath: 'assets/images/dummy_post1.jpg'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  // Bina senarai gabungan: daily cards dulu, feed posts kemudian
  List<_WheelItem> _buildItems(DailyContentProvider daily) {
    final List<_WheelItem> items = [];

    // 1. Hadith
    if (daily.todayHadith != null) {
      items.add(_DailyHadithItem(daily.todayHadith!));
    }

    // 2. Amalan (max 3 supaya tak banjiri wheel)
    for (int i = 0; i < daily.todayAmalanList.length && i < 3; i++) {
      items.add(_DailyAmalanItem(daily.todayAmalanList[i], i));
    }

    // 3. Sirah
    if (daily.todaySirah != null) {
      items.add(_DailySirahItem(daily.todaySirah!));
    }

    // 4. Feed posts
    for (final p in _posts) {
      items.add(_FeedItem(p));
    }

    return items;
  }

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

    final List<_WheelItem> items = _buildItems(daily);

    return SizedBox.expand(
      child: ListWheelScrollView.useDelegate(
        controller: _controller,
        itemExtent: 180.0,
        diameterRatio: _diameterRatio,
        perspective: 0.002,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) =>
            _currentIndex.value = index,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: _cachedItems.length,
          builder: (context, index) {
            final item = _cachedItems[index];
            return ValueListenableBuilder<int>(
              valueListenable: _currentIndex,
              builder: (context, currentIdx, __) {
                final bool isCenter = index == currentIdx;

                if (item is _DailyHadithItem) {
                  return DailyHadithCard(
                    hadith: item.hadith,
                    isCenter: isCenter,
                  );
                }
                if (item is _DailyAmalanItem) {
                  return DailyAmalanCard(
                    amalan: item.amalan,
                    isCenter: isCenter,
                    onToggle: () =>
                        daily.toggleAmalan(item.amalan.id),
                  );
                }
                if (item is _DailySirahItem) {
                  return DailySirahCard(
                    sirah: item.sirah,
                    isCenter: isCenter,
                  );
                }
                // Feed card biasa
                final post = (item as _FeedItem).post;
                return FeedCard(
                  post: post,
                  isCenter: isCenter,
                  onTap: () => _controller.animateToItem(
                    index,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
