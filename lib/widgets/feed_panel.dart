// lib/widgets/feed_panel.dart  (V3 — Unboxed Editorial)
//
// Perubahan utama drpd V2:
// → SliverPadding sisi kiri-kanan ditukar 16→0. Post FeedCard V7
//   kini full-width tanpa kotak — padding diurus dalam post itu sendiri.
// → Padding(bottom:20) per-item dibuang. Setiap post sudah ada
//   whitespace sendiri (editorial: 32px bawah, bar hitam quote: visual
//   cukup, tiket: 16px bawah). Pemisah antara post = hairline dalam
//   FeedCard + whitespace dari konten post itu.
// → Tiada perubahan lain — DailyCard baris mendatar, logik data,
//   provider, scroll direction — semua kekal sama.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';
import '../theme/feed_theme.dart';
import 'feed_card.dart';
import 'daily_card.dart';
import 'anim_helpers.dart';

// ── ITEM MODELS ───────────────────────────────────────────────
abstract class _FeedItem {}
class _PostItem   extends _FeedItem { final PostModel post;     _PostItem(this.post); }
class _HadithItem extends _FeedItem { final HadithToday hadith; _HadithItem(this.hadith); }
class _AmalanItem extends _FeedItem { final AmalanToday amalan; final int idx; _AmalanItem(this.amalan, this.idx); }
class _SirahItem  extends _FeedItem { final SirahToday sirah;   _SirahItem(this.sirah); }

