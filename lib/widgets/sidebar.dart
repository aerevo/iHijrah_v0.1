// lib/widgets/sidebar.dart (FULL CODE: ANIMATED SLIDE OUT)

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
      final webUrl = 'https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent(_whatsappMessage)}';
      if (await canLaunchUrl(Uri.parse(webUrl))) {
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Ralat: Tidak dapat buka WhatsApp."),
              backgroundColor: kWarningRed
            )
          );
        }
      }
    }
  }

  void _showInfaqDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kCardDark.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg)
        ),
        title: const MetallicGold(
          child: Text(
            'Infaq Pembangunan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Playfair'
            )
          )
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Projek iHijrah dibangunkan atas dasar sukarela. Sumbangan anda membantu kos hosting, API, dan pembangunan ciri-ciri akan datang.",
              style: TextStyle(
                color: kTextSecondary,
                fontSize: AppFontSizes.sm,
                height: 1.5
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            const MetallicGold(
              child: Text(
                "Sila Hubungi Admin:",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600
                )
              )
            ),
            const SizedBox(height: AppSpacing.sm),

            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeightMd,
              child: CelebrationButton(
                onPressed: () => _launchWhatsApp(context),
                backgroundColor: Colors.green.shade700,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.chat_bubble, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "WhatsApp Admin",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      )
                    ),
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
    if (level <= 1) return AppAssets.treePhase1;
    if (level <= 3) return AppAssets.treePhase2;
    if (level <= 5) return AppAssets.treePhase3;
    if (level <= 8) return AppAssets.treePhase4;
    return AppAssets.treePhase5;
  }

  // --- BUILD MENU ITEM ---
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String id,
    bool isComingSoon = false
  }) {
    final model = Provider.of<SidebarStateModel>(context);
    final isActive = model.activeMenuId == id;

    return Tooltip(
      message: isComingSoon ? "$title (Akan Datang)" : title,
      child: InkWell(
        onTap: isComingSoon ? null : () => model.setActiveMenu(id),
        child: Container(
          width: dockWidth,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.08) : Colors.transparent,
            border: isActive 
              ? Border(left: BorderSide(color: kPrimaryGold.withOpacity(0.8), width: 2)) 
              : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MetallicGold(
                child: Icon(
                  icon,
                  color: isComingSoon 
                    ? Colors.grey.withOpacity(0.3) 
                    : (isActive ? Colors.white : Colors.white.withOpacity(0.6)),
                  size: 20 
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  color: isComingSoon 
                    ? Colors.grey.withOpacity(0.3) 
                    : (isActive ? kPrimaryGold : kTextSecondary.withOpacity(0.6)),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ CONSUMER BARU UNTUK VISIBILITY & ANIMASI
    return Consumer<SidebarStateModel>(
      builder: (context, model, child) {
        
        // Logik Animasi: Jika visible, offset 0. Jika tak, offset -60 (Sorok ke kiri)
        final double xOffset = model.isVisible ? 0.0 : -dockWidth;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300), // Kelajuan luncuran
          curve: Curves.easeInOut,
          transform: Matrix4.translationValues(xOffset, 0, 0), // Gerakkan X
          width: dockWidth + 1,
          height: MediaQuery.of(context).size.height,
          
          // KANDUNGAN SIDEBAR ASAL DI DALAM SINI
          child: ClipRect( 
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), 
              child: Container(
                width: dockWidth + 1,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3), 
                  border: Border(
                    right: BorderSide(
                      color: Colors.white.withOpacity(0.08), 
                      width: 1
                    ),
                  ),
                ),
                child: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // === 1. PROFILE SECTION ===
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 5),
                          child: Consumer<UserModel>(
                            builder: (context, user, _) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Profile Picture
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: kPrimaryGold.withOpacity(0.7), width: 1.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 5
                                        )
                                      ]
                                    ),
                                    child: ClipOval(
                                      child: user.avatarPath != null
                                        ? Image.file(
                                            File(user.avatarPath!),
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Image.asset(
                                              AppAssets.profileDefault,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Image.asset(
                                            AppAssets.profileDefault,
                                            fit: BoxFit.cover,
                                          ),
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  // User Name
                                  MetallicGold(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 2),
                                      child: Text(
                                        user.name.isNotEmpty
                                          ? (user.name.length > 6 ? '${user.name.substring(0, 5)}..' : user.name)
                                          : "User",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Playfair',
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        // === 2. TREE SECTION ===
                        Consumer<UserModel>(
                          builder: (context, user, _) {
                            return InkWell(
                              onTap: () {
                                Provider.of<SidebarStateModel>(context, listen: false)
                                  .setActiveMenu('tree_progress');
                              },
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: kPrimaryGold.withOpacity(0.1),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Image.asset(
                                      _getTreeAsset(user.treeLevel),
                                      fit: BoxFit.contain,
                                      height: 40,
                                      errorBuilder: (ctx, _, __) => const Icon(
                                        Icons.forest,
                                        color: kPrimaryGold,
                                        size: 30
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      child: Text(
                                        "LVL ${user.treeLevel}",
                                        style: TextStyle(
                                          color: kPrimaryGold.withOpacity(0.8),
                                          fontSize: 6,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        Divider(color: Colors.white.withOpacity(0.1), height: 1),

                        // === 3. MENU ICONS ===
                        _buildMenuItem(context, icon: Icons.calendar_month, title: 'Kalendar', id: 'kalendar'),
                        _buildMenuItem(context, icon: Icons.menu_book, title: 'Sirah', id: 'sirah'),
                        _buildMenuItem(context, icon: Icons.cake, title: 'H.Jadi', id: 'birthday'),
                        _buildMenuItem(context, icon: Icons.event, title: 'Peristiwa', id: 'peristiwa'),
                        _buildMenuItem(context, icon: Icons.notifications, title: 'Notifikasi', id: 'notifikasi'),
                        _buildMenuItem(context, icon: Icons.person, title: 'Profil', id: 'profil'),

                        const SizedBox(height: 5),

                        // Coming Soon
                        _buildMenuItem(context, icon: Icons.mosque, title: 'Qiblat', id: 'qiblat', isComingSoon: true),
                        _buildMenuItem(context, icon: Icons.book, title: 'Quran', id: 'quran', isComingSoon: true),

                        const SizedBox(height: 15),

                        // Bottom Actions
                        _buildMenuItem(context, icon: Icons.favorite, title: 'Infaq', id: 'infaq'),
                        _buildMenuItem(context, icon: Icons.info, title: 'Info', id: 'info'),

                        // Infaq Dialog Trigger
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
          ),
        );
      },
    );
  }
}
