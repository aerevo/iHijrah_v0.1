// lib/widgets/sidebar.dart
// Top navbar — Facebook style
// Scroll bawah = sembunyi, scroll atas = floating button, tap = keluar semula

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/sidebar_state_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'living_tree.dart';
import 'metallic_gold.dart';

// ── TINGGI NAVBAR ─────────────────────────────────────────────
const double kNavbarHeight     = 100.0; // Baris 1 (logo+profile) + Baris 2 (tabs)
const double kNavbarRow1Height = 54.0;
const double kNavbarRow2Height = 46.0;

class Sidebar extends StatefulWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar>
    with SingleTickerProviderStateMixin {

  final String _whatsappNumber  = '+60133662440';
  final String _whatsappMessage =
      'Assalamualaikum Admin, saya berminat untuk membuat Infaq Pembangunan iHijrah.';

  Future<void> _launchWhatsApp() async {
    final url =
        'whatsapp://send?phone=$_whatsappNumber&text=${Uri.encodeComponent(_whatsappMessage)}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _getTreeAsset(int level) {
    if (level <= 1) return AppAssets.treeV1;
    if (level <= 2) return AppAssets.treeV2;
    if (level <= 3) return AppAssets.treeV3;
    return AppAssets.treeV4;
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SidebarStateModel>();
    final user  = context.watch<UserModel>();

    return Stack(
      children: [

        // ── TOP NAVBAR ─────────────────────────────────────
        AnimatedPositioned(
          duration: AppDurations.normal,
          curve: AppCurves.smooth,
          top: model.isVisible ? 0 : -kNavbarHeight,
          left: 0, right: 0,
          height: kNavbarHeight,
          child: _buildNavbar(context, model, user),
        ),

        // ── FAB TERAPUNG — muncul bila navbar sembunyi ──────
        AnimatedPositioned(
          duration: AppDurations.normal,
          curve: AppCurves.smooth,
          top: model.isVisible ? -50 : MediaQuery.of(context).padding.top + 8,
          right: 14,
          child: _buildFab(context, model),
        ),
      ],
    );
  }

  // ── NAVBAR ────────────────────────────────────────────────────
  Widget _buildNavbar(
      BuildContext ctx, SidebarStateModel model, UserModel user) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: kBackgroundDark.withOpacity(0.82),
            border: const Border(
              bottom: BorderSide(color: Color(0x1AFFFFFF), width: 0.5),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Baris 1 — logo + profil + ikon
                SizedBox(
                  height: kNavbarRow1Height,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [

                        // Avatar + nama
                        GestureDetector(
                          onTap: () => model.setActiveMenu('profil'),
                          child: Row(
                            children: [
                              _avatar(user),
                              const SizedBox(width: 8),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name.isEmpty
                                        ? 'Hamba Allah'
                                        : user.name.split(' ').first,
                                    style: const TextStyle(
                                      color: kTextPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    user.hijriAge,
                                    style: const TextStyle(
                                      color: kPrimaryGold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Logo tengah
                        const Text(
                          'iHijrah',
                          style: TextStyle(
                            color: kGoldLight,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Playfair',
                            letterSpacing: 1,
                          ),
                        ),

                        const Spacer(),

                        // Ikon kanan
                        _iconBtn(Icons.notifications_none_rounded,
                            () => model.setActiveMenu('notifikasi')),
                        const SizedBox(width: 4),
                        _iconBtn(Icons.search_rounded,
                            () => model.setActiveMenu('carian')),
                      ],
                    ),
                  ),
                ),

                // Baris 2 — tab menu
                SizedBox(
                  height: kNavbarRow2Height,
                  child: _buildTabs(ctx, model, user),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── TAB MENU ──────────────────────────────────────────────────
  Widget _buildTabs(
      BuildContext ctx, SidebarStateModel model, UserModel user) {
    final tabs = [
      _TabItem('utama',    Icons.home_rounded,             'Utama'),
      _TabItem('sirah',    Icons.auto_stories_rounded,     'Sirah'),
      _TabItem('amalan',   Icons.spa_rounded,              'Amalan'),
      _TabItem('kalendar', Icons.calendar_month_rounded,   'Jadual'),
      _TabItem('pokok',    Icons.park_rounded,             'Pokok'),
      _TabItem('profil',   Icons.person_rounded,           'Profil'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: tabs.map((t) {
        final bool active = model.activeMenuId == t.id;
        return GestureDetector(
          onTap: () => model.setActiveMenu(t.id),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: active
                  ? kPrimaryGold.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(t.icon,
                    size: 18,
                    color: active ? kPrimaryGold : kTextMuted),
                const SizedBox(height: 1),
                Text(
                  t.label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: active
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: active ? kPrimaryGold : kTextMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── FAB TERAPUNG ──────────────────────────────────────────────
  Widget _buildFab(BuildContext ctx, SidebarStateModel model) {
    return GestureDetector(
      onTap: () => model.setSidebarVisibility(true),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: kBackgroundDark.withOpacity(0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: kPrimaryGold.withOpacity(0.35), width: 0.8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_rounded,
                    color: kPrimaryGold, size: 16),
                SizedBox(width: 5),
                Text(
                  'iHijrah',
                  style: TextStyle(
                    color: kGoldLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Playfair',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HELPER WIDGETS ────────────────────────────────────────────
  Widget _avatar(UserModel user) {
    final bool hasAvatar =
        user.avatarPath != null && user.avatarPath!.isNotEmpty;
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: kPrimaryGold.withOpacity(0.5), width: 1.2),
        color: kPrimaryGold.withOpacity(0.12),
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
          color: kPrimaryGold,
          fontSize: 14,
          fontWeight: FontWeight.w700),
    ),
  );

  Widget _iconBtn(IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
          ),
          child: Icon(icon, color: kTextSecondary, size: 18),
        ),
      );
}

// ── DATA ──────────────────────────────────────────────────────
class _TabItem {
  final String id, label;
  final IconData icon;
  const _TabItem(this.id, this.icon, this.label);
}
