// lib/widgets/sidebar.dart
// Rel navigasi KIRI — gantikan navbar atas.
// - Keadaan lalai: ikon + label ringkas (kRailWidthCollapsed)
// - Tekan logo ATAU swipe kanan pada rel: kembang penuh (kRailWidthExpanded)
// - Scroll feed ke bawah: rel pudar/gelongsor keluar; scroll atas: kembali
// - Semua navigasi (logo, avatar, notis, carian, 6 tab) hidup di sini sahaja

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sidebar_state_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

// ── SAIZ REL ──────────────────────────────────────────────────
const double kRailWidthCollapsed = 72.0;
const double kRailWidthExpanded  = 226.0;

class _RailTab {
  final String   id;
  final IconData icon;
  final String   label;
  const _RailTab(this.id, this.icon, this.label);
}

const List<_RailTab> _mainTabs = [
  _RailTab('utama',    Icons.home_rounded,             'Utama'),
  _RailTab('sirah',    Icons.auto_stories_rounded,     'Sirah'),
  _RailTab('amalan',   Icons.spa_rounded,              'Amalan'),
  _RailTab('kalendar', Icons.calendar_month_rounded,   'Jadual'),
  _RailTab('pokok',    Icons.park_rounded,             'Pokok'),
  _RailTab('profil',   Icons.person_rounded,           'Profil'),
];

const List<_RailTab> _utilityTabs = [
  _RailTab('notifikasi', Icons.notifications_none_rounded, 'Notis'),
  _RailTab('carian',     Icons.search_rounded,             'Cari'),
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
                gradient: kRailGoldGradient,
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

          // Logo — tekan untuk kembang/kuncup
          _logoRow(model),

          _divider(),
          const SizedBox(height: 4),

          // Avatar + identiti — tekan buka Profil
          _avatarRow(model, user),

          const SizedBox(height: 6),
          _divider(),
          const SizedBox(height: 8),

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

  // ── LOGO ────────────────────────────────────────────────────
  Widget _logoRow(SidebarStateModel model) {
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
                    _logoMark(),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'iHijrah',
                        style: TextStyle(
                          fontFamily: 'Playfair',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: kPrimaryNavy,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_left_rounded,
                        color: kRailTextDark.withOpacity(0.55), size: 20),
                  ],
                ),
              )
            : Center(child: _logoMark()),
      ),
    );
  }

  // Bebola emas 3D — cahaya dari atas-kiri, ikon navy sebagai kontras
  Widget _logoMark() => Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(-0.35, -0.35),
            radius: 0.9,
            colors: [kGoldHighlight, kGoldMid, kGoldDeep],
            stops: [0.0, 0.55, 1.0],
          ),
          boxShadow: [
            BoxShadow(
                color: kGoldHighlight.withOpacity(0.7),
                blurRadius: 3,
                offset: const Offset(-1, -1)),
            BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 7,
                offset: const Offset(2, 3)),
          ],
        ),
        child: const Icon(Icons.nights_stay_rounded,
            color: kPrimaryNavy, size: 18),
      );

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
          color: active ? kPrimaryNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: active
              ? Border.all(color: kGoldHighlight.withOpacity(0.4), width: 1)
              : null,
          boxShadow: active
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 3)),
                ]
              : null,
        ),
        child: model.isExpanded
            ? Row(
                children: [
                  Icon(t.icon,
                      size: 20,
                      color: active ? Colors.white : kRailTextDark),
                  const SizedBox(width: 14),
                  Text(
                    t.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.w600,
                      color: active ? Colors.white : kRailTextDark,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.icon,
                      size: 20,
                      color: active ? Colors.white : kRailTextDark),
                  const SizedBox(height: 3),
                  Text(
                    t.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8.6,
                      fontWeight:
                          active ? FontWeight.w700 : FontWeight.w600,
                      color: active ? Colors.white : kRailTextDark,
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
            colors: [kGoldMid, kGoldDeep],
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