class FeedPanel extends StatefulWidget {
  final void Function(bool scrollingDown)? onScrollDirection;
  final FeedPalette palette;
  const FeedPanel({Key? key, this.onScrollDirection, required this.palette}) : super(key: key);

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel> {

  List<_FeedItem> _dailyItems = [];
  List<PostModel> _posts      = [];
  bool            _cached     = false;

  static const List<PostModel> _allPosts = [
    PostModel(id:'101',type:'video',  title:'Kisah Hijrah Rasulullah ﷺ',       content:'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda.',        author:'Ustaz Don',       authorAge:'40',likes:1240,time:'2j',  assetPath:'assets/images/dummy_post1.jpg'),
    PostModel(id:'102',type:'quote',  title:'Kata Hikmah',                     content:'Jangan bersedih, sesungguhnya Allah bersama kita. (At-Taubah: 40)',          author:"Imam Syafi'i",    authorAge:'',  likes:850, time:'5j'),
    PostModel(id:'103',type:'article',title:'Kelebihan Selawat',                content:'Barangsiapa berselawat sekali, Allah balas sepuluh kali ganda.',              author:'Habib Ali',       authorAge:'52',likes:2100,time:'1h',  assetPath:'assets/images/dummy_post2.jpg'),
    PostModel(id:'104',type:'event',  title:'Majlis Ilmu Perdana',              content:'Jom sertai kami di Masjid Negeri untuk kupasan kitab Sirah Nabawiyah.',       author:'Admin iHijrah',   authorAge:'',  likes:500, time:'10j'),
    PostModel(id:'105',type:'quote',  title:'Pesan Imam Malik',                 content:'Ilmu bukan pada apa yang dihafal, tetapi pada apa yang memberi manfaat.',     author:'Imam Malik',      authorAge:'',  likes:3200,time:'12j'),
    PostModel(id:'106',type:'video',  title:'Tajwid Asas: Al-Fatihah',          content:'Mari perbaiki bacaan Al-Fatihah. Setiap huruf ada makhrajnya.',               author:'Ustaz Azhar',     authorAge:'60',likes:890, time:'1h'),
    PostModel(id:'107',type:'article',title:'Rahsia Dhuha & Pintu Rezeki',      content:'Konsistensi solat Dhuha membuka pintu rezeki yang tidak disangka-sangka.',  author:'Ustaz Wadi',      authorAge:'45',likes:4500,time:'30m', assetPath:'assets/images/dummy_post1.jpg'),
    PostModel(id:'108',type:'quote',  title:'Nasihat Imam Ghazali',             content:'Ilmu tanpa amal itu gila, amal tanpa ilmu itu sia-sia.',                      author:'Imam Ghazali',    authorAge:'',  likes:5100,time:'2h'),
    PostModel(id:'109',type:'article',title:'Keutamaan Surah Al-Mulk',          content:'Sesiapa membaca Al-Mulk setiap malam dilindungi dari azab kubur.',            author:'Ustazah Noor',    authorAge:'38',likes:1870,time:'3h',  assetPath:'assets/images/dummy_post2.jpg'),
    PostModel(id:'110',type:'event',  title:'Kem Tahfiz Ramadan 1446H',         content:'Kem intensif hafazan Al-Quran 10 hari untuk semua peringkat umur.',           author:'Markaz Quran KL', authorAge:'',  likes:720, time:'4h'),
    PostModel(id:'111',type:'video',  title:'Doa Pagi yang Mujarab',            content:'Amalkan 7 doa ini setiap pagi. Nabi ﷺ mengajarkan kepada para sahabat.',    author:'Dr Rozaimi',      authorAge:'47',likes:3300,time:'5h',  assetPath:'assets/images/dummy_post1.jpg'),
    PostModel(id:'112',type:'quote',  title:'Kata Ibn Qayyim',                  content:'Hati yang kosong dari zikir adalah hati yang mati walaupun bernyawa.',        author:'Ibn Qayyim',      authorAge:'',  likes:6200,time:'6h'),
    PostModel(id:'115',type:'video',  title:'Tafsir Surah Al-Kahfi Ayat 1-10', content:'Perlindungan dari fitnah Dajjal bermula dengan 10 ayat pertama surah ini.',  author:'Ust Fathul Bari', authorAge:'50',likes:7800,time:'9h',  assetPath:'assets/images/dummy_post1.jpg'),
    PostModel(id:'116',type:'article',title:'Merenung Ciptaan Langit',          content:'Tidakkah kamu perhatikan langit yang terbentang tanpa tiang? (Ar-Ra\'d: 2)', author:'Ustaz Firdaus',   authorAge:'44',likes:2650,time:'7h',  assetPath:'assets/images/langit.png'),
    PostModel(id:'117',type:'event',  title:'Selamat Datang ke iHijrah',        content:'Versi terkini iHijrah kini rasmi — Embun Jiwa untuk peneman ibadah harian anda.', author:'Admin iHijrah',   authorAge:'',  likes:980, time:'1h',  assetPath:'assets/images/logo.png'),
    PostModel(id:'118',type:'article',title:'Kenali Pokok Hijrah Anda',         content:'Setiap amalan yang kau catat menumbuhkan Pokok Embun Jiwa kau sendiri.',      author:'Admin iHijrah',   authorAge:'',  likes:1540,time:'3h',  assetPath:'assets/images/pokok_intro.png'),
    PostModel(id:'119',type:'event',  title:'Naik Level 2: Pucuk Menghijau',    content:'Tahniah! Konsistensi amalan kau dah cukup untuk pokok naik ke Level 2.',      author:'Admin iHijrah',   authorAge:'',  likes:610, time:'2h',  assetPath:'assets/images/pokok_level2.png'),
    PostModel(id:'120',type:'event',  title:'Naik Level 3: Dahan Mula Rendang', content:'Pokok kau semakin rendang — teruskan istiqamah, jangan putus rentak.',        author:'Admin iHijrah',   authorAge:'',  likes:730, time:'4h',  assetPath:'assets/images/pokok_level3.png'),
    PostModel(id:'121',type:'event',  title:'Naik Level 4: Berbuah Amalan',      content:'Masya-Allah, pokok kau dah mula berbuah — hasil disiplin ibadah harian.',      author:'Admin iHijrah',   authorAge:'',  likes:890, time:'6h',  assetPath:'assets/images/pokok_level4.png'),
    PostModel(id:'122',type:'event',  title:'Naik Level 5: Pokok Matang Emas',  content:'Tahap tertinggi dicapai — pokok kau kini matang & berkilauan keemasan.',      author:'Admin iHijrah',   authorAge:'',  likes:1120,time:'8h',  assetPath:'assets/images/pokok_level5.png'),
    PostModel(id:'123',type:'article',title:'Sertai Komuniti iHijrah',          content:'Kongsi perjalanan hijrah kau bersama ribuan pengguna lain di seluruh negara.', author:'Admin iHijrah',   authorAge:'',  likes:1780,time:'11h', assetPath:'assets/images/profile_default.png'),
    PostModel(id:'124',type:'article',title:'Tema Wallpaper Baharu Tersedia',   content:'Latar belakang baharu \"Embun Jiwa\" kini boleh dipilih dalam tetapan aplikasi.', author:'Admin iHijrah',   authorAge:'',  likes:640, time:'13h', assetPath:'assets/images/wallpaper.png'),
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
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(widget.palette.accent),
          strokeWidth: 1.5,
        ),
      );
    }

    if (!_cached) {
      _dailyItems = _buildDaily(daily);
      _posts      = _allPosts;
      _cached     = true;
    }

    return Container(
      color: Colors.transparent,
      child: NotificationListener<UserScrollNotification>(
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

            // ── HARI INI — jalur mendatar ───────────────────────────
            if (_dailyItems.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                  child: Text('HARI INI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: widget.palette.textMuted,
                      )),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 236,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _dailyItems.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => SizedBox(
                      width: 178,
                      child: FadeSlideIn(
                        index: i,
                        slideOffset: 0.15,
                        child: _dailyCard(_dailyItems[i], daily),
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],

            // ── KOMUNITI — satu lajur penuh, unboxed editorial ──────
            // V3: SliverPadding sisi = 0. Post full-width, terapung
            // terus atas latar krim skrin. Padding 16px kiri-kanan
            // diurus dalam FeedCard itu sendiri (_buildEditorial &
            // _buildTicket). Post dipisah oleh hairline + whitespace
            // konten sendiri — tiada margin per-item lagi.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text('KOMUNITI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: widget.palette.textMuted,
                    )),
              ),
            ),
            SliverPadding(
              // ← sisi 0: post full-width
              // ↓ bawah 40: ruang nafas selepas post terakhir
              padding: const EdgeInsets.only(bottom: 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final post  = _posts[i];
                    final ratio = _imageAspectFor(post);
                    // Tiada Padding wrapper per-item — FeedCard V7
                    // uruskan whitespace & hairline sendiri.
                    return FadeSlideIn(
                      index: i,
                      child: FeedCard(
                        post: post,
                        imageAspectRatio: ratio,
                        palette: widget.palette,
                      ),
                    );
                  },
                  childCount: _posts.length,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  static const List<double> _aspectPool = [1.05, 1.25, 1.45, 1.7];

  double _imageAspectFor(PostModel post) {
    return _aspectPool[post.id.hashCode.abs() % _aspectPool.length];
  }

  Widget _dailyCard(_FeedItem item, DailyContentProvider daily) {
    if (item is _HadithItem) {
      return DailyHadithCard(hadith: item.hadith, palette: widget.palette);
    }
    if (item is _AmalanItem) {
      return DailyAmalanCard(
        amalan: item.amalan, palette: widget.palette,
        onToggle: () => daily.toggleAmalan(item.amalan.id),
      );
    }
    return DailySirahCard(sirah: (item as _SirahItem).sirah, palette: widget.palette);
  }
}
