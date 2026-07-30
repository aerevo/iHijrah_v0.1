// lib/widgets/sidebar.dart
// Rel navigasi KIRI — gantikan navbar atas.
// - Keadaan lalai: ikon + label ringkas (kRailWidthCollapsed)
// - Tekan logo ATAU swipe kanan pada rel: kembang penuh (kRailWidthExpanded)
// - Scroll feed ke bawah: rel pudar/gelongsor keluar; scroll atas: kembali
// - Semua navigasi (logo, avatar, notis, carian, 6 tab) hidup di sini sahaja

import 'dart:io';
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

        // ── REL UTAMA ────────────────────────────────────
        AnimatedPositioned(
          duration: AppDurations.normal,
          curve: AppCurves.smooth,
          left: model.isVisible ? 0 : -kRailWidthExpanded,
          top: 0, bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (d) {
              final vx = d.velocity.pixelsPerSecond.dx;
              if (vx > 250 && !model.isExpanded) model.toggleExpanded();
              if (vx < -250 && model.isExpanded) model.toggleExpanded();
            },
            child: AnimatedContainer(
              duration: AppDurations.normal,
              curve: AppCurves.smooth,
              width: width,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: kRailGreenGradient,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 24,
                    offset: Offset(6, 0),
                  ),
                ],
              ),
              child: _railContent(context, model, user),
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
          const SizedBox(height: 10),

          // Wordmark ringkas — tekan untuk kembang/kuncup (tiada lagi
          // ikon pokok di sini; pokok "hidup" kini di bawah avatar)
          _wordmarkRow(model),

          _divider(),
          const SizedBox(height: 8),

          // Avatar + nama + umur Hijrah — tekan buka Profil
          _avatarRow(model, user),

          const SizedBox(height: 10),

          // Pokok Embun Jiwa — video sebenar (sama macam tab Pokok),
          // tekan -> tab Pokok. Cuma dirender bila rel memang visible
          // (bila tersorok scroll-bawah, video di-dispose terus, jimat
          // prestasi — bukan main senyap belakang tabir).
          _miniTreeSlot(model, user),

          const SizedBox(height: 10),
          _divider(),
          const SizedBox(height: 6),

          // Tab utama
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: _mainTabs
                    .map((t) => _railItem(model, t))
                    .toList(),
              ),
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
        color: Colors.black.withOpacity(0.14),
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
                  onTap: () => model.setActiveMenu('pokok'),
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

  // ── WORDMARK (ganti logo pokok — cuma teks/monogram) ─────────
  Widget _wordmarkRow(SidebarStateModel model) {
    return GestureDetector(
      onTap: model.toggleExpanded,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: model.isExpanded
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'iHijrah',
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: kPrimaryNavy,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_left_rounded,
                        color: kRailGreenText.withOpacity(0.6), size: 20),
                  ],
                ),
              )
            : Center(
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.5),
                    border: Border.all(
                        color: kPrimaryGold.withOpacity(0.6), width: 1.2),
                  ),
                  child: Center(
                    child: Text(
                      'iH',
                      style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: kGoldDark,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // ── AVATAR ──────────────────────────────────────────────────
  Widget _avatarRow(SidebarStateModel model, UserModel user) {
    final bool hasAvatar =
        user.avatarPath != null && user.avatarPath!.isNotEmpty;

    return GestureDetector(
      onTap: () => model.setActiveMenu('profil'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: model.isExpanded ? 16 : 0,
          vertical: 6,
        ),
        child: model.isExpanded
            ? Row(
                children: [
                  _avatarCircle(user, hasAvatar, 34),
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
                            color: kPrimaryNavy,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user.hijriAge,
                          style: TextStyle(
                              color: kPrimaryNavy.withOpacity(0.7), fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Center(child: _avatarCircle(user, hasAvatar, 34)),
      ),
    );
  }

  Widget _avatarCircle(UserModel user, bool hasAvatar, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kPrimaryNavy.withOpacity(0.75), width: 1.4),
        color: Colors.white.withOpacity(0.55),
      ),
      child: ClipOval(
        child: hasAvatar
            ? Image.file(File(user.avatarPath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _avatarFallback(user))
            : _avatarFallback(user),
      ),
    );
  }

  Widget _avatarFallback(UserModel user) => Center(
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'H',
          style: const TextStyle(
              color: kPrimaryNavy, fontSize: 13, fontWeight: FontWeight.w800),
        ),
      );

  // ── ITEM REL (tab / notis / carian) ────────────────────────
  Widget _railItem(SidebarStateModel model, _RailTab t) {
    final bool isUtama = t.id == 'utama';
    final bool active  = isUtama ? model.isClosed : model.isMenuActive(t.id);

    return GestureDetector(
      onTap: () => isUtama ? model.closeMenu() : model.setActiveMenu(t.id),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        margin: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        padding: EdgeInsets.symmetric(
          horizontal: model.isExpanded ? 12 : 0,
          vertical: model.isExpanded ? 11 : 9,
        ),
        decoration: BoxDecoration(
          color: active ? kRailGreenActive : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: active
              ? Border.all(color: Colors.white.withOpacity(0.4), width: 1)
              : null,
          boxShadow: active
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 3)),
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
                      color: active ? Colors.white : kRailGreenText,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MetallicIcon(icon: t.icon, size: 20, gradient: t.gradient),
                  const SizedBox(height: 3),
                  Text(
                    t.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.6,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.w600,
                      color: active ? Colors.white : kRailGreenText,
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
            colors: [kRailGreenMid, kRailGreenActive],
          ),
          borderRadius:
              const BorderRadius.horizontal(right: Radius.circular(18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 14,
              offset: const Offset(3, 0),
            ),
          ],
        ),
        child: const Icon(Icons.chevron_right_rounded,
            color: Colors.white, size: 20),
      ),
    );
  }
}
