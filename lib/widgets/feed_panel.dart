// lib/widgets/feed_panel.dart
// 3D Cylinder Carousel — Matrix4 orbit, cinematic depth

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
const double _kRadius      = 620.0;  // cylinder radius — larger = more spread
const double _kPerspective = 0.0010; // 1/focal = smaller number = more cinematic
const double _kTiltX      = -0.18;  // radians — tilt ring toward viewer (top-down)
const double _kCardW       = 200.0;
const double _kCardH       = 260.0;
const int    _kVisible     = 10;     // render cards on each side of current
const double _kAngleStep   = (2 * math.pi) / 14; // 14 slots in full ring

// ── FEED PANEL ────────────────────────────────────────────────
class FeedPanel extends StatefulWidget {
  final void Function(bool scrollingDown)? onScrollDirection;
  const FeedPanel({Key? key, this.onScrollDirection}) : super(key: key);

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel>
    with SingleTickerProviderStateMixin {

  // ── ORBIT STATE ───────────────────────────────────────────
  double _angle       = 0.0;  // current orbit angle in radians
  double _velocity    = 0.0;  // angular velocity rad/frame
  bool   _dragging    = false;
  double _lastX       = 0;
  double _lastTime    = 0;

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
    // Ticker runs every frame for smooth auto-rotation + momentum decay
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
        // Auto rotate
        _angle += 0.003;
        // Momentum decay
        _angle    += _velocity;
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
    final now = DateTime.now().millisecondsSinceEpoch.toDouble();
    final dx  = d.globalPosition.dx - _lastX;
    final dt  = (now - _lastTime).clamp(1, 100);

    // Convert pixel drag to radians — negative so drag right = rotate right
    final dAngle = -dx * 0.006;
    _velocity = dAngle / dt * 16;

    setState(() => _angle += dAngle);

    _lastX    = d.globalPosition.dx;
    _lastTime = now;

    // Notify sidebar
    widget.onScrollDirection?.call(dx < 0);
  }

  void _onPanEnd(DragEndDetails d) {
    _dragging = false;
  }

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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart:  _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd:    _onPanEnd,
      child: LayoutBuilder(
        builder: (ctx, box) {
          final double cx = box.maxWidth  / 2 - _kCardW / 2;
          final double cy = box.maxHeight / 2 - _kCardH / 2;

          // Sort cards by Z depth (back to front) for correct painter's order
          final List<Map<String, dynamic>> slots = [];
          for (int i = -_kVisible; i <= _kVisible; i++) {
            final int dataIdx = ((i) % _items.length + _items.length) % _items.length;
            final double cardAngle = _angle + i * _kAngleStep;
            final double sinA = math.sin(cardAngle);
            final double cosA = math.cos(cardAngle);

            // 3D position on cylinder
            final double x3d = sinA * _kRadius;
            final double z3d = cosA * _kRadius;

            // Apply tiltX — rotate around X axis
            final double y3d = -z3d * math.sin(_kTiltX);
            final double z3dT = z3d * math.cos(_kTiltX);

            // Perspective projection
            final double scale = 1.0 / (1.0 + _kPerspective * (-z3dT));

            // Projected 2D position
            final double px = cx + x3d * scale;
            final double py = cy + y3d * scale;

            // Opacity — fade cards that are behind
            final double normalizedZ = (z3dT + _kRadius) / (2 * _kRadius);
            final double opacity = (0.2 + normalizedZ * 0.8).clamp(0.0, 1.0);

            slots.add({
              'i':       i,
              'dataIdx': dataIdx,
              'px':      px,
              'py':      py,
              'scale':   scale,
              'opacity': opacity,
              'z3d':     z3dT,
              'front':   i == 0,
            });
          }

          // Sort: back cards first (painter's algorithm)
          slots.sort((a, b) => (a['z3d'] as double).compareTo(b['z3d'] as double));

          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (final s in slots)
                _buildSlot(ctx, s, daily),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSlot(
    BuildContext ctx,
    Map<String, dynamic> s,
    DailyContentProvider daily,
  ) {
    final int    dataIdx = s['dataIdx'] as int;
    final double px      = s['px']      as double;
    final double py      = s['py']      as double;
    final double scale   = s['scale']   as double;
    final double opacity = s['opacity'] as double;
    final bool   isFront = s['front']   as bool;

    // Skip nearly invisible cards
    if (opacity < 0.08) return const SizedBox.shrink();

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

    return Positioned(
      left: px,
      top:  py,
      width:  _kCardW,
      height: _kCardH,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: card,
          ),
        ),
      ),
    );
  }
}
