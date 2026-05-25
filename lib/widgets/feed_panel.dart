// lib/widgets/feed_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';
import 'feed_card.dart';
import 'daily_card.dart';

// ── ITEM MODELS ───────────────────────────────────────────────
abstract class _FeedItem {}

class _PostItem extends _FeedItem {
  final PostModel post;
  _PostItem(this.post);
}

class _HadithItem extends _FeedItem {
  final HadithToday hadith;
  _HadithItem(this.hadith);
}

class _AmalanItem extends _FeedItem {
  final AmalanToday amalan;
  final int index;
  _AmalanItem(this.amalan, this.index);
}

class _SirahItem extends _FeedItem {
  final SirahToday sirah;
  _SirahItem(this.sirah);
}

// ── FEED PANEL ────────────────────────────────────────────────
class FeedPanel extends StatefulWidget {
  final void Function(bool scrollingDown)? onScrollDirection;
  const FeedPanel({Key? key, this.onScrollDirection}) : super(key: key);

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel>
    with SingleTickerProviderStateMixin {

  int _current = 0;
  List<_FeedItem> _items = [];
  bool _itemsCached = false;

  // Drag state
  double _dragStartY = 0;
  double _dragDy = 0;
  bool _dragging = false;

  // Animation
  late AnimationController _animCtrl;
  late Animation<double> _anim;
  double _animFrom = 0;
  double _animTo   = 0;
  double _liveOffset = 0; // px offset dari posisi snap

  // Peek amount — how much of next/prev card shows
  static const double kPeek = 60.0;

  static const List<PostModel> _posts = [
    PostModel(id: '101', type: 'video',   title: 'Kisah Hijrah Rasulullah ﷺ',        content: 'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda dari ancaman kaum Quraisy.',        author: 'Ustaz Don',       authorAge: '40', likes: 1240, time: '2j',  assetPath: 'assets/images/dummy_post1.jpg'),
    PostModel(id: '102', type: 'quote',   title: 'Kata Hikmah',                       content: 'Jangan bersedih, sesungguhnya Allah bersama kita. (At-Taubah: 40)',                                    author: "Imam Syafi'i",    authorAge: '',   likes: 850,  time: '5j'),
    PostModel(id: '103', type: 'article', title: 'Kelebihan Selawat',                 content: 'Barangsiapa berselawat ke atasku sekali, Allah balas sepuluh kali ganda rahmat kepadanya.',            author: 'Habib Ali',       authorAge: '52', likes: 2100, time: '1h',  assetPath: 'assets/images/dummy_post2.jpg'),
    PostModel(id: '104', type: 'event',   title: 'Majlis Ilmu Perdana',               content: 'Jom sertai kami di Masjid Negeri untuk kupasan kitab Sirah Nabawiyah bersama ulama.',                  author: 'Admin iHijrah',   authorAge: '',   likes: 500,  time: '10j'),
    PostModel(id: '105', type: 'quote',   title: 'Pesan Imam Malik',                  content: 'Ilmu itu bukan pada apa yang dihafal, tetapi pada apa yang memberi manfaat kepada hati.',              author: 'Imam Malik',      authorAge: '',   likes: 3200, time: '12j'),
    PostModel(id: '106', type: 'video',   title: 'Tajwid Asas: Al-Fatihah',           content: 'Mari perbaiki bacaan Al-Fatihah kita. Setiap huruf ada makhrajnya yang tersendiri.',                  author: 'Ustaz Azhar',     authorAge: '60', likes: 890,  time: '1h'),
    PostModel(id: '107', type: 'article', title: 'Rahsia Dhuha & Pintu Rezeki',       content: 'Konsistensi solat Dhuha membuka pintu rezeki yang tidak disangka-sangka oleh manusia biasa.',         author: 'Ustaz Wadi',      authorAge: '45', likes: 4500, time: '30m', assetPath: 'assets/images/dummy_post1.jpg'),
    PostModel(id: '108', type: 'quote',   title: 'Nasihat Imam Ghazali',              content: 'Ilmu tanpa amal itu gila, amal tanpa ilmu itu sia-sia. Carilah keduanya bersama.',                    author: 'Imam Ghazali',    authorAge: '',   likes: 5100, time: '2h'),
    PostModel(id: '109', type: 'article', title: 'Keutamaan Surah Al-Mulk',           content: 'Sesiapa yang membaca Al-Mulk setiap malam, ia akan dilindungi dari azab kubur.',                      author: 'Ustazah Noor',    authorAge: '38', likes: 1870, time: '3h',  assetPath: 'assets/images/dummy_post2.jpg'),
    PostModel(id: '110', type: 'event',   title: 'Kem Tahfiz Ramadan 1446H',          content: 'Daftar sekarang! Kem intensif hafazan Al-Quran 10 hari untuk semua peringkat umur.',                  author: 'Markaz Quran KL', authorAge: '',   likes: 720,  time: '4h'),
    PostModel(id: '111', type: 'video',   title: 'Doa Pagi yang Mujarab',             content: 'Amalkan 7 doa ini setiap pagi. Nabi ﷺ sendiri mengajarkan kepada para sahabat baginda.',             author: 'Dr Rozaimi',      authorAge: '47', likes: 3300, time: '5h',  assetPath: 'assets/images/dummy_post1.jpg'),
    PostModel(id: '112', type: 'quote',   title: 'Kata Ibn Qayyim',                   content: 'Hati yang kosong dari zikir adalah hati yang mati walaupun pemiliknya masih bernyawa.',               author: 'Ibn Qayyim',      authorAge: '',   likes: 6200, time: '6h'),
    PostModel(id: '115', type: 'video',   title: 'Tafsir Surah Al-Kahfi Ayat 1-10',  content: 'Perlindungan dari fitnah Dajjal bermula dengan memahami 10 ayat pertama surah ini sepenuhnya.',      author: 'Ust Fathul Bari', authorAge: '50', likes: 7800, time: '9h',  assetPath: 'assets/images/dummy_post1.jpg'),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  List<_FeedItem> _buildItems(DailyContentProvider daily) {
    final List<_FeedItem> items = [];
    if (daily.todayHadith != null) items.add(_HadithItem(daily.todayHadith!));
    for (int i = 0; i < daily.todayAmalanList.length && i < 3; i++) {
      items.add(_AmalanItem(daily.todayAmalanList[i], i));
    }
    if (daily.todaySirah != null) items.add(_SirahItem(daily.todaySirah!));
    for (final p in _posts) items.add(_PostItem(p));
    return items;
  }

  void _snapTo(int target) {
    final int clamped = target.clamp(0, _items.length - 1);
    final double from = _liveOffset;
    final double to   = 0;

    _current = clamped;
    _liveOffset = from; // start anim from current drag offset

    _anim = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic),
    )..addListener(() {
      setState(() => _liveOffset = _anim.value);
    });

    _animCtrl.forward(from: 0);
  }

