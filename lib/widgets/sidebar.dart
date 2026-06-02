// lib/widgets/sidebar.dart

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/sidebar_state_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart';
import 'living_tree.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  final String _whatsappNumber = '+60133662440';
  final String _whatsappMessage = 'Assalamualaikum Admin, saya berminat untuk membuat Infaq Pembangunan iHijrah.';

  Future<void> _launchWhatsApp(BuildContext context) async {
    final url = 'whatsapp://send?phone=$_whatsappNumber&text=${Uri.encodeComponent(_whatsappMessage)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _showInfaqDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCardDark.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg)),
        title: const MetallicGold(child: Text('Infaq Pembangunan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Sumbangan anda amat dihargai untuk pembangunan iHijrah.", style: TextStyle(color: kTextSecondary, fontSize: AppFontSizes.sm)),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () => _launchWhatsApp(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
                ),
                child: const Text("WhatsApp Admin", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTreeAsset(int level) {
    if (level <= 1) return 'assets/videos/tree_v1.mp4';
    if (level <= 3) return 'assets/videos/tree_v2.mp4';
    return 'assets/videos/tree_v1.mp4';
  }

  // ── FLOATING MENU ITEM (PILL STYLE) ───────────────────────
  Widget _buildFloatingMenuItem(BuildContext context, {required IconData icon, required String title, required String id, bool isComingSoon = false}) {
    final model = Provider.of<SidebarStateModel>(context);
    final isActive = model.activeMenuId == id;

    return InkWell(
      onTap: isComingSoon ? null : () {
        model.setActiveMenu(id);
        // TIP: Jika mahu menu auto-close lepas klik, nyah-komen baris bawah:
        // model.isVisible = false; // atau model.toggleVisibility();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryGold.withOpacity(0.15) : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? kPrimaryGold.withOpacity(0.4) : Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            MetallicGold(
              child: Icon(
                icon,
                color: isComingSoon ? Colors.grey.withOpacity(0.3) : (isActive ? kPrimaryGold : Colors.white70),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isComingSoon ? Colors.grey.withOpacity(0.3) : (isActive ? kPrimaryGold : Colors.white),
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (isActive) const Spacer(),
            if (isActive)
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: kPrimaryGold,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SidebarStateModel>(
      builder: (context, model, child) {
        // LOGIK ANIMASI: Jika visible, yOffset = 0. Jika tidak, yOffset = -500 (sembunyi ke atas)
        final double yOffset = model.isVisible ? 0.0 : -500.0;

        return GestureDetector(
          // LOGIK SWIPE: Swipe ke bawah (velocity positif) untuk tutup menu
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null && details.primaryVelocity! > 0 && model.isVisible) {
              // Gantikan dengan method sebenar dalam model anda untuk tutup sidebar
              // Contoh: model.toggleVisibility(); atau model.isVisible = false;
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutQuart, // Animasi smooth & premium
            transform: Matrix4.translationValues(0, yOffset, 0),
            width: double.infinity,
            height: 500, // Ruang tinggi untuk panel
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 340, // Lebar panel terapung (floating)
                margin: const EdgeInsets.only(top: 60), // Jarak dari atas skrin (elak status bar)
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 25,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0), // Kesan kaca blur
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── DRAG HANDLE (Visual Cue) ───────────────────────
                          Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),

                          // ── PROFILE HEADER ─────────────────────────────────
                          Consumer<UserModel>(
                            builder: (context, user, _) {
                              String displayAge = user.hijriAge;
                              String fullName = user.name.isNotEmpty ? user.name : "User";
                              List<String> nameParts = fullName.trim().split(' ');
                              String firstName = nameParts.isNotEmpty ? nameParts.first : "";
                              String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : "";

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: kPrimaryGold.withOpacity(0.7), width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: kPrimaryGold.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: (user.avatarPath != null && user.avatarPath!.isNotEmpty)
                                          ? Image.file(
                                              File(user.avatarPath!),
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Image.asset(AppAssets.profileDefault, fit: BoxFit.cover),
                                            )
                                          : Image.asset(AppAssets.profileDefault, fit: BoxFit.cover),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  MetallicGold(
                                    child: Text(
                                      firstName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                  if (lastName.isNotEmpty)
                                    Text(
                                      lastName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: kPrimaryGold.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: kPrimaryGold.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      displayAge,
                                      style: const TextStyle(color: kPrimaryGold, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 16),
                          const Divider(color: Colors.white12, height: 1),
                          const SizedBox(height: 16),

                          // ── POKOK MENU (Floating Card) ─────────────────────
                          Consumer<UserModel>(
                            builder: (context, user, _) {
                              return InkWell(
                                onTap: () => model.setActiveMenu('tree_progress'),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            IgnorePointer(
                                              child: LivingTree(
                                                assetPath: _getTreeAsset(user.treeLevel),
                                                height: 35,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Pokok Amalan",
                                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              "LVL ${user.treeLevel}",
                                              style: TextStyle(color: kPrimaryGold.withOpacity(0.8), fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // ── MENU ITEMS (FLOATING PILLS) ────────────────────
                          _buildFloatingMenuItem(context, icon: Icons.calendar_month, title: 'Kalendar', id: 'kalendar'),
                          _buildFloatingMenuItem(context, icon: Icons.menu_book, title: 'Sirah', id: 'sirah'),
                          _buildFloatingMenuItem(context, icon: Icons.volunteer_activism, title: 'Amalan', id: 'amalan'),
                          _buildFloatingMenuItem(context, icon: Icons.cake, title: 'H.Jadi', id: 'birthday'),
                          _buildFloatingMenuItem(context, icon: Icons.notifications, title: 'Notifikasi', id: 'notifikasi'),
                          _buildFloatingMenuItem(context, icon: Icons.person, title: 'Profil', id: 'profil'),
                          
                          const SizedBox(height: 8),
                          const Divider(color: Colors.white12, height: 1),
                          const SizedBox(height: 8),

                          _buildFloatingMenuItem(context, icon: Icons.favorite, title: 'Infaq', id: 'infaq'),
                          _buildFloatingMenuItem(context, icon: Icons.info, title: 'Info', id: 'info'),
                          
                          const SizedBox(height: 16),
                        ],
                      ),
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
