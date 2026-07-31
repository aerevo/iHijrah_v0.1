// lib/widgets/feed_panel.dart
// Panel KOMUNITI kini guna grid masonry 2-lajur (TwoColumnMasonry) —
// setiap kad tinggi ikut kandungan sebenar, bukan childAspectRatio tetap.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';
import 'feed_card.dart';
import 'daily_card.dart';
import 'anim_helpers.dart';
import 'masonry_grid.dart';

// ── ITEM MODELS ───────────────────────────────────────────────
abstract class _FeedItem {}
class _PostItem   extends _FeedItem { final PostModel post;     _PostItem(this.post); }
class _HadithItem extends _FeedItem { final HadithToday hadith; _HadithItem(this.hadith); }
class _AmalanItem extends _FeedItem { final AmalanToday amalan; final int idx; _AmalanItem(this.amalan, this.idx); }
class _SirahItem  extends _FeedItem { final SirahToday sirah;   _SirahItem(this.sirah); }

class FeedPanel extends StatefulWidget {
  final void Function(bool scrollingDown)? onScrollDirection;
  const FeedPanel({Key? key, this.onScrollDirection}) : super(key: key);

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel> {

  List<_FeedItem> _dailyItems = [];
  List<PostModel> _posts      = [];
  bool            _cached     = false;

  static const List<PostModel> _allPosts = [
    PostModel(id:'101',type:'video',  title:'Kisah Hijrah Rasulullah ﷺ',       content:'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda.',        author:'Ustaz Don',       authorAge:'40',likes:1240,time:'2j',  assetPath:'assets/images/dummy_post1.jpg'),
    PostModel(id:'102',type:'quote',  title:'Kata Hikmah',                      content:'Jangan bersedih, sesungguhnya Allah bersama kita. (At-Taubah: 40)',          author:"Imam Syafi'i",    authorAge:'',  likes:850, time:'5j'),
    PostModel(id:'103',type:'article',title:'Kelebihan Selawat',                content:'Barangsiapa berselawat sekali, Allah balas sepuluh kali ganda.',             author:'Habib Ali',       authorAge:'52',likes:2100,time:'1h',  assetPath:'assets/images/dummy_post2.jpg'),
    PostModel(id:'104',type:'event',  title:'Majlis Ilmu Perdana',              content:'Jom sertai kami di Masjid Negeri untuk kupasan kitab Sirah Nabawiyah.',      author:'Admin iHijrah',   authorAge:'',  likes:500, time:'10j'),
    PostModel(id:'105',type:'quote',  title:'Pesan Imam Malik',                 content:'Ilmu bukan pada apa yang dihafal, tetapi pada apa yang memberi manfaat.',    author:'Imam Malik',      authorAge:'',  likes:3200,time:'12j'),
    PostModel(id:'106',type:'video',  title:'Tajwid Asas: Al-Fatihah',          content:'Mari perbaiki bacaan Al-Fatihah. Setiap huruf ada makhrajnya.',              author:'Ustaz Azhar',     authorAge:'60',likes:890, time:'1h'),
    PostModel(id:'107',type:'article',title:'Rahsia Dhuha & Pintu Rezeki',      content:'Konsistensi solat Dhuha membuka pintu rezeki yang tidak disangka-sangka.',  author:'Ustaz Wadi',      authorAge:'45',likes:4500,time:'30m', assetPath:'assets/images/dummy_post1.jpg'),
    PostModel(id:'108',type:'quote',  title:'Nasihat Imam Ghazali',             content:'Ilmu tanpa amal itu gila, amal tanpa ilmu itu sia-sia.',                     author:'Imam Ghazali',    authorAge:'',  likes:5100,time:'2h'),
    PostModel(id:'109',type:'article',title:'Keutamaan Surah Al-Mulk',          content:'Sesiapa membaca Al-Mulk setiap malam dilindungi dari azab kubur.',           author:'Ustazah Noor',    authorAge:'38',likes:1870,time:'3h',  assetPath:'assets/images/dummy_post2.jpg'),
    PostModel(id:'110',type:'event',  title:'Kem Tahfiz Ramadan 1446H',         content:'Kem intensif hafazan Al-Quran 10 hari untuk semua peringkat umur.',          author:'Markaz Quran KL', authorAge:'',  likes:720, time:'4h'),
    PostModel(id:'111',type:'video',  title:'Doa Pagi yang Mujarab',            content:'Amalkan 7 doa ini setiap pagi. Nabi ﷺ mengajarkan kepada para sahabat.',    author:'Dr Rozaimi',      authorAge:'47',likes:3300,time:'5h',  assetPath:'assets/images/dummy_post1.jpg'),
    PostModel(id:'112',type:'quote',  title:'Kata Ibn Qayyim',                  content:'Hati yang kosong dari zikir adalah hati yang mati walaupun bernyawa.',       author:'Ibn Qayyim',      authorAge:'',  likes:6200,time:'6h'),
    PostModel(id:'115',type:'video',  title:'Tafsir Surah Al-Kahfi Ayat 1-10', content:'Perlindungan dari fitnah Dajjal bermula dengan 10 ayat pertama surah ini.',  author:'Ust Fathul Bari', authorAge:'50',likes:7800,time:'9h',  assetPath:'assets/images/dummy_post1.jpg'),
  ];

  List<_FeedItem> _buildDaily(DailyContentProvider d) {
    final items = <_FeedItem>[];
    if (d.todayHadith != null) items.add(_HadithItem(d.todayHadith!));
    for (int i = 0; i < d.todayAmalanList.length && i < 3; i++) {
      items.add(_AmalanItem(d.todayAmalanList[i], i));
    }
    if (d.todaySirah != null) items.add(_SirahItem(d.todaySirah!));
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

    if (!_cached) {
      _dailyItems = _buildDaily(daily);
      _posts      = _allPosts;
      _cached     = true;
    }

    return NotificationListener<UserScrollNotification>(
      onNotification: (n) {
        if (n.direction == ScrollDirection.reverse) {
          widget.onScrollDirection?.call(true);
        } else if (n.direction == ScrollDirection.forward) {
          widget.onScrollDirection?.call(false);
        }
        return false;
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── HARI INI — jalur mendatar ──────────────────────
          if (_dailyItems.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
                child: Text('HARI INI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: kTextMuted,
                    )),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 208,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  itemCount: _dailyItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => SizedBox(
                    width: 152,
                    child: FadeSlideIn(
                      index: i,
                      slideOffset: 0.15,
                      child: _dailyCard(_dailyItems[i], daily),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
          ],

          // ── KOMUNITI — grid masonry organik ─────────────────
          // Ganti SliverGrid+childAspectRatio tetap (punca rupa "kaku")
          // dengan TwoColumnMasonry: setiap kad tinggi ikut kandungan
          // sebenar (kad petikan pendek/panjang, gambar pelbagai nisbah
          // aspek), lajur kekal seimbang ikut anggaran tinggi.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text('KOMUNITI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: kTextMuted,
                  )),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
              child: TwoColumnMasonry(
                tiles: List.generate(_posts.length, (i) {
                  final post  = _posts[i];
                  final ratio = _imageAspectFor(post);
                  return MasonryTile(
                    heightWeight: _heightWeightFor(post, ratio),
                    child: FadeSlideIn(
                      index: i,
                      child: FeedCard(post: post, imageAspectRatio: ratio),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Kumpulan nisbah aspek gambar berbeza — dipilih ikut hash id post
  // (deterministic, bukan Random(), supaya kekal sama tiap rebuild/
  // scroll balik) supaya thumbnail dalam grid nampak pelbagai saiz
  // secara organik, bukan seragam macam sebelum ini.
  static const List<double> _aspectPool = [0.85, 1.15, 1.45, 1.7];

  double _imageAspectFor(PostModel post) {
    return _aspectPool[post.id.hashCode.abs() % _aspectPool.length];
  }

  // Anggaran tinggi RELATIF setiap kad (unit tidak semestinya px sebenar)
  // — asas untuk TwoColumnMasonry agihkan kad ke lajur paling pendek.
  double _heightWeightFor(PostModel post, double imageAspect) {
    const double colWidthUnit = 165; // ~lebar 1 lajur pada skrin telefon biasa

    if (post.type == 'quote') {
      const double charsPerLine = 30;
      final int lines = (post.content.length / charsPerLine).ceil().clamp(2, 6);
      return (70 + (lines * 20) + 40).toDouble(); // ikon + baris petikan + baris pengarang
    }

    final double imageHeight = colWidthUnit / imageAspect;
    return imageHeight + 90; // + tajuk (2 baris) + baris meta + padding
  }

  Widget _dailyCard(_FeedItem item, DailyContentProvider daily) {
    if (item is _HadithItem) {
      return DailyHadithCard(hadith: item.hadith, isCenter: false);
    }
    if (item is _AmalanItem) {
      return DailyAmalanCard(
        amalan: item.amalan, isCenter: false,
        onToggle: () => daily.toggleAmalan(item.amalan.id),
      );
    }
    return DailySirahCard(sirah: (item as _SirahItem).sirah, isCenter: false);
  }
}