  void _onDragStart(DragStartDetails d) {
    _animCtrl.stop();
    _dragging = true;
    _dragStartY = d.globalPosition.dy;
    _dragDy = 0;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (!_dragging) return;
    _dragDy = d.globalPosition.dy - _dragStartY;

    // Notify sidebar
    if (_dragDy.abs() > 10) {
      widget.onScrollDirection?.call(_dragDy < 0); // true = scroll down
    }

    // Resistance at ends
    double dy = _dragDy;
    if ((_current == 0 && dy > 0) ||
        (_current == _items.length - 1 && dy < 0)) {
      dy *= 0.18;
    }

    setState(() => _liveOffset = dy);
  }

  void _onDragEnd(DragEndDetails d) {
    if (!_dragging) return;
    _dragging = false;

    final double velocity = d.primaryVelocity ?? 0;
    final double threshold = 55.0;

    if (_dragDy < -threshold || velocity < -400) {
      _snapTo(_current + 1);
    } else if (_dragDy > threshold || velocity > 400) {
      _snapTo(_current - 1);
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

    if (!_itemsCached) {
      _items = _buildItems(daily);
      _itemsCached = true;
    }

    return GestureDetector(
      onVerticalDragStart: _onDragStart,
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double h = constraints.maxHeight;
          final double w = constraints.maxWidth;

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Render stack: slot+3 dulu (bawah), slot-1 last (atas)
              // Flutter Stack: last child = paling atas
              for (int i = _current + 3; i >= _current - 1; i--)
                if (i >= 0 && i < _items.length)
                  _buildCardSlot(context, i, h, w, daily),

              // Dots — right side
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildDots(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCardSlot(
    BuildContext context,
    int index,
    double h,
    double w,
    DailyContentProvider daily,
  ) {
    // ── KAD SEGI EMPAT SAMA ──────────────────────────────
    // Lebar = w - margin 28px kiri kanan
    final double cardW = w - 28;
    final double cardH = cardW; // 1:1 ratio — jangan ubah

    // Pusat kad di tengah panel secara menegak
    final double centerTop = (h - cardH) / 2;

    final int slot = index - _current; // -1 = prev, 0 = front, 1+ = belakang

    // ── POKER STACK OFFSET ────────────────────────────────
    // Kad belakang tersembul sikit dari bawah seperti kad poker
    const double stackOffsetY  = 22.0; // jarak antara kad
    const double scaleStep     = 0.032;

    final double baseOffsetY = slot * stackOffsetY;
    final double baseScale   = 1.0 - slot.abs() * scaleStep;
    final double baseOpacity = slot == 0 ? 1.0
        : slot == 1 ? 0.80
        : slot == 2 ? 0.50
        : slot == 3 ? 0.25
        : 0.0;

    // Drag: kad depan bergerak penuh, kad belakang bergerak kurang
    final double dragFactor = slot == 0 ? 1.0
        : slot == -1 ? 0.5
        : 0.25;
    final double dragY = _liveOffset * dragFactor;

    final double finalY = baseOffsetY + dragY;

    // Kad yang dah lepas (slot < 0) — keluar atas
    if (slot < -1) return const SizedBox.shrink();
    if (slot > 3)  return const SizedBox.shrink();

    // Z-order: slot 0 paling depan
    final int zIndex = 10 - slot.abs();

    Widget card = _buildCard(context, index, daily);

    // Dim kad belakang
    if (slot != 0) {
      card = Opacity(
        opacity: baseOpacity.clamp(0.0, 1.0),
        child: card,
      );
    }

    card = ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: card,
    );

    return Positioned(
      left: 14,
      width: cardW,
      top: centerTop,
      height: cardH,
      child: Transform.translate(
        offset: Offset(0, finalY),
        child: Transform.scale(
          scale: baseScale.clamp(0.5, 1.0),
          alignment: Alignment.topCenter,
          child: card,
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    int index,
    DailyContentProvider daily,
  ) {
    final item = _items[index];
    final bool isCenter = index == _current;

    if (item is _HadithItem) {
      return DailyHadithCard(hadith: item.hadith, isCenter: isCenter);
    }
    if (item is _AmalanItem) {
      return DailyAmalanCard(
        amalan: item.amalan,
        isCenter: isCenter,
        onToggle: () => daily.toggleAmalan(item.amalan.id),
      );
    }
    if (item is _SirahItem) {
      return DailySirahCard(sirah: item.sirah, isCenter: isCenter);
    }
    final post = (item as _PostItem).post;
    return FeedCard(post: post, isCenter: isCenter);
  }

  Widget _buildDots() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        _items.length.clamp(0, 12),
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 2.5),
          width: 4,
          height: i == _current ? 14 : 4,
          decoration: BoxDecoration(
            color: i == _current
                ? kPrimaryGold
                : Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
