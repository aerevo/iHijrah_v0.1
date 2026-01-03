import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Import Models & Utils
import '../models/sidebar_state_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/hijri_service.dart';

// Import Widgets
import 'metallic_gold.dart';
import 'living_tree.dart'; 

class Sidebar extends StatelessWidget {
  final double dockWidth;
  final Color backgroundColor;

  const Sidebar({
    Key? key,
    this.dockWidth = AppSizes.sidebarWidth, 
    this.backgroundColor = Colors.transparent, 
  }) : super(key: key);

  // ══════════════════════════════════════════════════════════════
  // LOGIK WHATSAPP & INFAQ
  // ══════════════════════════════════════════════════════════════
  final String _whatsappNumber = '+60133662440';
  final String _whatsappMessage = 'Assalamualaikum Admin, saya berminat untuk membuat Infaq Pembangunan iHijrah.';

  Future<void> _launchWhatsApp(BuildContext context) async {
    final url = 'whatsapp://send?phone=$_whatsappNumber&text=${Uri.encodeComponent(_whatsappMessage)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // Fallback jika tiada WhatsApp installed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("WhatsApp tidak dijumpai")),
      );
    }
  }

  void _showInfaqDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E).withOpacity(0.95), // Dark Card
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: MetallicGold(
            child: Text(
              'INFAQ PEMBANGUNAN', 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)
            )
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Sumbangan anda amat dihargai untuk kelangsungan dakwah aplikasi ini.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 20),
            // Custom Button untuk elak error import
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () => _launchWhatsApp(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.message, size: 18),
                    SizedBox(width: 8),
                    Text("WhatsApp Admin", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTreeAsset(int level) {
    // Logik pokok membesar ikut level
    if (level <= 1) return 'assets/videos/tree_v1.mp4'; 
    if (level <= 3) return 'assets/videos/tree_v2.mp4'; 
    return 'assets/videos/tree_v1.mp4'; 
  }

  // ══════════════════════════════════════════════════════════════
  // MENU ITEM BUILDER (AAA GRADE - CLEANER)
  // ══════════════════════════════════════════════════════════════
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String id,
  }) {
    final model = Provider.of<SidebarStateModel>(context);
    final isActive = model.activeMenuId == id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => model.setActiveMenu(id),
        splashColor: kPrimaryGold.withOpacity(0.3),
        child: Container(
          width: dockWidth,
          padding: const EdgeInsets.symmetric(vertical: 12), // KONSISTEN 12px
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.08) : Colors.transparent,
            border: isActive 
              ? const Border(left: BorderSide(color: kPrimaryGold, width: 3))
              : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MetallicGold(
                child: Icon(
                  icon,
                  color: Colors.white, 
                  size: 24, // Ikon Besar sikit
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? kPrimaryGold : Colors.white.withOpacity(0.6),
                  fontSize: 9, // Font standard
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // SECTION DIVIDER (GARISAN PEMISAH HALUS)
  // ══════════════════════════════════════════════════════════════
  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white.withOpacity(0.15),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // BUILD UTAMA
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Consumer<SidebarStateModel>(
      builder: (context, model, child) {
        // Animasi Slide Keluar/Masuk
        final double xOffset = model.isVisible ? 0.0 : -dockWidth;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic, // Animasi lebih smooth
          transform: Matrix4.translationValues(xOffset, 0, 0),
          width: dockWidth, // Lebar tetap
          height: MediaQuery.of(context).size.height,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0), // Blur Kuat
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6), // Gelap sikit
                  border: Border(
                    right: BorderSide(
                      color: Colors.white.withOpacity(0.1), 
                      width: 1
                    )
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // ═══════════════════════════════════════════════
                        // 1. PROFILE HEADER (COMPACT - AAA GRADE)
                        // ═══════════════════════════════════════════════
                        Consumer<UserModel>(
                          builder: (context, user, _) {
                            // Logik Umur Hijriah
                            String rawAgeString = "";
                            if (user.hijriDOB != null && user.hijriDOB!.isNotEmpty) {
                              rawAgeString = HijriService.calculateHijriAge(user.hijriDOB!);
                            }
                            String ageDisplay = rawAgeString.contains(RegExp(r'\d')) 
                                ? "${RegExp(r'(\d+)').firstMatch(rawAgeString)?.group(1)}"
                                : "--";

                            // Nama Pendek (First Name Only)
                            String fullName = user.name.isNotEmpty ? user.name : "Kapten";
                            String firstName = fullName.trim().split(' ').first;

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Avatar Bulat
                                Container(
                                  width: 44, 
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: kPrimaryGold.withOpacity(0.8), 
                                      width: 2
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: kPrimaryGold.withOpacity(0.2),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: user.avatarPath != null
                                      ? Image.file(
                                          File(user.avatarPath!), 
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Image.asset(AppAssets.profileDefault, fit: BoxFit.cover),
                                        )
                                      : Image.asset(AppAssets.profileDefault, fit: BoxFit.cover),
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Nama (Emas)
                                MetallicGold(
                                  child: Text(
                                    firstName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white, 
                                      fontSize: 12, 
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                
                                const SizedBox(height: 4),
                                
                                // Umur + Hijriah (Baris yang sama)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "$ageDisplay Thn",
                                      style: TextStyle(
                                        color: kPrimaryGold.withOpacity(0.9), 
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      " • ",
                                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9),
                                    ),
                                    Text(
                                      "Hijriah",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6), 
                                        fontSize: 8,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // ═══════════════════════════════════════════════
                        // 2. POKOK HIDUP (SMALLER + BADGE)
                        // ═══════════════════════════════════════════════
                        Consumer<UserModel>(
                          builder: (context, user, _) {
                            return InkWell(
                              onTap: () => Provider.of<SidebarStateModel>(
                                context, 
                                listen: false
                              ).setActiveMenu('tree_progress'),
                              child: Container(
                                height: 48, // Saiz Compact
                                width: dockWidth,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Pokok
                                    IgnorePointer(
                                      child: LivingTree(
                                        assetPath: _getTreeAsset(user.treeLevel),
                                        height: 42, 
                                        onTap: null, 
                                      ),
                                    ),
                                    // Badge Level
                                    Positioned(
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: kPrimaryGold.withOpacity(0.5), width: 0.5),
                                        ),
                                        child: Text(
                                          "LVL ${user.treeLevel}",
                                          style: const TextStyle(
                                            color: kPrimaryGold,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        _buildSectionDivider(),

                        // ═══════════════════════════════════════════════
                        // SEKSYEN 1: AMALAN (Primary)
                        // ═══════════════════════════════════════════════
                        _buildMenuItem(
                          context, 
                          icon: Icons.calendar_month, 
                          title: 'Kalendar', 
                          id: 'kalendar'
                        ),
                        _buildMenuItem(
                          context, 
                          icon: Icons.volunteer_activism, 
                          title: 'Amalan', 
                          id: 'amalan'
                        ),
                        _buildMenuItem(
                          context, 
                          icon: Icons.cake, 
                          title: 'H.Jadi', 
                          id: 'birthday'
                        ),

                        _buildSectionDivider(),

                        // ═══════════════════════════════════════════════
                        // SEKSYEN 2: ILMU (Learning)
                        // ═══════════════════════════════════════════════
                        _buildMenuItem(
                          context, 
                          icon: Icons.menu_book, 
                          title: 'Sirah', 
                          id: 'sirah'
                        ),
                        _buildMenuItem(
                          context, 
                          icon: Icons.event, 
                          title: 'Peristiwa', 
                          id: 'peristiwa'
                        ),

                        _buildSectionDivider(),

                        // ═══════════════════════════════════════════════
                        // SEKSYEN 3: SISTEM (Settings)
                        // ═══════════════════════════════════════════════
                        _buildMenuItem(
                          context, 
                          icon: Icons.notifications, 
                          title: 'Notifikasi', 
                          id: 'notifikasi'
                        ),
                        _buildMenuItem(
                          context, 
                          icon: Icons.person, 
                          title: 'Profil', 
                          id: 'profil'
                        ),

                        const SizedBox(height: 8),

                        // ═══════════════════════════════════════════════
                        // BOTTOM ACTIONS (Special)
                        // ═══════════════════════════════════════════════
                        _buildMenuItem(
                          context, 
                          icon: Icons.favorite, 
                          title: 'Infaq', 
                          id: 'infaq'
                        ),
                        _buildMenuItem(
                          context, 
                          icon: Icons.info_outline, 
                          title: 'Info', 
                          id: 'info'
                        ),

                        const SizedBox(height: 16),

                        // Infaq Dialog Listener
                        Consumer<SidebarStateModel>(
                          builder: (ctx, m, _) {
                            // Jika menu 'infaq' ditekan
                            if (m.activeMenuId == 'infaq') {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                m.closeMenu(); // Tutup sidebar dulu
                                _showInfaqDialog(context); // Buka dialog
                              });
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
