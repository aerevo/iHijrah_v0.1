// lib/components/side_menu.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:rive/rive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/user_model.dart';
import '../models/sidebar_state_model.dart';
import '../utils/constants.dart';

// Import Widget UI Embun (Jika ada)
import '../widgets/metallic_gold.dart'; 

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  // --- LOGIK WHATSAPP & INFAQ ---
  final String _whatsappNumber = '+60133662440';
  final String _whatsappMessage = 'Assalamualaikum Admin, saya berminat untuk membuat Infaq Pembangunan iHijrah.';

  Future<void> _launchWhatsApp(BuildContext context) async {
    final url = 'whatsapp://send?phone=$_whatsappNumber&text=${Uri.encodeComponent(_whatsappMessage)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      final webUrl = 'https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent(_whatsappMessage)}';
      if (await canLaunchUrl(Uri.parse(webUrl))) {
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Ralat: Tidak dapat buka WhatsApp."), backgroundColor: kWarningRed)
        );
      }
    }
  }

  void _showInfaqDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg)),
        title: const MetallicGold(
          child: Text('Infaq Pembangunan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Playfair')
          )
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Projek iHijrah dibangunkan atas dasar sukarela. Sumbangan anda membantu kos hosting, API, dan pembangunan ciri-ciri akan datang.",
              style: TextStyle(color: kTextSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.md),
            const MetallicGold(child: Text("Sila Hubungi Admin:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton( 
                onPressed: () => _launchWhatsApp(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble, color: Colors.white),
                    SizedBox(width: 8),
                    Text("WhatsApp Admin", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: kTextSecondary))
          )
        ],
      ),
    );
  }

  // --- LOGIK UMUR HIJRAH ---
  String _calculateHijrahAge(DateTime? dob) {
    if (dob == null) return "0";
    final HijriCalendar todayHijri = HijriCalendar.now();
    final HijriCalendar dobHijri = HijriCalendar.fromDate(dob);
    int age = todayHijri.hYear - dobHijri.hYear;
    if (todayHijri.hMonth < dobHijri.hMonth) age--;
    else if (todayHijri.hMonth == dobHijri.hMonth && todayHijri.hDay < dobHijri.hDay) age--;
    return age.toString();
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final sidebarState = Provider.of<SidebarStateModel>(context);

    String userName = userModel.name.isNotEmpty ? userModel.name : "Hamba Allah";
    String hijrahAge = _calculateHijrahAge(userModel.birthdate);

    return Container(
      color: const Color(0xFF17203A),
      height: double.infinity,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // --- HEADER: PROFIL BARU ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kPrimaryGold, width: 2),
                      boxShadow: [BoxShadow(color: kPrimaryGold.withOpacity(0.3), blurRadius: 10)],
                    ),
                    // [FIX] Buang 'const' di sini sebab ada onBackgroundImageError
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white10,
                      backgroundImage: const AssetImage('assets/images/profile_default.png'),
                      onBackgroundImageError: (_,__) {}, // Ini fungsi, tak boleh const
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    userName,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w300, fontFamily: 'Poppins'),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text("$hijrahAge Tahun Hijrah", style: const TextStyle(color: kPrimaryGold, fontSize: 12)),
                  ),
                ],
              ),
            ),
            
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
                  _buildMenuTile(
                    title: "Utama", riveIcon: "HOME", 
                    isActive: sidebarState.activeMenuId == "HOME",
                    onTap: () => sidebarState.setActiveMenu("HOME"),
                  ),
                  _buildMenuTile(
                    title: "Carian", riveIcon: "SEARCH", 
                    isActive: sidebarState.activeMenuId == "SEARCH",
                    onTap: () => sidebarState.setActiveMenu("SEARCH"),
                  ),
                  _buildMenuTile(
                    title: "Notifikasi", riveIcon: "BELL", 
                    isActive: sidebarState.activeMenuId == "BELL",
                    onTap: () => sidebarState.setActiveMenu("BELL"),
                  ),
                  // INFAQ MENU (Trigger Dialog)
                  _buildMenuTile(
                    title: "Infaq", riveIcon: "LIKE", 
                    isActive: false,
                    onTap: () => _showInfaqDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required String title, required String riveIcon, 
    required bool isActive, required VoidCallback onTap
  }) {
    return Column(
      children: [
        Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              height: 56, width: isActive ? 288 : 0, left: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF6792FF),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
            ListTile(
              onTap: onTap,
              leading: SizedBox(
                height: 34, width: 34,
                child: RiveAnimation.asset(
                  "assets/RiveAssets/icons.riv", artboard: riveIcon,
                  onInit: (artboard) {
                    try {
                      StateMachineController? controller = StateMachineController.fromArtboard(artboard, "State Machine");
                      if (controller != null) {
                        artboard.addController(controller);
                        (controller.findInput<bool>("active") as SMIBool).value = isActive;
                      }
                    } catch (e) {}
                  },
                ),
              ),
              title: Text(title, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}
