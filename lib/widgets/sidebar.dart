import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/user_model.dart';
import '../models/sidebar_state_model.dart';
import '../utils/constants.dart';
import '../utils/audio_service.dart'; 
import 'metallic_gold.dart';
import 'embun_ui/embun_ui.dart'; 

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  // --- LOGIC: WHATSAPP & INFAQ ---
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
      }
    }
  }

  // --- DIALOG: INFAQ ---
  void _showInfaqDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A).withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const MetallicGold(
          child: Text('Infaq Pembangunan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Playfair')
          )
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Sumbangan anda membantu kos server & API untuk ciri akan datang.",
              style: TextStyle(color: kTextSecondary, fontSize: 12),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: CelebrationButton(
                onPressed: () {
                   Navigator.pop(ctx);
                   _launchWhatsApp(context);
                },
                backgroundColor: Colors.green.shade700,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.chat_bubble, color: Colors.white),
                    SizedBox(width: 8),
                    Text("WhatsApp Admin", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOG: LOCKED FEATURE (Coming Soon) ---
  void _showLockedDialog(BuildContext context, String featureName) {
    // 🔊 Bunyi: InsyaAllah (Respon lembut)
    Provider.of<AudioService>(context, listen: false).playInsyaallah();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A).withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_clock, color: kPrimaryGold),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Ciri Akan Datang',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Modul '$featureName' dikunci buat masa ini.",
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Kami sedang membangunkan ciri ini untuk fasa seterusnya. Ingin mempercepatkan pembangunan?",
              style: TextStyle(color: kTextSecondary, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 20),
            
            // Butang Support
            SizedBox(
              width: double.infinity,
              height: 45,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showInfaqDialog(context); // Redirect ke Infaq
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kPrimaryGold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Support Pembangunan", style: TextStyle(color: kPrimaryGold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sidebarState = Provider.of<SidebarStateModel>(context);
    final isExpanded = sidebarState.isSidebarExpanded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
      width: sidebarState.currentSidebarWidth,
      height: double.infinity,
      child: Stack(
        children: [
          // 1. BACKGROUND GLASS
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F0F).withOpacity(0.90),
                  border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
                ),
              ),
            ),
          ),

          // 2. CONTENT
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                
                // === HEADER: LOGO ===
                _buildHeader(context, sidebarState, isExpanded),
                
                const SizedBox(height: 15),

                // === SECTION 1: PROFIL ===
                Consumer<UserModel>(
                  builder: (context, user, _) => _buildProfileSection(user, isExpanded),
                ),

                const SizedBox(height: 10),

                // === SECTION 2: POKOK ===
                Consumer<UserModel>(
                  builder: (context, user, _) => _buildTreeSection(user, isExpanded),
                ),

                const SizedBox(height: 15),
                if (isExpanded) Divider(color: Colors.white.withOpacity(0.1), indent: 15, endIndent: 15),

                // === SECTION 3: MENU ITEMS (ACTIVE & LOCKED) ===
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- CIRI AKTIF ---
                        if (isExpanded) _buildSectionTitle("CIRI AKTIF"),
                        
                        // 1. Sirah Harian (ID: peristiwa)
                        _buildNavItem(context, 
                          icon: Icons.history_edu, 
                          id: 'peristiwa', 
                          label: 'Sirah Harian'
                        ),

                        // 2. Amalan Harian (ID: dashboard)
                        // Note: Dashboard kita mengandungi Tracker Amalan
                        _buildNavItem(context, 
                          icon: Icons.task_alt, 
                          id: 'dashboard', 
                          label: 'Amalan Harian'
                        ),

                        const SizedBox(height: 20),
                        
                        // --- CIRI DIKUNCI (COMING SOON) ---
                        // Tajuk hanya muncul bila expand, bila tutup jadi ikon je
                        if (isExpanded) _buildSectionTitle("AKAN DATANG (LOCKED)"),

                        // 1. Hari Lahir Hijrah
                        _buildLockedItem(context, isExpanded, 
                          Icons.cake, "Ulangtahun Hijrah"
                        ),

                        // 2. Platform Niaga
                        _buildLockedItem(context, isExpanded, 
                          Icons.storefront, "Platform Niaga"
                        ),

                        // 3. Cari Ceramah
                        _buildLockedItem(context, isExpanded, 
                          Icons.podcasts, "Cari Ceramah"
                        ),
                      ],
                    ),
                  ),
                ),

                // === FOOTER ===
                if (isExpanded) Divider(color: Colors.white.withOpacity(0.1)),
                _buildNavItem(context, icon: Icons.favorite_border, id: 'infaq', label: 'Infaq', isSpecial: true),
                _buildNavItem(context, icon: Icons.info_outline, id: 'info', label: 'Info App'),
                const SizedBox(height: 10),
                
                // Logic Infaq Listener
                Consumer<SidebarStateModel>(
                  builder: (ctx, model, child) {
                    if (model.activeMenuId == 'infaq') {
                       WidgetsBinding.instance.addPostFrameCallback((_) {
                         model.handleInfaqMenu(); 
                         _showInfaqDialog(context);
                       });
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUB-WIDGETS
  // ---------------------------------------------------------------------------

  Widget _buildHeader(BuildContext context, SidebarStateModel state, bool isExpanded) {
    return InkWell(
      onTap: () {
        Provider.of<AudioService>(context, listen: false).playClick();
        state.toggleSidebar();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            const MetallicGold(child: Icon(Icons.diamond_outlined, size: 28, color: Colors.white)),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              const Expanded(
                child: Text("ZYAMINA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 3, fontSize: 14)),
              ),
              const Icon(Icons.chevron_left, color: Colors.white54),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(UserModel user, bool isExpanded) {
    String umurHijrah = "2 Tahun 3 Bulan"; 
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 15 : 0),
      child: Row(
        mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: kGoldGradientColors)),
            child: CircleAvatar(
              radius: isExpanded ? 24 : 18,
              backgroundColor: Colors.black,
              backgroundImage: user.avatarPath != null 
                ? FileImage(File(user.avatarPath!)) 
                : const AssetImage('assets/images/profile_default.png') as ImageProvider,
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const MetallicGold(
                    child: Text("Aer (Kapten)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.hourglass_bottom, size: 12, color: kPrimaryGold),
                      const SizedBox(width: 4),
                      Text("Umur Hijrah: $umurHijrah", style: const TextStyle(color: kPrimaryGold, fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildTreeSection(UserModel user, bool isExpanded) {
    int level = user.treeLevel > 4 ? 4 : (user.treeLevel < 1 ? 1 : user.treeLevel);
    String treeAsset = 'assets/images/pokok_level$level.png';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: isExpanded ? 15 : 5),
      padding: EdgeInsets.all(isExpanded ? 10 : 5),
      decoration: BoxDecoration(
        color: isExpanded ? Colors.white.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isExpanded ? Border.all(color: Colors.white10) : null,
      ),
      child: Column(
        children: [
          Image.asset(
            treeAsset,
            height: isExpanded ? 70 : 30,
            width: isExpanded ? 70 : 30,
            fit: BoxFit.contain,
            errorBuilder: (c, o, s) => const Icon(Icons.eco, color: kAccentOlive),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(value: 0.7, backgroundColor: Colors.black45, valueColor: AlwaysStoppedAnimation(kSuccessGreen), minHeight: 4),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("LVL ${user.treeLevel}", style: const TextStyle(color: kPrimaryGold, fontSize: 10, fontWeight: FontWeight.bold)),
                Text("READY", style: const TextStyle(color: Colors.white54, fontSize: 9)),
              ],
            )
          ]
        ],
      ),
    );
  }

  // --- BUILD ACTIVE NAV ITEM ---
  Widget _buildNavItem(BuildContext context, {
    required IconData icon, 
    required String id, 
    required String label, 
    bool isSpecial = false
  }) {
    final model = Provider.of<SidebarStateModel>(context);
    final isExpanded = model.isSidebarExpanded;
    final isActive = (id == 'dashboard') ? model.activeMenuId == null : model.activeMenuId == id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Provider.of<AudioService>(context, listen: false).playClick();
          if (id == 'dashboard') {
            model.closeMenu();
          } else {
            model.setActiveMenu(id);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: isExpanded ? 10 : 5, vertical: 2),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: isExpanded ? 10 : 0),
          decoration: BoxDecoration(
            color: isActive ? kGoldGradientColors[0].withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive ? Border.all(color: kPrimaryGold.withOpacity(0.4)) : null,
          ),
          child: Row(
            mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              isActive 
                ? MetallicGold(child: Icon(icon, size: 24, color: Colors.white))
                : Icon(icon, size: 24, color: isSpecial ? kSuccessGreen : Colors.white54),
              
              if (isExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label, style: TextStyle(
                    color: isActive ? kPrimaryGold : Colors.white70,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13
                  )),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // --- BUILD LOCKED ITEM (CLICKABLE) ---
  Widget _buildLockedItem(BuildContext context, bool isExpanded, IconData icon, String label) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // Bila tekan, keluar dialog
        onTap: () {
          _showLockedDialog(context, label);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: isExpanded ? 10 : 5, vertical: 2),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: isExpanded ? 10 : 0),
          child: Row(
            mainAxisAlignment: isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              // Ikon Kunci (Gelap sikit)
              Icon(icon, size: 24, color: Colors.white24),
              
              // Teks (Hanya bila Expand)
              if (isExpanded) ...[
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: const TextStyle(color: Colors.white30, fontSize: 13, fontStyle: FontStyle.italic))),
                const Icon(Icons.lock, size: 10, color: Colors.white24)
              ]
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 0, 5),
      child: Text(title, style: const TextStyle(color: kPrimaryGold, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
    );
  }
}