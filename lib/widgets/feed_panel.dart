// lib/widgets/feed_panel.dart
// Netflix-style card stack — full width, drag follows finger, spring snap

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

// ── FEED PANEL ────────────────────────────────────────────────
class FeedPanel extends StatefulWidget {
  final void Function(bool scrollingDown)? onScrollDirection;
  const FeedPanel({Key? key, this.onScrollDirection}) : super(key: key);
  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel>
    with SingleTickerProviderStateMixin {

  int    _current     = 0;
  double _dragOffset  = 0; // live drag offset in px
  bool   _dragging    = false;
  double _startY      = 0;

  late AnimationController _spring;
  late Animation<double>   _springAnim;

  List<_FeedItem> _items     = [];
  bool            _cached    = false;

  // Peek — how many px of next/prev card peeks from bottom
  static const double _peek = 52.0;

  static const List<PostModel> _posts = [
    PostModel(id:'101',type:'video',  title:'Kisah Hijrah Rasulullah ﷺ',       content:'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda dari ancaman Quraisy.',      author:'Ustaz Don',      authorAge:'40',likes:1240,time:'2j', assetPath:'assets/images/dummy_post1.jpg'),
    PostModel(id:'102',type:'quote',  title:'Kata Hikmah',                      content:'Jangan bersedih, sesungguhnya Allah bersama kita. (At-Taubah: 40)',                            author:"Imam Syafi'i",   authorAge:'',  likes:850, time:'5j'),
    PostModel(id:'103',type:'article',title:'Kelebihan Selawat',                content:'Barangsiapa berselawat ke atasku sekali, Allah balas sepuluh kali ganda rahmat kepadanya.',   author:'Habib Ali',      authorAge:'52',likes:2100,time:'1h', assetPath:'assets/images/dummy_post2.jpg'),
    PostModel(id:'104',type:'event',  title:'Majlis Ilmu Perdana',              content:'Jom sertai kami di Masjid Negeri untuk kupasan kitab Sirah Nabawiyah bersama ulama.',         author:'Admin iHijrah',  authorAge:'',  likes:500, time:'10j'),
    PostModel(id:'105',type:'quote',  title:'Pesan Imam Malik',                 content:'Ilmu itu bukan pada apa yang dihafal, tetapi pada apa yang memberi manfaat kepada hati.',     author:'Imam Malik',     authorAge:'',  likes:3200,time:'12j'),
    PostModel(id:'106',type:'video',  title:'Tajwid Asas: Al-Fatihah',          content:'Mari perbaiki bacaan Al-Fatihah kita. Setiap huruf ada makhrajnya yang tersendiri.',         author:'Ustaz Azhar',    authorAge:'60',likes:890, time:'1h'),
    PostModel(id:'107',type:'article',title:'Rahsia Dhuha & Pintu Rezeki',      content:'Konsistensi solat Dhuha membuka pintu rezeki yang tidak disangka-sangka.',                   author:'Ustaz Wadi',     authorAge:'45',likes:4500,time:'30m',assetPath:'assets/images/dummy_post1.jpg'),
    PostModel(id:'108',type:'quote',  title:'Nasihat Imam Ghazali',             content:'Ilmu tanpa amal itu gila, amal tanpa ilmu itu sia-sia. Carilah keduanya bersama.',           author:'Imam Ghazali',   authorAge:'',  likes:5100,time:'2h'),
    PostModel(id:'109',type:'article',title:'Keutamaan Surah Al-Mulk',          content:'Sesiapa yang membaca Al-Mulk setiap malam, ia akan dilindungi dari azab kubur.',             author:'Ustazah Noor',   authorAge:'38',likes:1870,time:'3h', assetPath:'assets/images/dummy_post2.jpg'),
    PostModel(id:'110',type:'event',  title:'Kem Tahfiz Ramadan 1446H',         content:'Daftar sekarang! Kem intensif hafazan Al-Quran 10 hari untuk semua peringkat umur.',         author:'Markaz Quran KL',authorAge:'',  likes:720, time:'4h'),
    PostModel(id:'111',type:'video',  title:'Doa Pagi yang Mujarab',            content:'Amalkan 7 doa ini setiap pagi. Nabi ﷺ sendiri mengajarkan kepada para sahabat baginda.',    author:'Dr Rozaimi',     authorAge:'47',likes:3300,time:'5h', assetPath:'assets/images/dummy_post1.jpg'),
    PostModel(id:'112',type:'quote',  title:'Kata Ibn Qayyim',                  content:'Hati yang kosong dari zikir adalah hati yang mati walaupun pemiliknya masih bernyawa.',      author:'Ibn Qayyim',     authorAge:'',  likes:6200,time:'6h'),
    PostModel(id:'115',type:'video',  title:'Tafsir Surah Al-Kahfi Ayat 1-10', content:'Perlindungan dari fitnah Dajjal bermula dengan memahami 10 ayat pertama surah ini.',         author:'Ust Fathul Bari',authorAge:'50',likes:7800,time:'9h', assetPath:'assets/images/dummy_post1.jpg'),
  ];

  @override
  void initState() {
    super.initState();
    _spring = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void dispose() {
    _spring.dispose();
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

  // ── SNAP with spring physics ──────────────────────────────
  void _snapTo(int target, {double velocity = 0}) {
    final int idx = target.clamp(0, _items.length - 1);
    _current = idx;

    // Spring from current dragOffset back to 0
    final from = _dragOffset;
    _springAnim = Tween<double>(begin: from, end: 0.0).animate(
      CurvedAnimation(
        parent: _spring,
        curve: velocity.abs() > 800
            ? Curves.easeOutBack
            : Curves.easeOutCubic,
      ),
    )..addListener(() {
      setState(() => _dragOffset = _springAnim.value);
    });
    _spring.forward(from: 0);
  }

  // ── GESTURE ───────────────────────────────────────────────
  void _onPanStart(DragStartDetails d) {
    _spring.stop();
    _dragging = true;
    _startY   = d.globalPosition.dy;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!_dragging) return;
    double dy = d.globalPosition.dy - _startY;

    // Rubber band at ends
    if ((_current == 0 && dy > 0) ||
        (_current == _items.length - 1 && dy < 0)) {
      dy *= 0.15;
    }

    // Notify sidebar
    if (dy.abs() > 8) {
      widget.onScrollDirection?.call(dy < 0);
    }

    setState(() => _dragOffset = dy);
  }

  void _onPanEnd(DragEndDetails d) {
    if (!_dragging) return;
    _dragging = false;

    final vel = d.primaryVelocity ?? 0;
    if (_dragOffset < -60 || vel < -500) {
      _snapTo(_current + 1, velocity: vel);
    } else if (_dragOffset > 60 || vel > 500) {
      _snapTo(_current - 1, velocity: vel);
    } else {
      _snapTo(_current);
    }
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
          final double h = box.maxHeight;
          final double w = box.maxWidth;

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Render: 1 prev + current + 3 next (back to front)
              for (int i = (_current + 3).clamp(0, _items.length - 1);
                   i >= (_current - 1).clamp(0, _items.length - 1);
                   i--)
                _cardSlot(ctx, i, h, w, daily),

              // Dots indicator — right side
              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(child: _dots()),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── CARD SLOT ─────────────────────────────────────────────
  Widget _cardSlot(
    BuildContext ctx,
    int index,
    double h,
    double w,
    DailyContentProvider daily,
  ) {
    final int slot = index - _current; // -1=prev, 0=front, 1,2,3=back

    // Full width — no margin
    // Card height = h - peek (so next card peeks from bottom)
    final double cardH = h - _peek;

    // Y positions:
    // slot 0 → top = 0 (fill top, peek shows at bottom)
    // slot 1 → top = cardH - peekStep*0 (just below front)
    // slot 2 → top = cardH + peekStep*1
    // slot -1 → top = -cardH (off top)
    const double peekStep = 14.0; // each stacked card shows 14px more

    double baseTop;
    if (slot == 0) {
      baseTop = 0;
    } else if (slot > 0) {
      baseTop = cardH + (slot - 1) * peekStep;
    } else {
      baseTop = -cardH; // off screen top
    }

    // Drag: front card moves with finger, back cards move proportionally
    double dragY;
    if (slot == 0) {
      dragY = _dragOffset;
    } else if (slot == -1) {
      // Prev card comes down from top as we drag down
      dragY = _dragOffset * 0.7;
    } else {
      // Back cards inch up slightly as front drags up
      dragY = _dragOffset * (0.3 / slot);
    }

    final double top = baseTop + dragY;

    // Opacity: front=1, each layer slightly darker
    final double opacity = slot == 0  ? 1.0
        : slot == 1 ? 0.82
        : slot == 2 ? 0.60
        : slot == 3 ? 0.35
        : slot == -1 ? (1.0 + _dragOffset / cardH).clamp(0.0, 1.0)
        : 0.0;

    if (opacity <= 0) return const SizedBox.shrink();

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(slot == 0 ? 20 : 18),
      child: _buildCard(ctx, index, daily),
    );

    return Positioned(
      left: 0,
      right: 0,
      top: top,
      height: cardH,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: card,
      ),
    );
  }

  Widget _buildCard(BuildContext ctx, int i, DailyContentProvider d) {
    final item = _items[i];
    final bool front = i == _current;
    if (item is _HadithItem) return DailyHadithCard(hadith: item.hadith, isCenter: front);
    if (item is _AmalanItem) return DailyAmalanCard(amalan: item.amalan, isCenter: front, onToggle: () => d.toggleAmalan(item.amalan.id));
    if (item is _SirahItem)  return DailySirahCard(sirah: item.sirah, isCenter: front);
    return FeedCard(post: (item as _PostItem).post, isCenter: front);
  }

  Widget _dots() {
    final int total = _items.length.clamp(0, 15);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final bool on = i == _current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          margin: const EdgeInsets.symmetric(vertical: 2.5),
          width: 4,
          height: on ? 16 : 4,
          decoration: BoxDecoration(
            color: on ? kPrimaryGold : Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
