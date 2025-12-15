// lib/widgets/flyout_panel.dart (FIXED: Added dart:ui import)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // ✅ IMPORT BARU: Untuk ImageFilter.blur

import '../models/sidebar_state_model.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart';

// === IMPORT VIEWS ===
import 'profile_detail_view.dart';
import 'calendar_view.dart';
import 'event_view.dart';
import 'settings_view.dart'; // Setting Notifikasi
import 'about_view.dart';   // Info Aplikasi
import 'hijrah_tree.dart'; // Untuk paparan Pokok penuh

class FlyoutPanel extends StatelessWidget {
  final double panelWidth;
  const FlyoutPanel({Key? key, this.panelWidth = AppSizes.flyoutWidth}) : super(key: key);

  Widget _buildContent(String menuId) {
    switch (menuId) {
      case 'profil': return const ProfileDetailView();
      case 'kalendar': return const CalendarView();
      case 'peristiwa': return const EventView();
      case 'notifikasi': return const SettingsView(); // Mengandung NotificationSettingsScreen
      case 'info': return const AboutView();
      
      // ✅ MENU BARU
      case 'tree_progress': return const HijrahTree(); // Show Tree full view
      case 'sirah': // Sirah Screen - Placeholder
        return const Center(child: Text("Halaman Sirah Lengkap - Dalam Pembangunan.", style: TextStyle(color: kTextSecondary)));
      case 'birthday': // Ucapan Hari Jadi - Placeholder
        return const Center(child: Text("Halaman Ucapan Hari Jadi (Live) - Akan Datang", style: TextStyle(color: kTextSecondary)));
        
      default: return const Center(child: Text("Sila Pilih Menu", style: TextStyle(color: kTextSecondary)));
    }
  }

  String _getTitle(String menuId) {
    switch (menuId) {
      case 'profil': return 'Profil Saya';
      case 'kalendar': return 'Kalendar Islam';
      case 'peristiwa': return 'Peristiwa Penting';
      case 'notifikasi': return 'Tetapan & Notifikasi';
      case 'info': return 'Tentang Aplikasi';
      
      // ✅ MENU BARU
      case 'tree_progress': return 'Progres Pokok Hijrah';
      case 'sirah': return 'Arkib Sirah Nabi SAW';
      case 'birthday': return 'Ulangtahun Hijrah';
      
      default: return 'Menu Sampingan';
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<SidebarStateModel>(context);

    // Animasi Flyout Panel
    return AnimatedContainer(
      duration: AppDurations.medium,
      curve: AppCurves.smooth,
      width: model.isMenuOpen ? panelWidth : 0,
      
      // Pastikan Flyout Panel tidak hilang bila Flyout Close
      constraints: BoxConstraints(maxWidth: model.isMenuOpen ? panelWidth : 0),
      
      child: model.isMenuOpen
          ? Container(
              decoration: BoxDecoration(
                color: kBackgroundDark,
                border: Border(left: BorderSide(color: kPrimaryGold.withOpacity(0.3))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ClipRRect(
                // ✅ ImageFilter.blur sekarang berfungsi
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER (Title & Close Button)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.lg, left: AppSpacing.screenH, right: AppSpacing.md, bottom: AppSpacing.md),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Title Emas
                            MetallicGold(
                              child: Text(
                                _getTitle(model.activeMenuId!),
                                style: const TextStyle(
                                  fontSize: AppFontSizes.xxl,
                                  fontFamily: 'Playfair',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            
                            // Close Button
                            IconButton(
                              icon: const Icon(Icons.close, color: kTextSecondary),
                              onPressed: () => model.closeMenu(),
                            ),
                          ],
                        ),
                      ),
                      
                      // Divider & Glow
                      Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: kTextSecondary.withOpacity(0.1), width: 1)),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black12, Colors.transparent],
                            ),
                          ),
                      ),

                      // KANDUNGAN
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.md, left: AppSpacing.screenH, right: AppSpacing.screenH, bottom: 100),
                            child: _buildContent(model.activeMenuId!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
