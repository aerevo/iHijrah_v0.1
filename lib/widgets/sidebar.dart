// lib/widgets/sidebar.dart
// Rel navigasi KIRI — gantikan navbar atas.
// - Tema: KACA GELAP (glassmorphism) — navy-hitam lutsinar + blur, kontras
//   sengaja dgn app cerah, emas jenama sbg satu-satunya aksen "bersinar".
// - Keadaan lalai: ikon shj (kRailWidthCollapsed), rel terapung atas feed.
// - Kembang (kRailWidthExpanded) bila salah satu berlaku:
//     • tekan mana-mana bahagian rel (avatar/pokok/tab/ruang kosong)
//     • scroll senarai tab dalam rel
//     • swipe kanan atas rel
// - Kuncup balik: tekan chevron pada wordmark (bila kembang), atau swipe kiri.
// - Scroll FEED ke bawah: rel pudar/gelongsor keluar; scroll atas: kembali.
// - Semua navigasi (logo, avatar, notis, carian, 6 tab) hidup di sini sahaja.

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/sidebar_state_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'metallic_icon.dart';
import 'living_tree.dart';

// ── SAIZ REL ──────────────────────────────────────────────────
const double kRailWidthCollapsed = 60.0;
const double kRailWidthExpanded  = 226.0;

class _RailTab {
  final String   id;
  final IconData icon;
  final String   label;
  final List<Color> gradient;
  const _RailTab(this.id, this.icon, this.label, this.gradient);
}

const List<_RailTab> _mainTabs = [
  _RailTab('utama',    Icons.home_rounded,             'Utama',  MetallicPalettes.gold),
  _RailTab('sirah',    Icons.auto_stories_rounded,     'Sirah',  MetallicPalettes.navy),
  _RailTab('amalan',   Icons.spa_rounded,              'Amalan', MetallicPalettes.emerald),
  _RailTab('kalendar', Icons.calendar_month_rounded,   'Jadual', MetallicPalettes.bronze),
  _RailTab('pokok',    Icons.park_rounded,             'Pokok',  MetallicPalettes.emerald),
  _RailTab('profil',   Icons.person_rounded,           'Profil', MetallicPalettes.navy),
];

