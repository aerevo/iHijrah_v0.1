// lib/widgets/sidebar.dart (FIXED UI & LOGIC)

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
import 'living_tree.dart'; 

class Sidebar extends StatelessWidget {
  final double dockWidth;
  final Color backgroundColor;

  const Sidebar({
    Key? key,
    this.dockWidth = AppSizes.sidebarWidth, 
    this.backgroundColor = Colors.transparent, 
  }) : super(key: key);

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
              child: CelebrationButton(
                onPressed: () => _launchWhatsApp(context),
                backgroundColor: Colors.green.shade700,
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

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required String id, bool isComingSoon = false}) {
    final model = Provider.of<SidebarStateModel>(context);
    final isActive = model.activeMenuId == id;

    return InkWell(
      onTap: isComingSoon ? null : () => model.setActiveMenu(id),
      child: Container(
        width: dockWidth,
        padding: const EdgeInsets.symmetric(vertical: 10),
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
                color: isComingSoon ? Colors.grey.withOpacity(0.3) : Colors.white, 
                size: 22, 
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: isComingSoon ? Colors.grey.withOpacity(0.3) : (isActive ? kPrimaryGold : kTextSecondary.withOpacity(0.6)),
                fontSize: 8, 
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
    return Consumer<SidebarStateModel>(
      builder: (context, model, child) {
        final double xOffset = model.isVisible ? 0.0 : -dockWidth;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          transform: Matrix4.translationValues(xOffset, 0, 0),
          width: dockWidth + 1,
          height: MediaQuery.of(context).size.height,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  border: Border(right: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // PROFILE HEADER (FIXED LOGIC)
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 5),
                          child: Consumer<UserModel>(
                            builder: (context, user, _) {
                              // Panggil getter hijriAge yang dah difix dalam UserModel
                              String displayAge = user.hijriAge;

                              String fullName = user.name.isNotEmpty ? user.name : "User";
                              List<String> nameParts = fullName.trim().split(' ');
                              String firstName = nameParts.isNotEmpty ? nameParts.first : "";
                              String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : "";

                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 38, height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: kPrimaryGold.withOpacity(0.7), width: 1.5),
                                    ),
                                    child: ClipOval(
                                      child: user.avatarPath.isNotEmpty
                                        ? Image.file(File(user.avatarPath), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset(AppAssets.profileDefault, fit: BoxFit.cover))
                                        : Image.asset(AppAssets.profileDefault, fit: BoxFit.cover),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  MetallicGold(
                                    child: Text(
                                      firstName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white, 
                                        fontSize: 11, 
                                        fontWeight: FontWeight.w900
                                      ),
                                    ),
                                  ),
                                  if (lastName.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 1.0),
                                      child: ShaderMask(
                                        shaderCallback: (bounds) => const LinearGradient(
                                          colors: [
                                            Color(0xFFB0BEC5), 
                                            Color(0xFFFFFFFF), 
                                            Color(0xFF78909C), 
                                            Color(0xFFFFFFFF), 
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          stops: [0.0, 0.45, 0.55, 1.0], 
                                        ).createShader(bounds),
                                        child: Text(
                                          lastName,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white, 
                                            fontSize: 9, 
                                            fontWeight: FontWeight.w900, 
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    displayAge,
                                    style: const TextStyle(color: kPrimaryGold, fontSize: 10, fontWeight: FontWeight.w500),
                                  ),
                                  Text("Hijriah", style: TextStyle(color: kTextSecondary.withOpacity(0.7), fontSize: 7, fontStyle: FontStyle.italic)),
                                ],
                              );
                            },
                          ),
                        ),
                        
                        // POKOK HIDUP (MENU)
                        Consumer<UserModel>(
                          builder: (context, user, _) {
                            return InkWell(
                              onTap: () => Provider.of<SidebarStateModel>(context, listen: false).setActiveMenu('tree_progress'),
                              child: Container(
                                height: 60,
                                width: dockWidth,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    IgnorePointer(
                                      child: LivingTree(
                                        assetPath: _getTreeAsset(user.treeLevel),
                                        height: 50, 
                                        onTap: null, 
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0, 
                                      child: Text(
                                        "LVL ${user.treeLevel}", 
                                        style: TextStyle(
                                          color: kPrimaryGold.withOpacity(0.9), 
                                          fontSize: 7, 
                                          fontWeight: FontWeight.w900,
                                          shadows: const [Shadow(color: Colors.black, blurRadius: 2)]
                                        )
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        Divider(color: Colors.white.withOpacity(0.1), height: 1),
                        
                        // === SENARAI MENU ===
                        _buildMenuItem(context, icon: Icons.calendar_month, title: 'Kalendar', id: 'kalendar'),
                        _buildMenuItem(context, icon: Icons.menu_book, title: 'Sirah', id: 'sirah'),
                        _buildMenuItem(context, icon: Icons.volunteer_activism, title: 'Amalan', id: 'amalan'),
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
                        
                        // Handler untuk Dialog Infaq
                        Consumer<SidebarStateModel>(
                          builder: (ctx, m, _) {
                            if (m.activeMenuId == 'infaq') {
                              WidgetsBinding.instance.addPostFrameCallback((_) { m.closeMenu(); _showInfaqDialog(context); });
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
