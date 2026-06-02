// lib/widgets/feed_panel.dart
// 3D Cylinder Carousel — CSS-style rotateY+translateZ per card.
//
// PERFORMANCE:
//   - ValueNotifier<double> _angle (no setState on tick)
//   - AnimatedBuilder rebuilds ONLY the slot geometry, not card content
//   - RepaintBoundary per card slot
//
// BACK-FACE CULLING:
//   - Cards with cos(angle) < 0 are behind viewer → skip
//   - Only front hemisphere (≤5 cards) ever rendered

import 'dart:math' as math;
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

// ── CONSTANTS (UPDATED TO MATCH SIMULATOR) ────────────────────
const double _kRadius      = 215.0;
const double _kPerspective = 0.00200;
const double _kTiltX       = -0.32;
const double _kCardW       = 200.0;
const double _kCardH       = 200.0;        // 1:1 square card
const double _kAngleStep   = (2 * math.pi) / 16.0;

// ── FEED PANEL ────────────────────────────────────────────────
class FeedPanel extends StatefulWidget {
  final void Function(bool scrollingDown)? onScrollDirection;
  const FeedPanel({Key? key, this.onScrollDirection}) : super(key: key);

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel>
    with SingleTickerProviderStateMixin {

  // ValueNotifier — angle changes don't trigger setState on this widget.
  // AnimatedBuilder subscribes and rebuilds only the Stack geometry.
  final ValueNotifier<double> _angle    = ValueNotifier(0.0);
  double                      _velocity = 0.0;
  bool                        _dragging = false;
  double                      _lastX    = 0;
  double                      _lastTime = 0;

  late final _ticker;

  List<_FeedItem> _items  = [];
  bool            _cached = false;

  static const double _kCullThreshold = 0.10; // cos(84°) — tighter, less overlap 

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
    PostModel(id:'111',type:'video',  title:'Doa Pagi yang Mujarab',            content:'Amalkan 7 doa ini setiap pagi. Nabi ﷺ mengajarkan kepada para sahabat.',                   author:'Dr Rozaimi',     authorAge:'47',likes:3300,time:'5h', assetPath:'assets/images/dummy_post1.jpg'),
    PostModel(id:'112',type:'quote',  title:'Kata Ibn Qayyim',                  content:'Hati yang kosong dari zikir adalah hati yang mati walaupun bernyawa.',                      author:'Ibn Qayyim',     authorAge:'',  likes:6200,time:'6h'),
    PostModel(id:'115',type:'video',  title:'Tafsir Surah Al-Kahfi Ayat 1-10', content:'Perlindungan dari fitnah Dajjal bermula dengan 10 ayat pertama surah ini.',                  author:'Ust Fathul Bari',authorAge:'50',likes:7800,time:'9h', assetPath:'assets/images/dummy_post1.jpg'),
  ];

  @override
  void initState() {
    super.initState();
    // Ticker (vsync-safe) — updates ValueNotifier without triggering setState
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _angle.dispose();
    super.dispose();
  }

  void _onTick(Duration _) {
    if (!_dragging) {
      _angle.value += 0.003 + _velocity;
      _velocity     *= 0.94;
    }
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

  // ── GESTURE ───────────────────────────────────────────────
  void _onPanStart(DragStartDetails d) {
    _dragging = true;
    _lastX    = d.globalPosition.dx;
    _lastTime = DateTime.now().millisecondsSinceEpoch.toDouble();
    _velocity = 0;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!_dragging) return;
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    final dx  = d.globalPosition.dx - _lastX;
    final dy  = d.globalPosition.dy - _lastX; // unused for carousel
    final dt  = (now - _lastTime).clamp(1.0, 100.0);
    final dA  = -dx * 0.006;
    _velocity  = dA / dt * 16;
    _angle.value += dA;
    _lastX    = d.globalPosition.dx;
    _lastTime = now;
    // Sidebar: any leftward/downward swipe hides, rightward/upward shows
    if (dx.abs() > 2) widget.onScrollDirection?.call(dx < 0);
  }

