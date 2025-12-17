// lib/widgets/sidebar.dart (OPTIMIZED FOR 60PX)
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/sidebar_state_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/hijri_service.dart';
import 'metallic_gold.dart';
import 'embun_ui/embun_ui.dart';

class Sidebar extends StatelessWidget {
  final double dockWidth;
  final Color backgroundColor;

  const Sidebar({
    Key? key,
    this.dockWidth = AppSizes.sidebarWidth, // Auto 60.0 dari constants
    this.backgroundColor = Colors.transparent, 
  }) : super(key: key);

  // --- WHATSAPP LOGIC ---
  final String _whatsappNumber = '+60133662440';
  final String _whatsappMessage = 'Assalamualaikum Admin, saya berminat untuk membuat Infaq Pembangunan iHijrah.';

  Future<void> _launchWhatsApp(BuildContext context) async {
    final url = 'whatsapp://send?phone=$_whatsappNumber&text=${Uri.encodeComponent(_whatsappMessage)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // Fallback
      debugPrint("WhatsApp error");
    }
  }

  void _showInfaqDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCardDark.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg)),
        title: const MetallicGold(child: Text('Infaq Pembangunan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Playfair'))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Projek iHijrah dibangunkan atas dasar sukarela. Sumbangan anda amat dihargai.", style: TextStyle(color: kTextSecondary, fontSize: AppFontSizes.sm)),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity, height: 40,
              child: ElevatedButton(
                onPressed: () => _launchWhatsApp(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("WhatsApp Admin"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTreeAsset(int level) {
    if (level <= 1) return AppAssets.treePhase1;
    if (level <= 3) return AppAssets.treePhase2;
    if (level <= 5) return AppAssets.treePhase3;
    if (level <= 8) return AppAssets.treePhase4;
    return AppAssets.treePhase5;
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required String id, bool isComingSoon = false}) {
    final model = Provider.of<SidebarStateModel>(context);
    final isActive = model.activeMenuId == id;

    return InkWell(
      onTap: isComingSoon ? null : () => model.setActiveMenu(id),
      child: Container(
        width: dockWidth,
        padding: const EdgeInsets.symmetric(vertical: 10), // Padding vertikal rapat sikit
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.08) : Colors.transparent,
          border: isActive ? Border(left: BorderSide(color: kPrimaryGold.withOpacity(0.8), width: 2)) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MetallicGold(
              child: Icon(
                icon,
                color: isComingSoon ? Colors.grey.withOpacity(0.3) : (isActive ? Colors.white : Colors.white.withOpacity(0.6)),
                size: 20 // Ikon kecil sikit (20px)
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: isComingSoon ? Colors.grey.withOpacity(0.3) : (isActive ? kPrimaryGold : kTextSecondary.withOpacity(0.6)),
                fontSize: 8, // Font kecil (8px)
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          width: dockWidth + 1,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border(right: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Section (Compressed)
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 5),
                    child: Consumer<UserModel>(
                      builder: (context, user, _) {
                        return Column(
                          children: [
                            Container(
                              width: 38, height: 38, // Avatar kecil (38px)
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: kPrimaryGold.withOpacity(0.7), width: 1.5),
                              ),
                              child: ClipOval(
                                child: Image.asset(AppAssets.profileDefault, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 4),
                            MetallicGold(
                              child: Text(
                                user.name.isNotEmpty ? (user.name.length > 6 ? '${user.name.substring(0, 5)}..' : user.name) : "User",
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Tree Section
                  Consumer<UserModel>(
                    builder: (context, user, _) {
                      return InkWell(
                        onTap: () => Provider.of<SidebarStateModel>(context, listen: false).setActiveMenu('tree_progress'),
                        child: Container(
                          height: 60, width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.asset(_getTreeAsset(user.treeLevel), fit: BoxFit.contain, height: 40),
                              Positioned(bottom: 0, child: Text("LVL ${user.treeLevel}", style: TextStyle(color: kPrimaryGold.withOpacity(0.8), fontSize: 6, fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  Divider(color: Colors.white.withOpacity(0.1), height: 1),

                  // Menu Icons
                  _buildMenuItem(context, icon: Icons.calendar_month, title: 'Kalendar', id: 'kalendar'),
                  _buildMenuItem(context, icon: Icons.menu_book, title: 'Sirah', id: 'sirah'),
                  _buildMenuItem(context, icon: Icons.cake, title: 'H.Jadi', id: 'birthday'),
                  _buildMenuItem(context, icon: Icons.event, title: 'Peristiwa', id: 'peristiwa'),
                  _buildMenuItem(context, icon: Icons.notifications, title: 'Notifikasi', id: 'notifikasi'),
                  _buildMenuItem(context, icon: Icons.person, title: 'Profil', id: 'profil'),
                  
                  const SizedBox(height: 5),
                  _buildMenuItem(context, icon: Icons.mosque, title: 'Qiblat', id: 'qiblat', isComingSoon: true),
                  _buildMenuItem(context, icon: Icons.book, title: 'Quran', id: 'quran', isComingSoon: true),
                  const SizedBox(height: 15),
                  _buildMenuItem(context, icon: Icons.favorite, title: 'Infaq', id: 'infaq'),
                  _buildMenuItem(context, icon: Icons.info, title: 'Info', id: 'info'),

                  // Infaq Trigger
                  Consumer<SidebarStateModel>(
                    builder: (ctx, model, child) {
                      if (model.activeMenuId == 'infaq') {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          model.closeMenu();
                          _showInfaqDialog(context);
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
    );
  }
}
