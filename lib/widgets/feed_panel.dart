// lib/widgets/feed_panel.dart
// TRUE 3D CYLINDER FEED PANEL
// YouTube / Vision Pro style cinematic orbit carousel

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';

import 'feed_card.dart';
import 'daily_card.dart';

// ─────────────────────────────────────────────────────────────
// ITEM MODELS
// ─────────────────────────────────────────────────────────────

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
  final int idx;
  _AmalanItem(this.amalan, this.idx);
}

class _SirahItem extends _FeedItem {
  final SirahToday sirah;
  _SirahItem(this.sirah);
}

// ─────────────────────────────────────────────────────────────
// FEED PANEL
// ─────────────────────────────────────────────────────────────

class FeedPanel extends StatefulWidget {
  final void Function(bool scrollingDown)? onScrollDirection;

  const FeedPanel({
    Key? key,
    this.onScrollDirection,
  }) : super(key: key);

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel>
    with SingleTickerProviderStateMixin {

  // ── CONFIG ────────────────────────────────────────────────

  static const double _cardWidthFactor = 0.74;

  static const double _radius = 760;

  static const double _verticalStep = 18;

  static const double _perspective = 0.00042;

  static const double _dragSensitivity = 0.0032;

  static const int _visibleCount = 10;

  // ── STATE ─────────────────────────────────────────────────

  double _scrollPosition = 0.0;

  double _startY = 0;

  bool _dragging = false;

  late AnimationController _controller;

  Animation<double>? _animation;

  List<_FeedItem> _items = [];

  bool _cached = false;

  // ─────────────────────────────────────────────────────────

  static const List<PostModel> _posts = [

    PostModel(
      id:'101',
      type:'video',
      title:'Kisah Hijrah Rasulullah ﷺ',
      content:'Detik cemas di Gua Thur. Bagaimana laba-laba menyelamatkan baginda dari ancaman Quraisy.',
      author:'Ustaz Don',
      authorAge:'40',
      likes:1240,
      time:'2j',
      assetPath:'assets/images/dummy_post1.jpg',
    ),

    PostModel(
      id:'102',
      type:'quote',
      title:'Kata Hikmah',
      content:'Jangan bersedih, sesungguhnya Allah bersama kita. (At-Taubah: 40)',
      author:"Imam Syafi'i",
      authorAge:'',
      likes:850,
      time:'5j',
    ),

    PostModel(
      id:'103',
      type:'article',
      title:'Kelebihan Selawat',
      content:'Barangsiapa berselawat ke atasku sekali, Allah balas sepuluh kali ganda rahmat kepadanya.',
      author:'Habib Ali',
      authorAge:'52',
      likes:2100,
      time:'1h',
      assetPath:'assets/images/dummy_post2.jpg',
    ),

    PostModel(
      id:'104',
      type:'event',
      title:'Majlis Ilmu Perdana',
      content:'Jom sertai kami di Masjid Negeri untuk kupasan kitab Sirah Nabawiyah bersama ulama.',
      author:'Admin iHijrah',
      authorAge:'',
      likes:500,
      time:'10j',
    ),

    PostModel(
      id:'105',
      type:'quote',
      title:'Pesan Imam Malik',
      content:'Ilmu itu bukan pada apa yang dihafal, tetapi pada apa yang memberi manfaat kepada hati.',
      author:'Imam Malik',
      authorAge:'',
      likes:3200,
      time:'12j',
    ),

    PostModel(
      id:'106',
      type:'video',
      title:'Tajwid Asas: Al-Fatihah',
      content:'Mari perbaiki bacaan Al-Fatihah kita. Setiap huruf ada makhrajnya yang tersendiri.',
      author:'Ustaz Azhar',
      authorAge:'60',
      likes:890,
      time:'1h',
    ),

    PostModel(
      id:'107',
      type:'article',
      title:'Rahsia Dhuha & Pintu Rezeki',
      content:'Konsistensi solat Dhuha membuka pintu rezeki yang tidak disangka-sangka.',
      author:'Ustaz Wadi',
      authorAge:'45',
      likes:4500,
      time:'30m',
      assetPath:'assets/images/dummy_post1.jpg',
    ),

    PostModel(
      id:'108',
      type:'quote',
      title:'Nasihat Imam Ghazali',
      content:'Ilmu tanpa amal itu gila, amal tanpa ilmu itu sia-sia. Carilah keduanya bersama.',
      author:'Imam Ghazali',
      authorAge:'',
      likes:5100,
      time:'2h',
    ),

    PostModel(
      id:'109',
      type:'article',
      title:'Keutamaan Surah Al-Mulk',
      content:'Sesiapa yang membaca Al-Mulk setiap malam, ia akan dilindungi dari azab kubur.',
      author:'Ustazah Noor',
      authorAge:'38',
      likes:1870,
      time:'3h',
      assetPath:'assets/images/dummy_post2.jpg',
    ),

    PostModel(
      id:'110',
      type:'event',
      title:'Kem Tahfiz Ramadan 1446H',
      content:'Daftar sekarang! Kem intensif hafazan Al-Quran 10 hari untuk semua peringkat umur.',
      author:'Markaz Quran KL',
      authorAge:'',
      likes:720,
      time:'4h',
    ),

    PostModel(
      id:'111',
      type:'video',
      title:'Doa Pagi yang Mujarab',
      content:'Amalkan 7 doa ini setiap pagi. Nabi ﷺ sendiri mengajarkan kepada para sahabat baginda.',
      author:'Dr Rozaimi',
      authorAge:'47',
      likes:3300,
      time:'5h',
      assetPath:'assets/images/dummy_post1.jpg',
    ),

    PostModel(
      id:'112',
      type:'quote',
      title:'Kata Ibn Qayyim',
      content:'Hati yang kosong dari zikir adalah hati yang mati walaupun pemiliknya masih bernyawa.',
      author:'Ibn Qayyim',
      authorAge:'',
      likes:6200,
      time:'6h',
    ),

    PostModel(
      id:'115',
      type:'video',
      title:'Tafsir Surah Al-Kahfi Ayat 1-10',
      content:'Perlindungan dari fitnah Dajjal bermula dengan memahami 10 ayat pertama surah ini.',
      author:'Ust Fathul Bari',
      authorAge:'50',
      likes:7800,
      time:'9h',
      assetPath:'assets/images/dummy_post1.jpg',
    ),
  ];

  // ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────

  List<_FeedItem> _buildItems(DailyContentProvider d) {

    final items = <_FeedItem>[];

    if (d.todayHadith != null) {
      items.add(_HadithItem(d.todayHadith!));
    }

    for (int i = 0; i < d.todayAmalanList.length && i < 3; i++) {
      items.add(_AmalanItem(d.todayAmalanList[i], i));
    }

    if (d.todaySirah != null) {
      items.add(_SirahItem(d.todaySirah!));
    }

    for (final p in _posts) {
      items.add(_PostItem(p));
    }

    return items;
  }

  // ─────────────────────────────────────────────────────────
  // GESTURE
  // ─────────────────────────────────────────────────────────

  void _onPanStart(DragStartDetails d) {

    _controller.stop();

    _dragging = true;

    _startY = d.globalPosition.dy;
  }

  void _onPanUpdate(DragUpdateDetails d) {

    if (!_dragging) return;

    final dy = d.globalPosition.dy - _startY;

    final delta = dy * _dragSensitivity;

    setState(() {
      _scrollPosition -= delta;
    });

    if (dy.abs() > 8) {
      widget.onScrollDirection?.call(dy < 0);
    }

    _startY = d.globalPosition.dy;
  }

  void _onPanEnd(DragEndDetails d) {

    _dragging = false;

    final target = _scrollPosition.roundToDouble();

    _animation = Tween<double>(
      begin: _scrollPosition,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutExpo,
      ),
    )
      ..addListener(() {
        setState(() {
          _scrollPosition = _animation!.value;
        });
      });

    _controller.forward(from: 0);
  }

  // ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {

    final daily = context.watch<DailyContentProvider>();

    if (daily.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryGold),
          strokeWidth: 1.4,
        ),
      );
    }

    if (!_cached) {
      _items = _buildItems(daily);
      _cached = true;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: LayoutBuilder(
        builder: (context, box) {

          final w = box.maxWidth;
          final h = box.maxHeight;

          final cardWidth = w * _cardWidthFactor;

          final cardHeight = cardWidth * 1.05;

          return Stack(
            clipBehavior: Clip.none,
            children: [

              // ── FLOOR GLOW ───────────────────────────────

              Positioned.fill(
                child: IgnorePointer(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: w * 1.2,
                      height: 260,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.07),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── CARDS ────────────────────────────────────

              ...List.generate(_items.length, (index) {

                final diff = index - _scrollPosition;

                if (diff.abs() > _visibleCount) {
                  return const SizedBox.shrink();
                }

                final angle = diff * 0.34;

                final rotate = angle;

                final z = math.cos(angle) * _radius;

                final y = math.sin(angle) * (_radius * 0.78);

                final scale =
                    0.58 +
                    ((z + _radius) / (_radius * 2)) * 0.42;

                final opacity =
                    (0.18 +
                    ((z + _radius) / (_radius * 2)) * 0.82)
                        .clamp(0.0, 1.0);

                final darkness =
                    (1.0 -
                    ((z + _radius) / (_radius * 2)))
                        .clamp(0.0, 0.72);

                final blur =
                    10 *
                    (1.0 -
                    ((z + _radius) / (_radius * 2)));

                final top =
                    (h / 2) -
                    (cardHeight / 2) +
                    y +
                    (diff * _verticalStep);

                return Positioned(
                  left: (w - cardWidth) / 2,
                  top: top,
                  width: cardWidth,
                  height: cardHeight,
                  child: IgnorePointer(
                    ignoring: diff.abs() > 0.7,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, _perspective)
                        ..translate(0.0, 0.0, z)
                        ..rotateX(rotate * -0.82),
                      child: Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [

                              // ── SHADOW ───────────────────

                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(34),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.55),
                                      blurRadius: 45,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 26),
                                    ),
                                  ],
                                ),
                              ),

                              // ── CARD ─────────────────────

                              ClipRRect(
                                borderRadius: BorderRadius.circular(34),
                                child: _buildCard(
                                  context,
                                  index,
                                  daily,
                                ),
                              ),

                              // ── DEPTH SHADE ──────────────

                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(34),
                                  color: Colors.black.withOpacity(darkness),
                                ),
                              ),

                              // ── ATMOSPHERIC FOG ──────────

                              if (blur > 0.5)
                                BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: blur,
                                    sigmaY: blur,
                                  ),
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // ── DOTS ────────────────────────────────────

              Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _dots(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────

  Widget _buildCard(
    BuildContext ctx,
    int i,
    DailyContentProvider d,
  ) {

    final item = _items[i];

    final bool front =
        (i - _scrollPosition).abs() < 0.5;

    if (item is _HadithItem) {
      return DailyHadithCard(
        hadith: item.hadith,
        isCenter: front,
      );
    }

    if (item is _AmalanItem) {
      return DailyAmalanCard(
        amalan: item.amalan,
        isCenter: front,
        onToggle: () => d.toggleAmalan(item.amalan.id),
      );
    }

    if (item is _SirahItem) {
      return DailySirahCard(
        sirah: item.sirah,
        isCenter: front,
      );
    }

    return FeedCard(
      post: (item as _PostItem).post,
      isCenter: front,
    );
  }

  // ─────────────────────────────────────────────────────────

  Widget _dots() {

    final current =
        _scrollPosition.round().clamp(0, _items.length - 1);

    final total = _items.length.clamp(0, 15);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {

        final bool on = i == current;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          margin: const EdgeInsets.symmetric(vertical: 2.5),
          width: 4,
          height: on ? 18 : 4,
          decoration: BoxDecoration(
            color: on
                ? kPrimaryGold
                : Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
