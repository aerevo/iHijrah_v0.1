// lib/widgets/flyout_panel.dart (VERSI GLASS: LEBIH TERANG & JELAS)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; 

import '../models/sidebar_state_model.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart';

// === IMPORT SEMUA VIEW ===
import 'profile_detail_view.dart';
import 'calendar_view.dart';
import 'event_view.dart';
import 'settings_view.dart'; 
import 'about_view.dart';    
import 'hijrah_tree.dart'; 
import 'birthday_view.dart'; 

// ✅ IMPORT DUA BERADIK BARU
import 'sirah_view.dart';    
import 'amalan_view.dart';   

class FlyoutPanel extends StatelessWidget {
  final double panelWidth;
  const FlyoutPanel({Key? key, this.panelWidth = AppSizes.flyoutWidth}) : super(key: key);

  // --- KANDUNGAN MENU ---
  Widget _buildContent(String menuId) {
    switch (menuId) {
      case 'profil': return const ProfileDetailView();
      case 'kalendar': return const CalendarView();
      case 'peristiwa': return const EventView();
      case 'notifikasi': return const SettingsView();
      case 'info': return const AboutView();
      
      // POKOK SAHAJA
      case 'tree_progress': return const HijrahTree(); 
      
      // HARI JADI
      case 'birthday': return const BirthdayView();

      // ✅ MENU 1: SIRAH
      case 'sirah': return const SirahView(); 
      
      // ✅ MENU 2: AMALAN (Misi Harian)
      case 'amalan': return const AmalanView(); 
      
      case 'infaq': 
        return const Center(
          child: Text("Infaq - Coming Soon", style: TextStyle(color: kTextSecondary))
        );
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SidebarStateModel>(
      builder: (context, model, child) {
        final double width = model.isClosed ? 0 : panelWidth;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          width: width,
          height: double.infinity,
          child: OverflowBox(
            minWidth: panelWidth,
            maxWidth: panelWidth,
            alignment: Alignment.centerLeft,
            child: model.isClosed 
              ? const SizedBox.shrink() 
              : _buildGlassContainer(context, model),
          ),
        );
      },
    );
  }

  Widget _buildGlassContainer(BuildContext context, SidebarStateModel model) {
    return ClipRect(
      child: BackdropFilter(
        // KURANGKAN BLUR SEDIKIT SUPAYA LEBIH REALISTIK
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), 
        child: Container(
          width: panelWidth,
          height: double.infinity,
          decoration: BoxDecoration(
            // ✅ UBAH DI SINI: Opacity diturunkan drpd 0.4 ke 0.15 (Lebih Terang)
            color: Colors.black.withOpacity(0.15), 
            border: Border(
              right: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
              left: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER MENU
              Container(
                padding: const EdgeInsets.only(
                  top: 50,
                  left: AppSpacing.md, 
                  right: AppSpacing.sm, 
                  bottom: AppSpacing.md
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.1))
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MetallicGold(
                      child: Text(
                        model.menuTitle.toUpperCase(),
                        style: const TextStyle(
                          fontSize: AppFontSizes.lg,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontFamily: 'Playfair',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => model.closeMenu(),
                    ),
                  ],
                ),
              ),

              // KANDUNGAN
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _buildContent(model.activeMenuId!),
                      const SizedBox(height: 100), 
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
