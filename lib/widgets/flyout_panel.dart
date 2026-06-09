// lib/widgets/flyout_panel.dart
// Slide bawah dari top navbar — penuh lebar

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sidebar_state_model.dart';
import '../utils/constants.dart';

import 'profile_detail_view.dart';
import 'calendar_view.dart';
import 'event_view.dart';
import 'settings_view.dart';
import 'about_view.dart';
import 'hijrah_tree.dart';
import 'birthday_view.dart';
import 'sirah_view.dart';
import 'amalan_view.dart';

class FlyoutPanel extends StatelessWidget {
  const FlyoutPanel({Key? key}) : super(key: key);

  // ── TAJUK IKUT MENU ─────────────────────────────────────────
  String _title(String? id) {
    switch (id) {
      case 'profil':    return 'Profil';
      case 'kalendar':  return 'Kalendar Hijrah';
      case 'sirah':     return 'Khazanah Nabi';
      case 'amalan':    return 'Misi Harian';
      case 'pokok':     return 'Pokok Hijrah';
      case 'birthday':  return 'Hari Jadi Hijrah';
      case 'notifikasi':return 'Tetapan';
      case 'info':      return 'Tentang iHijrah';
      case 'carian':    return 'Carian';
      default:          return 'iHijrah';
    }
  }

  IconData _icon(String? id) {
    switch (id) {
      case 'profil':    return Icons.person_rounded;
      case 'kalendar':  return Icons.calendar_month_rounded;
      case 'sirah':     return Icons.auto_stories_rounded;
      case 'amalan':    return Icons.spa_rounded;
      case 'pokok':     return Icons.park_rounded;
      case 'birthday':  return Icons.cake_rounded;
      case 'notifikasi':return Icons.settings_rounded;
      case 'info':      return Icons.info_outline_rounded;
      default:          return Icons.home_rounded;
    }
  }

  Widget _content(String? id) {
    switch (id) {
      case 'profil':    return const ProfileDetailView();
      case 'kalendar':  return const CalendarView();
      case 'sirah':     return const SirahView();
      case 'amalan':    return const AmalanView();
      case 'pokok':     return const HijrahTree(isExpanded: true);
      case 'birthday':  return const BirthdayView();
      case 'notifikasi':return const SettingsView();
      case 'info':      return const AboutView();
      case 'peristiwa': return const EventView();
      case 'infaq':
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text('Infaq — Akan datang segera 🌱',
                style: TextStyle(color: kTextSecondary, fontSize: 14)),
          ),
        );
      case 'carian':
        return _SearchPlaceholder();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SidebarStateModel>(
      builder: (ctx, model, _) {

        final bool open = !model.isClosed;

        return Stack(
          children: [

            // ── BACKDROP ──────────────────────────────────────
            if (open)
              GestureDetector(
                onTap: model.closeMenu,
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                ),
              ),

            // ── PANEL ─────────────────────────────────────────
            AnimatedSlide(
              duration: const Duration(milliseconds: 380),
              curve: open ? AppCurves.spring : AppCurves.snap,
              offset: open ? Offset.zero : const Offset(0, -1),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 280),
                opacity: open ? 1.0 : 0.0,
                child: open
                    ? _PanelSheet(
                        title:   _title(model.activeMenuId),
                        icon:    _icon(model.activeMenuId),
                        onClose: model.closeMenu,
                        child:   _content(model.activeMenuId),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── SHEET ─────────────────────────────────────────────────────
class _PanelSheet extends StatelessWidget {
  final String       title;
  final IconData     icon;
  final VoidCallback onClose;
  final Widget       child;

  const _PanelSheet({
    required this.title,
    required this.icon,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final double maxH = MediaQuery.of(context).size.height * 0.80;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: kBackgroundDark.withOpacity(0.92),
                border: const Border(
                  bottom: BorderSide(color: Color(0x22C9A84C), width: 0.8),
                  left:   BorderSide(color: Color(0x11FFFFFF), width: 0.5),
                  right:  BorderSide(color: Color(0x11FFFFFF), width: 0.5),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ── HEADER ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 12, 10),
                    child: Row(
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kPrimaryGold.withOpacity(0.12),
                          ),
                          child: Icon(icon,
                              color: kPrimaryGold, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          title,
                          style: const TextStyle(
                            color: kGoldLight,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: onClose,
                          child: Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.06),
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: kTextSecondary, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 0.5,
                    color: kBorderSubtle,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),

                  // ── CONTENT ──────────────────────────────────
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      physics: const BouncingScrollPhysics(),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── SEARCH PLACEHOLDER ────────────────────────────────────────
class _SearchPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        TextField(
          autofocus: true,
          style: const TextStyle(color: kTextPrimary),
          decoration: InputDecoration(
            hintText: 'Cari ceramah, ustaz, topik...',
            hintStyle: const TextStyle(color: kTextMuted),
            prefixIcon: const Icon(Icons.search_rounded,
                color: kPrimaryGold, size: 20),
            filled: true,
            fillColor: kCardDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              borderSide: const BorderSide(color: kPrimaryGold, width: 1),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Carian ceramah & tempat ibadat\nakan datang segera ✨',
          style: TextStyle(
              color: kTextSecondary, fontSize: 13, height: 1.6),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
