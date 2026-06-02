// lib/widgets/feed_panel.dart
// Apple Vision Pro — Stacked Deck, VERTICAL SWIPE
//
// Sidebar sekarang panel atas → swipe vertikal:
//   Swipe ATAS  (dy < 0) → dismiss kad, tunjuk kad seterusnya
//   Swipe BAWAH (dy > 0) → tunjuk sidebar, kad snap balik

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

// ── CONSTANTS ──────────────────────────────────────────────────
const double _kCardH       = 460.0;  // tinggi kad
const double _kSwipeLimit  = 100.0;  // jarak swipe atas untuk dismiss
const double _kStackOffset = 14.0;   // jarak vertikal antara kad dalam deck
const double _kStackScale  = 0.05;   // pengurangan saiz setiap lapisan
const double _kStackAngle  = 0.035;  // condong berganti kad belakang (radian ~2°)

// ── FEED PANEL ────────────────────────────────────────────────
class FeedPanel extends StatefulWidget {
  final void Function(bool scrollingDown)? onScrollDirection;
  const FeedPanel({Key? key, this.onScrollDirection}) : super(key: key);

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel> with TickerProviderStateMixin {

  int    _topIndex   = 0;
  Offset _drag       = Offset.zero;
  bool   _isDragging = false;

  late final AnimationController _dismissCtrl;
  late final AnimationController _promoteCtrl;
  late final AnimationController _snapCtrl;
  late Animation<Offset>         _dismissAnim;
  late Animation<Offset>         _snapAnim;
  bool   _dismissing = false;
  bool   _snapping   = false;

  bool            _cached = false;
  List<_FeedItem> _items  = [];

  static const List<PostModel> _posts = [
    PostModel(id:'101',type:'video',  title:'Kisah Hijrah Rasulullah ﷺ',       content:'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda.',                         author:'Ustaz Don',      authorAge:'40',likes:1240,time:'2j'),
    PostModel(id:'102',type:'quote',  title:'Kata Hikmah',                      content:'Jangan bersedih, sesungguhnya Allah bersama kita. (At-Taubah: 40)',                           author:"Imam Syafi'i",   authorAge:'',  likes:850, time:'5j'),
    PostModel(id:'103',type:'article',title:'Kelebihan Selawat',                content:'Barangsiapa berselawat ke atasku sekali, Allah balas sepuluh kali ganda.',                    author:'Habib Ali',      authorAge:'52',likes:2100,time:'1h'),
    PostModel(id:'104',type:'event',  title:'Majlis Ilmu Perdana',              content:'Jom sertai kami di Masjid Negeri untuk kupasan kitab Sirah Nabawiyah.',                       author:'Admin iHijrah',  authorAge:'',  likes:500, time:'10j'),
    PostModel(id:'105',type:'quote',  title:'Pesan Imam Malik',                 content:'Ilmu itu bukan pada apa yang dihafal, tetapi memberi manfaat kepada hati.',                  author:'Imam Malik',     authorAge:'',  likes:3200,time:'12j'),
    PostModel(id:'106',type:'video',  title:'Tajwid Asas: Al-Fatihah',          content:'Mari perbaiki bacaan Al-Fatihah kita. Setiap huruf ada makhrajnya.',                        author:'Ustaz Azhar',    authorAge:'60',likes:890, time:'1h'),
    PostModel(id:'107',type:'article',title:'Rahsia Dhuha & Pintu Rezeki',      content:'Konsistensi solat Dhuha membuka pintu rezeki yang tidak disangka-sangka.',                  author:'Ustaz Wadi',     authorAge:'45',likes:4500,time:'30m'),
    PostModel(id:'108',type:'quote',  title:'Nasihat Imam Ghazali',             content:'Ilmu tanpa amal itu gila, amal tanpa ilmu itu sia-sia.',                                     author:'Imam Ghazali',   authorAge:'',  likes:5100,time:'2h'),
    PostModel(id:'109',type:'article',title:'Keutamaan Surah Al-Mulk',          content:'Sesiapa yang membaca Al-Mulk setiap malam, dilindungi dari azab kubur.',                    author:'Ustazah Noor',   authorAge:'38',likes:1870,time:'3h'),
    PostModel(id:'110',type:'event',  title:'Kem Tahfiz Ramadan 1446H',         content:'Daftar sekarang! Kem intensif hafazan 10 hari untuk semua peringkat umur.',                  author:'Markaz Quran KL',authorAge:'',  likes:720, time:'4h'),
    PostModel(id:'111',type:'video',  title:'Doa Pagi yang Mujarab',            content:'Amalkan 7 doa ini setiap pagi. Nabi ﷺ mengajarkan kepada para sahabat.',                   author:'Dr Rozaimi',     authorAge:'47',likes:3300,time:'5h'),
    PostModel(id:'112',type:'quote',  title:'Kata Ibn Qayyim',                  content:'Hati yang kosong dari zikir adalah hati yang mati walaupun bernyawa.',                      author:'Ibn Qayyim',     authorAge:'',  likes:6200,time:'6h'),
    PostModel(id:'115',type:'video',  title:'Tafsir Surah Al-Kahfi Ayat 1-10', content:'Perlindungan dari fitnah Dajjal bermula dengan 10 ayat pertama surah ini.',                  author:'Ust Fathul Bari',authorAge:'50',likes:7800,time:'9h'),
  ];

  @override
  void initState() {
    super.initState();

    _dismissCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300),
    )..addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() {
          _topIndex   = (_topIndex + 1) % _items.length;
          _drag       = Offset.zero;
          _dismissing = false;
        });
        _dismissCtrl.reset();
      }
    });

    _promoteCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 280),
    );

    _snapCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400),
    )..addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() {
          _drag     = Offset.zero;
          _snapping = false;
        });
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

  // ── SWIPE LOGIC (VERTIKAL) ─────────────────────────────────
  void _onPanStart(DragStartDetails d) {
    if (_dismissing || _snapping) return;
    _isDragging = true;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!_isDragging || _dismissing || _snapping) return;
    setState(() => _drag += d.delta);

    // Beritahu home.dart arah swipe untuk sidebar
    if (d.delta.dy.abs() > 2) {
      // dy > 0 = swipe bawah = tunjuk sidebar (scrollingDown: false)
      // dy < 0 = swipe atas  = sembunyikan sidebar (scrollingDown: true)
      widget.onScrollDirection?.call(d.delta.dy < 0);
    }
  }

  void _onPanEnd(DragEndDetails d) {
    if (!_isDragging || _dismissing || _snapping) return;
    _isDragging = false;

    final vy = d.velocity.pixelsPerSecond.dy;
    // Dismiss hanya bila swipe ATAS (dy negatif) melebihi had
    final swipedUp = _drag.dy < -_kSwipeLimit || vy < -600;

    if (swipedUp) {
      // Kad terbang keluar ke atas
      _dismissAnim = Tween<Offset>(
        begin: _drag,
        end: Offset(_drag.dx * 0.3, -800),
      ).animate(CurvedAnimation(parent: _dismissCtrl, curve: Curves.easeOut));

      setState(() => _dismissing = true);
      _dismissCtrl.forward();
      _promoteCtrl.forward(from: 0);
    } else {
      // Snap balik — termasuk swipe bawah (sidebar gesture)
      _snapAnim = Tween<Offset>(
        begin: _drag,
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _snapCtrl, curve: Curves.elasticOut));

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

    const int visible = 3;
    final int total   = _items.length;

    return Center(
      child: SizedBox(
        height: _kCardH + _kStackOffset * (visible - 1) + 24,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            for (int layer = visible - 1; layer >= 0; layer--)
              _buildLayer(layer, total, daily),
          ],
        ),
      ),
    );
  }

  Widget _buildLayer(int layer, int total, DailyContentProvider daily) {
    final int    dataIdx     = (_topIndex + layer) % total;
    final bool   isTop       = layer == 0;
    final double baseY       = layer * _kStackOffset;
    final double baseScale   = 1.0 - layer * _kStackScale;
    final double baseAngle   = layer == 0 ? 0 : (layer.isOdd ? _kStackAngle : -_kStackAngle);
    final double baseOpacity = layer == 0 ? 1.0 : (1.0 - layer * 0.2).clamp(0.5, 1.0);

    return AnimatedBuilder(
      animation: Listenable.merge([_dismissCtrl, _promoteCtrl, _snapCtrl]),
      builder: (_, child) {
        Offset  offset  = Offset(0, baseY);
        double  angle   = baseAngle;
        double  scale   = baseScale;
        double  opacity = baseOpacity;

        if (isTop) {
          // Posisi semasa — dari drag, dismiss, atau snap
          final Offset cur = _dismissing
              ? _dismissAnim.value
              : _snapping
                  ? _snapAnim.value
                  : _drag;
          offset  = cur;
          // Sedikit tilt ikut drag mendatar
          angle   = cur.dx / 500.0;
          // Pudar bila swipe atas
          final double prog = (_drag.dy < 0
              ? (-_drag.dy / _kSwipeLimit).clamp(0.0, 1.0)
              : 0.0);
          opacity = (1.0 - prog * 0.3).clamp(0.7, 1.0);
        } else if (_dismissing || _snapping || _drag.dy.abs() > 10) {
          // Kad bawah spring ke hadapan semasa kad atas keluar
          final double t = _dismissing
              ? _promoteCtrl.value
              : _snapping
                  ? 0.0
                  : (_drag.dy < 0
                      ? (-_drag.dy / _kSwipeLimit).clamp(0.0, 1.0)
                      : 0.0);
          final int    pl     = layer - 1;
          final double tgtY   = pl * _kStackOffset;
          final double tgtSc  = 1.0 - pl * _kStackScale;
          final double tgtOp  = (1.0 - pl * 0.2).clamp(0.5, 1.0);
          offset  = Offset(0, baseY + (tgtY  - baseY ) * t);
          scale   = baseScale   + (tgtSc  - baseScale  ) * t;
          opacity = baseOpacity + (tgtOp  - baseOpacity) * t;
        }

        return Transform.translate(
          offset: offset,
          child: Transform.rotate(
            angle: angle,
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: child,
              ),
            ),
          ),
        );
      },
      child: isTop
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart:  _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd:    _onPanEnd,
              child: _buildCardContent(dataIdx, true, daily),
            )
          : _buildCardContent(dataIdx, false, daily),
    );
  }

  Widget _buildCardContent(int dataIdx, bool isFront, DailyContentProvider daily) {
    final item = _items[dataIdx];
    Widget card;
    if (item is _HadithItem) {
      card = DailyHadithCard(hadith: item.hadith, isCenter: isFront);
    } else if (item is _AmalanItem) {
      card = DailyAmalanCard(
        amalan: item.amalan, isCenter: isFront,
        onToggle: () => daily.toggleAmalan(item.amalan.id),
      );
    } else if (item is _SirahItem) {
      card = DailySirahCard(sirah: item.sirah, isCenter: isFront);
    } else {
      card = FeedCard(post: (item as _PostItem).post, isCenter: isFront);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(width: double.infinity, height: _kCardH, child: card),
    );
  }
}
