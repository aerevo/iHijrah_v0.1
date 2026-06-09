// lib/widgets/feed_panel.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';
import 'feed_card.dart';
import 'daily_card.dart';

// ── ITEM MODELS ───────────────────────────────────────────────
abstract class _FeedItem {}
class _PostItem   extends _FeedItem { final PostModel post;     _PostItem(this.post); }
class _HadithItem extends _FeedItem { final HadithToday hadith; _HadithItem(this.hadith); }
class _AmalanItem extends _FeedItem { final AmalanToday amalan; final int idx; _AmalanItem(this.amalan, this.idx); }
class _SirahItem  extends _FeedItem { final SirahToday sirah;   _SirahItem(this.sirah); }

// ── CONSTANTS ─────────────────────────────────────────────────
const double _kSwipeLimit  = 80.0;   // jarak swipe untuk dismiss
const double _kStackOffset = 18.0;   // jarak Y antara lapisan
const double _kStackScale  = 0.045;  // pengurangan saiz setiap lapisan
const double _kStackAngle  = 0.04;   // condong kad belakang (radian ~2.3°)
const int    _kVisible     = 4;      // bilangan kad nampak

class FeedPanel extends StatefulWidget {
  final void Function(bool scrollingDown)? onScrollDirection;
  const FeedPanel({Key? key, this.onScrollDirection}) : super(key: key);

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel>
    with TickerProviderStateMixin {

  int    _topIndex  = 0;
  Offset _drag      = Offset.zero;
  bool   _dragging  = false;

  late final AnimationController _dismissCtrl;
  late final AnimationController _promoteCtrl;
  late final AnimationController _snapCtrl;
  late Animation<Offset>         _dismissAnim;
  late Animation<Offset>         _snapAnim;
  bool _dismissing = false;
  bool _snapping   = false;

  List<_FeedItem> _items  = [];
  bool            _cached = false;

  static const List<PostModel> _posts = [
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

  @override
  void initState() {
    super.initState();

    _dismissCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 320),
    )..addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() {
          _topIndex  = (_topIndex + 1) % _items.length;
          _drag      = Offset.zero;
          _dismissing = false;
        });
        _dismissCtrl.reset();
        _promoteCtrl.reset();
      }
    });

    _promoteCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300),
    );

    _snapCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420),
    )..addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() { _drag = Offset.zero; _snapping = false; });
        _snapCtrl.reset();
      }
    });
  }

  @override
  void dispose() {
    _dismissCtrl.dispose();
    _promoteCtrl.dispose();
    _snapCtrl.dispose();
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

  // ── GESTURE ───────────────────────────────────────────────
  void _onPanStart(DragStartDetails d) {
    if (_dismissing || _snapping) return;
    _dragging = true;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!_dragging || _dismissing || _snapping) return;
    setState(() => _drag += d.delta);

    // Sidebar callback
    if (d.delta.dy.abs() > 2) {
      widget.onScrollDirection?.call(d.delta.dy < 0);
    }
  }

  void _onPanEnd(DragEndDetails d) {
    if (!_dragging || _dismissing || _snapping) return;
    _dragging = false;

    final vx = d.velocity.pixelsPerSecond.dx;
    final vy = d.velocity.pixelsPerSecond.dy;

    // Dismiss: swipe atas ATAU kiri/kanan kuat
    final bool shouldDismiss = _drag.dy < -_kSwipeLimit || vy < -500 ||
        _drag.dx.abs() > _kSwipeLimit * 1.5 || vx.abs() > 700;

    if (shouldDismiss) {
      // Terbang ke arah swipe
      Offset target;
      if (_drag.dx.abs() > _drag.dy.abs()) {
        target = Offset(_drag.dx > 0 ? 600 : -600, _drag.dy * 0.5);
      } else {
        target = Offset(_drag.dx * 0.3, -700);
      }

      _dismissAnim = Tween<Offset>(begin: _drag, end: target)
          .animate(CurvedAnimation(
              parent: _dismissCtrl, curve: Curves.easeOut));

      setState(() => _dismissing = true);
      _dismissCtrl.forward();
      _promoteCtrl.forward(from: 0);
    } else {
      _snapAnim = Tween<Offset>(begin: _drag, end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _snapCtrl, curve: Curves.elasticOut));
      setState(() => _snapping = true);
      _snapCtrl.forward();
    }
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

    if (!_cached) { _items = _buildItems(daily); _cached = true; }
    if (_items.isEmpty) return const SizedBox.shrink();

    final int    total   = _items.length;
    final double cardH   = MediaQuery.of(context).size.height * 0.58;
    final double cardW   = MediaQuery.of(context).size.width - 32;

    return Stack(
      alignment: Alignment.center,
      children: [

        // ── STACK KAD ──────────────────────────────────────
        Center(
          child: SizedBox(
            width: cardW,
            height: cardH + _kStackOffset * (_kVisible - 1) + 24,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                for (int layer = _kVisible - 1; layer >= 0; layer--)
                  _buildLayer(layer, total, daily, cardH, cardW),
              ],
            ),
          ),
        ),

        // ── COUNTER ────────────────────────────────────────
        Positioned(
          top: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBorderSubtle),
            ),
            child: Text(
              '${_topIndex + 1} / $total',
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        // ── SWIPE HINT ─────────────────────────────────────
        Positioned(
          bottom: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swipe, color: kTextMuted.withOpacity(0.5), size: 14),
              const SizedBox(width: 4),
              Text(
                'Swipe untuk teruskan',
                style: TextStyle(
                  color: kTextMuted.withOpacity(0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLayer(int layer, int total, DailyContentProvider daily,
      double cardH, double cardW) {
    final int    dataIdx     = (_topIndex + layer) % total;
    final bool   isTop       = layer == 0;
    final double baseY       = layer * _kStackOffset;
    final double baseScale   = 1.0 - layer * _kStackScale;
    final double baseAngle   = layer == 0 ? 0.0
        : (layer.isOdd ? _kStackAngle : -_kStackAngle);
    final double baseOpacity =
        (1.0 - layer * 0.18).clamp(0.45, 1.0);

    return AnimatedBuilder(
      animation: Listenable.merge(
          [_dismissCtrl, _promoteCtrl, _snapCtrl]),
      builder: (_, child) {
        Offset offset  = Offset(0, baseY);
        double angle   = baseAngle;
        double scale   = baseScale;
        double opacity = baseOpacity;

        if (isTop) {
          final Offset cur = _dismissing
              ? _dismissAnim.value
              : _snapping
                  ? _snapAnim.value
                  : _drag;
          offset = cur;
          angle  = cur.dx / 600.0;
          final double prog = _drag.dy < 0
              ? (-_drag.dy / _kSwipeLimit).clamp(0.0, 1.0)
              : 0.0;
          final double xProg = (_drag.dx.abs() /
                  (_kSwipeLimit * 1.5))
              .clamp(0.0, 1.0);
          opacity = (1.0 - (prog * 0.35 + xProg * 0.2))
              .clamp(0.55, 1.0);
        } else {
          final double t = _dismissing
              ? _promoteCtrl.value
              : _snapping
                  ? 0.0
                  : (_drag.dy < 0
                      ? (-_drag.dy / _kSwipeLimit).clamp(0.0, 1.0)
                      : (_drag.dx.abs() / (_kSwipeLimit * 1.5))
                          .clamp(0.0, 1.0));
          final int    pl    = layer - 1;
          final double tgtY  = pl * _kStackOffset;
          final double tgtSc = 1.0 - pl * _kStackScale;
          final double tgtOp = (1.0 - pl * 0.18).clamp(0.45, 1.0);
          offset  = Offset(0, baseY + (tgtY  - baseY ) * t);
          scale   = baseScale  + (tgtSc  - baseScale  ) * t;
          opacity = baseOpacity + (tgtOp  - baseOpacity) * t;
        }

        return Transform.translate(
          offset: offset,
          child: Transform.rotate(
            angle: angle,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topCenter,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: child,
              ),
            ),
          ),
        );
      },
      child: SizedBox(
        width:  cardW,
        height: cardH,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusXl),
          child: isTop
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart:  _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd:    _onPanEnd,
                  child: _cardContent(dataIdx, true, daily),
                )
              : _cardContent(dataIdx, false, daily),
        ),
      ),
    );
  }

  Widget _cardContent(int idx, bool isTop, DailyContentProvider daily) {
    final item = _items[idx];
    if (item is _HadithItem) {
      return DailyHadithCard(hadith: item.hadith, isCenter: isTop);
    }
    if (item is _AmalanItem) {
      return DailyAmalanCard(
        amalan: item.amalan, isCenter: isTop,
        onToggle: () => daily.toggleAmalan(item.amalan.id),
      );
    }
    if (item is _SirahItem) {
      return DailySirahCard(sirah: item.sirah, isCenter: isTop);
    }
    return FeedCard(post: (item as _PostItem).post, isCenter: isTop);
  }
}