const List<_RailTab> _utilityTabs = [
  _RailTab('notifikasi', Icons.notifications_none_rounded, 'Notis', MetallicPalettes.gold),
  _RailTab('carian',     Icons.search_rounded,             'Cari',  MetallicPalettes.bronze),
];

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SidebarStateModel>();
    final user  = context.watch<UserModel>();

    final double width =
        model.isExpanded ? kRailWidthExpanded : kRailWidthCollapsed;

    return Stack(
      children: [

        // ── REL UTAMA (kaca gelap) ───────────────────────
        AnimatedPositioned(
          duration: AppDurations.normal,
          curve: AppCurves.smooth,
          left: model.isVisible ? 0 : -kRailWidthExpanded,
          top: 0, bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            // Tekan bahagian kosong rel (padding/divider) -> kembang.
            // Item spesifik (avatar/pokok/tab) ada expandRail() sendiri
            // dlm onTap masing-masing supaya tekan ikon terus kembang +
            // navigasi serentak — expandRail() idempoten jadi selamat
            // dipanggil serentak dari dua tempat.
            onTap: () {
              if (!model.isExpanded) model.expandRail();
            },
            onHorizontalDragEnd: (d) {
              final vx = d.velocity.pixelsPerSecond.dx;
              if (vx > 250 && !model.isExpanded) model.toggleExpanded();
              if (vx < -250 && model.isExpanded) model.toggleExpanded();
            },
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(26)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: AnimatedContainer(
                  duration: AppDurations.normal,
                  curve: AppCurves.smooth,
                  width: width,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: kGlassRailGradient,
                    border: const Border(
                      right: BorderSide(color: kGlassRailBorder, width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.38),
                        blurRadius: 28,
                        offset: const Offset(10, 0),
                      ),
                    ],
                  ),
                  child: _railContent(context, model, user),
                ),
              ),
            ),
          ),
        ),

        // ── HANDLE TERAPUNG — muncul bila rel tersembunyi ──
        AnimatedPositioned(
          duration: AppDurations.normal,
          curve: AppCurves.smooth,
          left: model.isVisible ? -50 : 0,
          top: MediaQuery.of(context).size.height * 0.42,
          child: _buildHandle(model),
        ),
      ],
    );
  }

  // ── ISI REL ─────────────────────────────────────────────────
  Widget _railContent(
      BuildContext ctx, SidebarStateModel model, UserModel user) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: model.isExpanded ? 8 : 14),

          // Wordmark "iHijrah" cuma perlu bila rel KEMBANG (label + butang
          // kuncup). Bila KUNCUP ia tak render (SizedBox.shrink) — avatar
          // terus jadi elemen paling atas, tiada ruang terbiar.
          _wordmarkRow(model),
          if (model.isExpanded) ...[
            _divider(),
            const SizedBox(height: 8),
          ],

          // Avatar + nama + umur Hijrah — tekan buka Profil (+ kembang rel)
          _avatarRow(model, user),

          const SizedBox(height: 10),

          // Pokok Embun Jiwa — video sebenar, tekan -> tab Pokok (+ kembang)
          _miniTreeSlot(model, user),

          const SizedBox(height: 10),
          _divider(),
          const SizedBox(height: 6),

          // Tab utama — diagihkan sama rata ikut ruang menegak yg ada.
          // Scroll dlm senarai ni pun kembangkan rel.
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (!model.isExpanded &&
                        (n is ScrollStartNotification ||
                            n is ScrollUpdateNotification)) {
                      model.expandRail();
                    }
                    return false; // biar notification terus bubble macam biasa
                  },
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _mainTabs
                            .map((t) => _railItem(model, t))
                            .toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          _divider(),
          const SizedBox(height: 6),

          ..._utilityTabs.map((t) => _railItem(model, t)),

          SizedBox(height: MediaQuery.of(ctx).padding.bottom + 10),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 0.6,
        color: kGlassRailBorder,
        margin: const EdgeInsets.symmetric(horizontal: 16),
      );

  // ── POKOK MINI (video sebenar, saiz sidebar) ─────────────────
  // FittedBox skalakan video ke kotak kecil ni tanpa kira aspect ratio
  // sebenar fail video — selamat dari overflow rel yang sempit (60px).
  Widget _miniTreeSlot(SidebarStateModel model, UserModel user) {
    final double boxSize = model.isExpanded ? 92 : 58;
    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: model.isVisible
          ? FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                height: 260,
                child: LivingTree(
                  assetPath: _treeAssetForLevel(user.treeLevel),
                  height: 260,
                  onTap: () {
                    if (!model.isExpanded) model.expandRail();
                    model.setActiveMenu('pokok');
                  },
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  String _treeAssetForLevel(int level) {
    if (level <= 1) return AppAssets.treeV1;
    if (level <= 3) return AppAssets.treeV2;
    if (level <= 6) return AppAssets.treeV3;
    return AppAssets.treeV4;
  }

  // ── WORDMARK ──────────────────────────────────────────────────
  // Nota: bila rel KUNCUP, wordmark tak render langsung — avatar naik
  // jadi elemen paling atas, tiada ruang kosong ditinggalkan. Bila
  // KEMBANG, wordmark muncul semula sbg label emas + butang kuncup.
  Widget _wordmarkRow(SidebarStateModel model) {
    if (!model.isExpanded) return const SizedBox.shrink();

    return GestureDetector(
      onTap: model.toggleExpanded,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'iHijrah',
                style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: kGoldLight,
                ),
              ),
            ),
            const Icon(Icons.chevron_left_rounded,
                color: kGlassTextDim, size: 20),
          ],
        ),
      ),
    );
  }

  // ── AVATAR ──────────────────────────────────────────────────
  Widget _avatarRow(SidebarStateModel model, UserModel user) {
    final bool hasAvatar =
        user.avatarPath != null && user.avatarPath!.isNotEmpty;
    final String displayName =
        user.name.trim().isEmpty ? 'Hamba Allah' : user.name.trim();

    return GestureDetector(
      onTap: () {
        if (!model.isExpanded) model.expandRail();
        model.setActiveMenu('profil');
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: model.isExpanded ? 16 : 10,
          vertical: 6,
        ),
        child: model.isExpanded
            ? Row(
                children: [
                  _avatarCircle(user, hasAvatar, 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.name.isEmpty
                              ? 'Hamba Allah'
                              : user.name.split(' ').first,
                          style: const TextStyle(
                            color: kGlassTextBright,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.hijriAge,
                          style: const TextStyle(
                              color: kGlassTextDim, fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            // Rel kuncup: avatar naik jadi elemen paling atas, nama (2
            // baris, center) + umur Hijrah terus di bawahnya dlm satu
            // kolum bertengah — identiti kekal kelihatan walau rel sempit.
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _avatarCircle(user, hasAvatar, 40),
                  const SizedBox(height: 6),
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kGlassTextBright,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.hijriAge,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: kGlassTextDim,
                      fontSize: 8.6,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _avatarCircle(UserModel user, bool hasAvatar, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kGoldLight.withOpacity(0.85), width: 1.6),
        color: Colors.white,
        boxShadow: [
          kGoldGlow(opacity: 0.30),
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: hasAvatar
            ? Image.file(File(user.avatarPath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarFallback())
            : _avatarFallback(),
      ),
    );
  }

  // Placeholder profil lalai — dipapar bila user belum letak gambar sendiri
  // (atau fail avatar rosak/hilang, via errorBuilder di atas).
  Widget _avatarFallback() => Image.asset(
        AppAssets.profileDefault,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: kGlassRailBase,
          alignment: Alignment.center,
          child: const Icon(Icons.person_rounded,
              color: kGlassTextDim, size: 18),
        ),
      );

  // ── ITEM REL (tab / notis / carian) ────────────────────────
  Widget _railItem(SidebarStateModel model, _RailTab t) {
    final bool isUtama = t.id == 'utama';
    final bool active  = isUtama ? model.isClosed : model.isMenuActive(t.id);
    // Warna teras gradient tab sendiri sbg tint badge tak aktif — beri rel
    // rasa "ceria"/berwarna tanpa jejaskan kekemasan. Status AKTIF pula
    // konsisten guna emas jenama (makna sama macam badge/streak di app).
    final Color tint = t.gradient[1];

    return GestureDetector(
      onTap: () {
        if (!model.isExpanded) model.expandRail();
        isUtama ? model.closeMenu() : model.setActiveMenu(t.id);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.smooth,
        margin: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        padding: EdgeInsets.symmetric(
          horizontal: model.isExpanded ? 12 : 2,
          vertical: model.isExpanded ? 11 : 10,
        ),
        decoration: BoxDecoration(
          gradient: active ? kGlassActiveGradient : null,
          color: active ? null : tint.withOpacity(0.16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active
                ? Colors.white.withOpacity(0.35)
                : Colors.white.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: active
              ? [
                  kGoldGlow(opacity: 0.35),
                  BoxShadow(
                      color: Colors.black.withOpacity(0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ]
              : null,
        ),
        child: model.isExpanded
            ? Row(
                children: [
                  MetallicIcon(icon: t.icon, size: 20, gradient: t.gradient),
                  const SizedBox(width: 14),
                  Text(
                    t.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.w600,
                      color: active ? kPrimaryNavyDeep : kGlassTextDim,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MetallicIcon(icon: t.icon, size: 20, gradient: t.gradient),
                  const SizedBox(height: 3),
                  // FittedBox -> label sekalipun panjang ("Amalan",
                  // "Jadual") tetap muat dlm rel sempit, tak terpotong "...".
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      t.label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 8.8,
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.w600,
                        color: active ? kPrimaryNavyDeep : kGlassTextDim,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── HANDLE TERAPUNG ─────────────────────────────────────────
  Widget _buildHandle(SidebarStateModel model) {
    return GestureDetector(
      onTap: () => model.setSidebarVisibility(true),
      child: Container(
        width: 30, height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kGlassRailBase, kGlassRailDeep],
          ),
          border: Border.all(color: kGlassRailBorder, width: 1),
          borderRadius:
              const BorderRadius.horizontal(right: Radius.circular(18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(3, 0),
            ),
            kGoldGlow(opacity: 0.20),
          ],
        ),
        child: const Icon(Icons.chevron_right_rounded,
            color: kGoldLight, size: 20),
      ),
    );
  }
}
