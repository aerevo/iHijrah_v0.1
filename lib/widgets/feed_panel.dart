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
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/sidebar_state_model.dart';
import '../providers/daily_content_provider.dart';
import '../theme/feed_theme.dart';
import 'feed_card.dart';
import 'daily_card.dart';
import 'anim_helpers.dart';

// ── ITEM MODELS ───────────────────────────────────────────────
abstract class _FeedItem {}
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
  bool            _cached     = false;

  // Stream disimpan (bukan dibuat semula tiap build) supaya rebuild
  // FeedPanel tak resubscribe & tak kosongkan post sebenar seketika.
  // Butang "Cuba lagi" buat stream baharu.
  Stream<QuerySnapshot> _postsStream = _openPostsStream();

  static Stream<QuerySnapshot> _openPostsStream() =>
      FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots();

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

            // ── KOMUNITI — post sebenar dari Firestore ──────────────
            // Post pengguna sebenar dipaparkan terkini di atas.
            // Jika tiada post, papar keadaan kosong yang jelas.
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
            StreamBuilder<QuerySnapshot>(
              stream: _postsStream,
              builder: (context, snapshot) {
                final List<PostModel> realPosts = snapshot.hasData
                    ? snapshot.data!.docs.map(_postFromDoc).toList()
                    : <PostModel>[];
                final List<PostModel> combined = realPosts;

                // Status stream: error / memuatkan dipaparkan sbg baris
                // di atas senarai.
                final bool hasError = snapshot.hasError;
                final bool isLoading = !hasError &&
                    !snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.waiting;
                final int offset = (hasError || isLoading) ? 1 : 0;
                if (hasError) {
                  debugPrint('FeedPanel: stream posts gagal: ${snapshot.error}');
                }

                if (!hasError && !isLoading && combined.isEmpty) {
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'Belum ada post komuniti lagi. Jadilah yang pertama berkongsi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: widget.palette.textMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  // ← FeedCard V6 kembali ke kad bersempadan gaya FB —
                  // perlukan margin sisi + jarak antara kad supaya latar
                  // nampak lalu celah-celah (bukan continuous-flow lagi).
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        if (offset == 1 && i == 0) {
                          return _feedStatus(snapshot.error);
                        }
                        final int idx = i - offset;
                        final post  = combined[idx];
                        final ratio = _imageAspectFor(post);
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: idx == combined.length - 1 ? 0 : 10),
                          child: FadeSlideIn(
                            index: idx,
                            child: FeedCard(post: post, imageAspectRatio: ratio),
                          ),
                        );
                      },
                      childCount: combined.length + offset,
                    ),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }

  // Baris status di atas senarai komuniti. error == null → sedang
  // memuatkan; selain itu → ralat + butang "Cuba lagi". Mesej tak
  // dedahkan ralat mentah kepada pengguna.
  Widget _feedStatus(Object? error) {
    if (error == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Center(
          child: SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(widget.palette.accent),
            ),
          ),
        ),
      );
    }

    // FirebaseException.toString() mengandungi kod, cth.
    // "[cloud_firestore/permission-denied] ...".
    final bool denied = error.toString().contains('permission-denied');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Text(
            denied
                ? 'Tak dapat muat post komuniti. Pastikan e-mel anda sudah '
                  'disahkan, atau log masuk semula.'
                : 'Tak dapat muat post komuniti. Semak sambungan internet.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: widget.palette.textMuted),
          ),
          TextButton(
            onPressed: () =>
                setState(() => _postsStream = _openPostsStream()),
            child: Text('Cuba lagi',
                style: TextStyle(color: widget.palette.accent)),
          ),
        ],
      ),
    );
  }

  // ── Post sebenar dari Firestore → PostModel ──────────────────
  static String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final Duration diff = DateTime.now().difference(ts.toDate());
    if (diff.inMinutes < 1)  return 'Baru sahaja';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24)   return '${diff.inHours}j';
    return '${diff.inDays}h lalu';
  }

  static PostModel _postFromDoc(QueryDocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PostModel(
      id:            doc.id,
      type:          d['type'] ?? 'article',
      title:         d['title'] ?? '',
      content:       d['content'] ?? '',
      author:        d['author'] ?? 'Pengguna iHijrah',
      authorId:      d['authorId'] ?? '',
      time:          _timeAgo(d['createdAt'] as Timestamp?),
      likes:         d['likes'] ?? 0,
      commentsCount: d['commentsCount'] ?? 0,
      assetPath:     d['assetPath'],
      category:      d['category'],
    );
  }

  static const List<double> _aspectPool = [1.05, 1.25, 1.45, 1.7];

  double _imageAspectFor(PostModel post) {
    return _aspectPool[post.id.hashCode.abs() % _aspectPool.length];
  }

  // Tekan mana-mana kad harian → buka FlyoutPanel dgn kandungan PENUH
  // (jalan yg sama macam tekan menu di sidebar) — bukan skrin/route
  // baru. `setActiveMenu()` toggle: kalau flyout tu dah terbuka utk id
  // sama, tekan lagi akan tutup — sama macam behaviour sidebar sedia ada.
  Widget _dailyCard(_FeedItem item, DailyContentProvider daily) {
    final sidebar = context.read<SidebarStateModel>();

    if (item is _HadithItem) {
      return DailyHadithCard(
        hadith: item.hadith, palette: widget.palette,
        onTap: () => sidebar.setActiveMenu('hadith'),
      );
    }
    if (item is _AmalanItem) {
      return DailyAmalanCard(
        amalan: item.amalan, palette: widget.palette,
        onToggle: () => daily.toggleAmalan(item.amalan.id),
        onTap: () => sidebar.setActiveMenu('amalan'),
      );
    }
    return DailySirahCard(
      sirah: (item as _SirahItem).sirah, palette: widget.palette,
      onTap: () => sidebar.setActiveMenu('sirah'),
    );
  }
}
