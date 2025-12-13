import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hijri/hijri_calendar.dart';
import '../models/user_model.dart';
import '../models/sidebar_state_model.dart';
import 'side_menu_tile.dart'; // Fail yang baru kita buat di Langkah 2

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
    
    if (todayHijri.hMonth < dobHijri.hMonth) {
      age--;
    } else if (todayHijri.hMonth == dobHijri.hMonth) {
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

    // FIX 1: Guna 'birthdate' bukan 'dateOfBirth'
    String userName = userModel.name.isNotEmpty ? userModel.name : "Hamba Allah";
    String hijrahAge = _calculateHijrahAge(userModel.birthdate); 

    // FIX 2: Pastikan Menu Active ID adalah String (ikut error log)
    // Jika SidebarStateModel Kapten guna int, tukar 'menuKey' di bawah jadi int.
    // Tapi ikut error log Kapten: "int can't be assigned to String". Jadi saya guna String.
    String activeMenu = sidebarState.activeMenuId.toString(); 

    return Scaffold(
      body: Container(
        width: 288,
        height: double.infinity,
        color: const Color(0xFF17203A),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BAHAGIAN PROFIL ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white10,
                        backgroundImage: AssetImage('assets/images/profile_default.png'),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
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
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Divider(color: Colors.white.withOpacity(0.1), height: 1),
              ),
              
              const SizedBox(height: 20),

              // --- MENU ITEMS (FIX TYPE ERROR) ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    SideMenuTile(
                      title: "Utama",
                      menuKey: "HOME",
                      riveSrc: "assets/RiveAssets/icons.riv",
                      artboard: "HOME",
                      isActive: activeMenu == "HOME" || activeMenu == "0", // Support String/Int logic
                      onTap: () => sidebarState.setActiveMenu("HOME"), // Pass String "HOME"
                    ),
                    SideMenuTile(
                      title: "Carian",
                      menuKey: "SEARCH",
                      riveSrc: "assets/RiveAssets/icons.riv",
                      artboard: "SEARCH",
                      isActive: activeMenu == "SEARCH" || activeMenu == "1",
                      onTap: () => sidebarState.setActiveMenu("SEARCH"),
                    ),
                    SideMenuTile(
                      title: "Notifikasi",
                      menuKey: "BELL",
                      riveSrc: "assets/RiveAssets/icons.riv",
                      artboard: "BELL",
                      isActive: activeMenu == "BELL" || activeMenu == "2",
                      onTap: () => sidebarState.setActiveMenu("BELL"),
                    ),
                    SideMenuTile(
                      title: "Tetapan",
                      menuKey: "SETTINGS",
                      riveSrc: "assets/RiveAssets/icons.riv",
                      artboard: "SETTINGS",
                      isActive: activeMenu == "SETTINGS" || activeMenu == "3",
                      onTap: () => sidebarState.setActiveMenu("SETTINGS"),
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
