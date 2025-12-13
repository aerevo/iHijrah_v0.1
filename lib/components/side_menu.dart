import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hijri/hijri_calendar.dart'; // Pastikan package 'hijri' ada dalam pubspec.yaml
import '../models/user_model.dart';
import '../models/sidebar_state_model.dart';
import 'side_menu_tile.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  
  // Fungsi Helper: Kira Umur Hijrah
  String _calculateHijrahAge(DateTime? dob) {
    if (dob == null) return "0";
    
    final HijriCalendar todayHijri = HijriCalendar.now();
    final HijriCalendar dobHijri = HijriCalendar.fromDate(dob);
    
    int age = todayHijri.hYear - dobHijri.hYear;
    
    // Jika belum sampai bulan hari jadi
    if (todayHijri.hMonth < dobHijri.hMonth) {
      age--;
    } else if (todayHijri.hMonth == dobHijri.hMonth) {
      // Jika bulan sama tapi hari belum sampai
      if (todayHijri.hDay < dobHijri.hDay) {
        age--;
      }
    }
    return age.toString();
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final sidebarState = Provider.of<SidebarStateModel>(context);

    // Dapatkan data user (jika tiada data, guna default)
    String userName = userModel.name.isNotEmpty ? userModel.name : "Hamba Allah";
    String hijrahAge = _calculateHijrahAge(userModel.dateOfBirth); // Pastikan userModel ada field dateOfBirth

    return Scaffold(
      body: Container(
        width: 288,
        height: double.infinity,
        color: const Color(0xFF17203A),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BAHAGIAN PROFIL (UPGRADE) ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Gambar Profil
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white10,
                        // Pastikan letak gambar di folder assets
                        backgroundImage: AssetImage('assets/images/profile_default.png'),
                      ),
                    ),
                    
                    const SizedBox(height: 15),

                    // 2. Nama User (Font Halus & Elegan)
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w300, // Light/Thin font
                        letterSpacing: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // 3. Umur Hijrah Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_filled, color: Colors.white70, size: 12),
                          const SizedBox(width: 6),
                          Text(
                            "$hijrahAge Tahun Hijrah",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Garis Pemisah
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Divider(color: Colors.white.withOpacity(0.1), height: 1),
              ),
              
              const SizedBox(height: 20),

              // --- MENU ITEMS ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    SideMenuTile(
                      title: "Utama",
                      riveSrc: "assets/RiveAssets/icons.riv",
                      artboard: "HOME",
                      isActive: sidebarState.activeMenuId == 0,
                      onTap: () => sidebarState.setActiveMenu(0),
                    ),
                    SideMenuTile(
                      title: "Carian",
                      riveSrc: "assets/RiveAssets/icons.riv",
                      artboard: "SEARCH",
                      isActive: sidebarState.activeMenuId == 1,
                      onTap: () => sidebarState.setActiveMenu(1),
                    ),
                    SideMenuTile(
                      title: "Notifikasi",
                      riveSrc: "assets/RiveAssets/icons.riv",
                      artboard: "BELL",
                      isActive: sidebarState.activeMenuId == 2,
                      onTap: () => sidebarState.setActiveMenu(2),
                    ),
                    SideMenuTile(
                      title: "Tetapan",
                      riveSrc: "assets/RiveAssets/icons.riv",
                      artboard: "SETTINGS",
                      isActive: sidebarState.activeMenuId == 3,
                      onTap: () => sidebarState.setActiveMenu(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}