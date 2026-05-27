// lib/widgets/feed_panel.dart
// 3D Cylinder Carousel — CSS-style rotateY+translateZ per card
// Each card is positioned AND oriented by Matrix4, matching the
// "rotateY(angle) translateZ(radius)" approach from CSS 3D sliders.

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

// ── CONSTANTS ─────────────────────────────────────────────────
// CSS-style 3D: transform = rotateX(tilt) * rotateY(angle) * translate(0,0,radius)
// Cards face OUTWARD — same as CSS `rotateY(θ) translateZ(r)` on each face.
const double _kRadius      = 340.0;   // cylinder radius in logical px
const double _kPerspective = 0.00065; // Matrix4 entry(3,2) — perspective depth
const double _kTiltX      = -0.20;   // ring tilt toward viewer (radians, negative = top away)
const double _kCardW       = 200.0;
const double _kCardH       = 280.0;
const int    _kVisible     = 5;       // slots rendered each side of center
const double _kAngleStep   = (2 * math.pi) / 12.0; // 12 slots per full ring

// ── FEED PANEL ────────────────────────────────────────────────
class FeedPanel extends StatefulWidget {
  final void Function(bool scrollingDown)? onScrollDirection;
  const FeedPanel({Key? key, this.onScrollDirection}) : super(key: key);

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel>
    with SingleTickerProviderStateMixin {

  double _angle    = 0.0;
  double _velocity = 0.0;
  bool   _dragging = false;
  double _lastX    = 0;
  double _lastTime = 0;

  late AnimationController _ticker;

  List<_FeedItem> _items  = [];
  bool            _cached = false;

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
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(days: 999),
    )..addListener(_onTick)..forward();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick() {
    if (!_dragging) {
      setState(() {
        _angle    += 0.003 + _velocity;
        _velocity *= 0.94;
      });
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
    final now  = DateTime.now().millisecondsSinceEpoch.toDouble();
    final dx   = d.globalPosition.dx - _lastX;
    final dt   = (now - _lastTime).clamp(1, 100);
    final dA   = -dx * 0.006;
    _velocity  = dA / dt * 16;
    setState(() => _angle += dA);
    _lastX    = d.globalPosition.dx;
    _lastTime = now;
    widget.onScrollDirection?.call(dx < 0);
  }

  void _onPanEnd(DragEndDetails _) => _dragging = false;

  // ── BUILD ─────────────────────────────────────────────────
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

    // Build slot list with Z-depth for painter's sort
    final List<Map<String, dynamic>> slots = [];
    for (int i = -_kVisible; i <= _kVisible; i++) {
      final double cardAngle = _angle + i * _kAngleStep;
      // Z depth: cos(angle)*radius — positive = in front
      final double zDepth = math.cos(cardAngle) * _kRadius;
      // Normalised 0..1 for opacity
      final double nz = (zDepth + _kRadius) / (2 * _kRadius);
      final double opacity = (0.12 + nz * 0.88).clamp(0.0, 1.0);
      if (opacity < 0.08) continue;

      final int dataIdx =
          ((i) % _items.length + _items.length) % _items.length;

      // CSS-style per-card Matrix4:
      //   setEntry(3,2,p)  — perspective
      //   rotateX(tiltX)   — tilt entire ring (top away = top-down view)
      //   rotateY(angle)   — orbit card to its slot on the ring
      //   translate(0,0,r) — push card outward to cylinder surface
      // Result: card is positioned AND faces outward, matching CSS
      //   `transform: rotateY(angle) translateZ(radius)`
      final Matrix4 m = Matrix4.identity()
        ..setEntry(3, 2, _kPerspective)
        ..rotateX(_kTiltX)
        ..rotateY(cardAngle)
        ..translate(0.0, 0.0, _kRadius);

      slots.add({
        'dataIdx': dataIdx,
        'zDepth' : zDepth,
        'opacity': opacity,
        'matrix' : m,
        'front'  : i == 0,
      });
    }

    // Painter's algorithm: back cards first
    slots.sort((a, b) =>
        (a['zDepth'] as double).compareTo(b['zDepth'] as double));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart:  _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd:    _onPanEnd,
      child: Stack(
        // Alignment.center: all Transform children originate at panel center
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        children: [
          for (final s in slots)
            _buildSlot(s, daily),
        ],
      ),
    );
  }

  Widget _buildSlot(Map<String, dynamic> s, DailyContentProvider daily) {
    final int     dataIdx = s['dataIdx'] as int;
    final double  opacity = s['opacity'] as double;
    final Matrix4 matrix  = s['matrix']  as Matrix4;
    final bool    isFront = s['front']   as bool;

    final item = _items[dataIdx];

    Widget card;
    if (item is _HadithItem) {
      card = DailyHadithCard(hadith: item.hadith, isCenter: isFront);
    } else if (item is _AmalanItem) {
      card = DailyAmalanCard(
        amalan: item.amalan,
        isCenter: isFront,
        onToggle: () => daily.toggleAmalan(item.amalan.id),
      );
    } else if (item is _SirahItem) {
      card = DailySirahCard(sirah: item.sirah, isCenter: isFront);
    } else {
      card = FeedCard(
        post: (item as _PostItem).post,
        isCenter: isFront,
      );
    }

    return Opacity(
      opacity: opacity,
      child: Transform(
        transform: matrix,
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width:  _kCardW,
            height: _kCardH,
            child: card,
          ),
        ),
      ),
    );
  }
}
