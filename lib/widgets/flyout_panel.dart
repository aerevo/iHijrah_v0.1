// lib/widgets/flyout_panel.dart (UPDATED)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; 

import '../models/sidebar_state_model.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart';

// === IMPORT VIEWS ===
import 'profile_detail_view.dart';
import 'calendar_view.dart';
import 'event_view.dart';
import 'settings_view.dart'; 
import 'about_view.dart';   
import 'hijrah_tree.dart'; 
import 'birthday_view.dart'; // ✅ 1. TAMBAH IMPORT INI

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
      case 'tree_progress': return const HijrahTree(); 
      
      case 'sirah': 
        return const Center(
          child: Text(
            "Halaman Sirah - Akan Datang", 
            style: TextStyle(color: kTextSecondary)
          )
        );
        
      // ✅ 2. GANTI BAHAGIAN INI DENGAN WIDGET BARU
      case 'birthday': 
        return const BirthdayView(); 
        
      case 'infaq': 
        return const Center(
          child: Text(
            "Infaq - Sila rujuk Dialog", 
            style: TextStyle(color: kTextSecondary)
          )
        );
      default: return const SizedBox.shrink();
    }
  }

  // ... (Bahagian build di bawah KEKAL SAMA macam fail asal Kapten) ...
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
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), 
        child: Container(
          width: panelWidth,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4), 
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

              // KANDUNGAN SCROLLABLE
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
