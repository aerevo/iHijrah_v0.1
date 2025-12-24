// lib/widgets/flyout_panel.dart (GLASSMORPHISM STYLE)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Wajib untuk ImageFilter.blur (Efek Kaca)

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

class FlyoutPanel extends StatelessWidget {
  final double panelWidth;
  // Lebar panel menu (Lebih lebar sikit dari dulu supaya nampak luas)
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
      case 'birthday': 
        return const Center(
          child: Text(
            "Hari Jadi - Akan Datang", 
            style: TextStyle(color: kTextSecondary)
          )
        );
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

  @override
  Widget build(BuildContext context) {
    return Consumer<SidebarStateModel>(
      builder: (context, model, child) {
        // Logik Animasi Sliding
        final double width = model.isClosed ? 0 : panelWidth;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400), // Laju sikit dari default
          curve: Curves.easeOutCubic,
          width: width,
          height: double.infinity,
          // OverflowBox penting supaya isi dalam tak 'penyek' bila panel mengecil
          child: OverflowBox(
            minWidth: panelWidth,
            maxWidth: panelWidth,
            alignment: Alignment.centerLeft,
            child: model.isClosed 
              ? const SizedBox.shrink() // Kalau tutup, kosongkan terus (Performance)
              : _buildGlassContainer(context, model), // Kalau buka, tunjuk kaca
          ),
        );
      },
    );
  }

  // --- WIDGET KACA (GLASS CONTAINER) ---
  Widget _buildGlassContainer(BuildContext context, SidebarStateModel model) {
    return ClipRect( // Potong blur supaya tak melimpah
      child: BackdropFilter(
        // 1. KUASA BLUR (Semakin tinggi, semakin kabur corak belakang)
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), 
        child: Container(
          width: panelWidth,
          height: double.infinity,
          decoration: BoxDecoration(
            // 2. WARNA KACA (PENTING!)
            // Kita guna Hitam tapi nipis (0.4) supaya corak belakang nampak tembus
            color: Colors.black.withOpacity(0.4), 
            
            // 3. GARISAN TEPI (Border Kaca)
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
                  top: 50, // Jarak status bar
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
                    // Tajuk Menu (Emas)
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
                    // Butang Tutup (X)
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
                      // Kandungan sebenar
                      _buildContent(model.activeMenuId!),
                      
                      // Ruang kosong bawah supaya tak tertutup dek navigation bar
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