  void _onPanEnd(DragEndDetails _) => _dragging = false;

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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart:  _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd:    _onPanEnd,
      // AnimatedBuilder: only the Stack geometry rerenders each frame.
      // Card CONTENT is wrapped in RepaintBoundary → stays cached.
      child: AnimatedBuilder(
        animation: _angle,
        builder: (ctx, _) => _buildCarousel(ctx, daily),
      ),
    );
  }

  Widget _buildCarousel(BuildContext ctx, DailyContentProvider daily) {
    // Enumerate all slots; cull anything behind the viewer.
    final slots = <Map<String, dynamic>>[];

    // Walk enough slots to fill front hemisphere on both sides.
    // With _kAngleStep=30°, ±5 covers 150° — but we cull at cos<-0.05.
    for (int i = -6; i <= 6; i++) {
      final double cardAngle = _angle.value + i * _kAngleStep;
      final double cosA      = math.cos(cardAngle);

      // Back-face cull: don't render cards behind viewer.
      // This also prevents mirrored/flipped back-face artifacts.
      if (cosA < _kCullThreshold) continue;

      // Opacity: 0.12 (back) → 0.575 (side) → 1.0 (front) — matches simulator
      final double opacity = (0.12 + ((cosA + 1) / 2) * 0.88).clamp(0.0, 1.0);
      if (opacity < 0.05) continue;

      final int dataIdx =
          ((i) % _items.length + _items.length) % _items.length;

      // CSS-style Matrix4 per card:
      //   perspective → tilt ring → orbit → push to surface
      //
      //   rotateX(_kTiltX)  — view ring from slightly above
      //   rotateY(cardAngle)— orbit each card to its position
      //   translate(0,0,r)  — push card out to cylinder surface
      //
      // This makes each card FACE OUTWARD from the cylinder, matching CSS:
      //   transform: rotateY(angle) translateZ(radius)
      final Matrix4 m = Matrix4.identity()
        ..setEntry(3, 2, _kPerspective)
        ..rotateX(_kTiltX)
        ..rotateY(cardAngle)
        ..translate(0.0, 0.0, _kRadius);

      slots.add({
        'dataIdx': dataIdx,
        'cosA'   : cosA,
        'opacity': opacity,
        'matrix' : m,
        'front'  : i == 0,
      });
    }

    // Painter's algorithm: lowest cosA (furthest back) drawn first.
    slots.sort((a, b) =>
        (a['cosA'] as double).compareTo(b['cosA'] as double));

    return Stack(
      alignment:    Alignment.center,
      clipBehavior: Clip.hardEdge,
      children: [
        for (final s in slots)
          _buildSlot(s, daily),
      ],
    );
  }

  Widget _buildSlot(Map<String, dynamic> s, DailyContentProvider daily) {
    final int     dataIdx = s['dataIdx'] as int;
    final double  opacity = s['opacity'] as double;
    final Matrix4 matrix  = s['matrix']  as Matrix4;
    final bool    isFront = s['front']   as bool;
    final double  cosA    = s['cosA']    as double;

    // Back-face: when card faces away (cosA < 0), show dark shape instead
    // of mirrored card content — matches CSS backface-visibility:hidden + back face element
    final Widget child = cosA >= 0
        ? RepaintBoundary(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width:  _kCardW,
                height: _kCardH,
                child: _buildCardWidget(dataIdx, isFront, daily),
              ),
            ),
          )
        : Container(
            width:  _kCardW,
            height: _kCardH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF0a0812),
              border: Border.all(
                color: Colors.white.withOpacity(0.04),
                width: 1,
              ),
            ),
          );

    return Opacity(
      opacity: opacity,
      child: Transform(
        transform: matrix,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _buildCardWidget(int dataIdx, bool isFront, DailyContentProvider daily) {
    final item = _items[dataIdx];
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
