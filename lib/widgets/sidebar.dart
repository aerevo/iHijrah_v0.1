// lib/widgets/sidebar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:rive/rive.dart';

import '../models/user_model.dart';
import '../models/sidebar_state_model.dart';
import '../utils/constants.dart';

// Imports Asal Kapten
import 'metallic_gold.dart';           
import 'embun_ui/embun_ui.dart';       

class Sidebar extends StatefulWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  // --- LOGIK ASAL: WHATSAPP & INFAQ ---
  final String _whatsappNumber = '+60133662440';
  final String _whatsappMessage = 'Assalamualaikum Admin, saya berminat untuk membuat Infaq Pembangunan iHijrah.';

  Future<void> _launchWhatsApp(BuildContext context) async {
    final url = 'whatsapp://send?phone=$_whatsappNumber&text=${Uri.encodeComponent(_whatsappMessage)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // Fallback web
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
              // Fallback button kalau CelebrationButton tak jumpa, tapi patut ada sbb import
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

  // --- LOGIK BARU: UMUR HIJRAH ---
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
    
    // Check state expanded
    final bool isExpanded = sidebarState.isSidebarExpanded;

    String userName = userModel.name.isNotEmpty ? userModel.name : "Hamba Allah";
    String hijrahAge = _calculateHijrahAge(userModel.birthdate);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      width: sidebarState.currentSidebarWidth, // Guna width dari model
      color: const Color(0xFF17203A),
      height: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            // --- 1. TOGGLE BUTTON (ARROW) ---
            Align(
              alignment: isExpanded ? Alignment.centerRight : Alignment.center,
              child: IconButton(
                icon: Icon(isExpanded ? Icons.chevron_left : Icons.chevron_right, color: Colors.white54),
                onPressed: () => sidebarState.toggleSidebarSize(),
              ),
            ),

            // --- 2. PROFIL HEADER (FADE IN/OUT) ---
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: isExpanded ? 24 : 10, vertical: 20),
              child: Column(
                children: [
                  // Gambar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: isExpanded ? 70 : 40,
                    width: isExpanded ? 70 : 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kPrimaryGold, width: 2),
                      boxShadow: isExpanded ? [BoxShadow(color: kPrimaryGold.withOpacity(0.3), blurRadius: 10)] : [],
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white10,
                      backgroundImage: AssetImage('assets/images/profile_default.png'),
                      onBackgroundImageError: (_,__) {},
                    ),
                  ),
                  
                  // Detail Text (Fade Logic)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isExpanded ? 1.0 : 0.0,
                    child: isExpanded ? Column(
                      children: [
                        const SizedBox(height: 12),
                        Text(userName, 
                          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 16),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Text("$hijrahAge Thn Hijrah", style: const TextStyle(color: kPrimaryGold, fontSize: 10)),
                        ),
                      ],
                    ) : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.white.withOpacity(0.1)),

            // --- 3. MENU LIST ---
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 8),
                children: [
                  _buildMenuTile(
                    title: "Utama", riveIcon: "HOME", 
                    isActive: sidebarState.activeMenuId == "HOME", 
                    isExpanded: isExpanded,
                    onTap: () => sidebarState.setActiveMenu("HOME"),
                  ),
                  _buildMenuTile(
                    title: "Carian", riveIcon: "SEARCH", 
                    isActive: sidebarState.activeMenuId == "SEARCH", 
                    isExpanded: isExpanded,
                    onTap: () => sidebarState.setActiveMenu("SEARCH"),
                  ),
                  _buildMenuTile(
                    title: "Notifikasi", riveIcon: "BELL", 
                    isActive: sidebarState.activeMenuId == "BELL", 
                    isExpanded: isExpanded,
                    onTap: () => sidebarState.setActiveMenu("BELL"),
                  ),
                  _buildMenuTile(
                    title: "Infaq", riveIcon: "LIKE", // Atau ikon lain
                    isActive: false, // Infaq tak set active state biasanya
                    isExpanded: isExpanded,
                    onTap: () => _showInfaqDialog(context), // PANGGIL DIALOG ASAL
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
    required bool isActive, required bool isExpanded, required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 50,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryGold.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isActive ? Border.all(color: kPrimaryGold.withOpacity(0.5)) : null,
        ),
        child: Row(
          mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 36, width: 36,
              child: RiveAnimation.asset(
                "assets/RiveAssets/icons.riv",
                artboard: riveIcon,
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
            if (isExpanded) ...[
              const SizedBox(width: 12),
              Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.white70)),
            ]
          ],
        ),
      ),
    );
  }
}
