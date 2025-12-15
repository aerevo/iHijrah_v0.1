// lib/widgets/sidebar.dart (FIXED: Syntax Error Resolved + Golden Icons)
import 'dart:io';
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
    this.dockWidth = AppSizes.sidebarWidth,
    this.backgroundColor = kCardDark
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
        backgroundColor: kCardDark,
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
            const SizedBox(height: AppSpacing.sm),
            const Text(
              "Kami akan berikan maklumat bank/FPX melalui WhatsApp untuk keselamatan data Tuan dan mematuhi dasar Google Play.",
              style: TextStyle(
                color: kTextSecondary,
                fontSize: AppFontSizes.xs,
                fontStyle: FontStyle.italic
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Tutup",
              style: TextStyle(color: kTextSecondary)
            )
          )
        ],
      ),
    );
  }

  // --- GET TREE ASSET ---
  String _getTreeAsset(int level) {
    if (level <= 1) return AppAssets.treePhase1;
    if (level <= 3) return AppAssets.treePhase2;
    if (level <= 5) return AppAssets.treePhase3;
    if (level <= 8) return AppAssets.treePhase4;
    return AppAssets.treePhase5;
  }

  // --- BUILD MENU ITEM (WITH GOLDEN SHIMMER ICONS) ---
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? kPrimaryGold.withOpacity(0.15) : Colors.transparent,
            border: isActive 
              ? const Border(left: BorderSide(color: kPrimaryGold, width: 3)) 
              : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ GOLDEN SHIMMER ICON
              MetallicGold(
                child: Icon(
                  icon,
                  color: isComingSoon 
                    ? Colors.grey.withOpacity(0.5) 
                    : (isActive ? Colors.white : Colors.white.withOpacity(0.7)),
                  size: 24
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isComingSoon 
                    ? Colors.grey.withOpacity(0.5) 
                    : (isActive ? kPrimaryGold : kTextSecondary.withOpacity(0.7)),
                  fontSize: 9
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
    return Container(
      width: dockWidth + 1,
      height: MediaQuery.of(context).size.height,
      color: backgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // === 1. PROFILE SECTION ===
              Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 5),
                child: Consumer<UserModel>(
                  builder: (context, user, _) {
                    // Logic Umur Hijrah
                    String displayAge = "";
                    if (user.hijriDOB != null && user.hijriDOB!.isNotEmpty) {
                      displayAge = HijriService.calculateHijriAge(user.hijriDOB!);
                    }
                    if (displayAge.isEmpty || displayAge == "-- Tahun" || displayAge == "Format Salah") {
                      if (user.birthdate != null) {
                        try {
                          final hijri = HijriService.fromDate(user.birthdate!);
                          final manualHijriString = '${hijri.hDay}/${hijri.hMonth}/${hijri.hYear}';
                          displayAge = HijriService.calculateHijriAge(manualHijriString);
                        } catch (e) {
                          displayAge = "Ralat";
                        }
                      } else {
                        displayAge = "Tetapkan Tarikh";
                      }
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Profile Picture
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: kPrimaryGold, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
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

                        const SizedBox(height: 5),

                        // User Name
                        MetallicGold(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              user.name.isNotEmpty
                                ? (user.name.length > 8 ? '${user.name.substring(0, 7)}...' : user.name)
                                : "Pengguna",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Playfair',
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        // Hijri Age
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              displayAge,
                              style: TextStyle(
                                color: kPrimaryGold.withOpacity(0.9),
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
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
                      height: 80,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow Effect
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryGold.withOpacity(0.15),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          // Tree Image
                          Image.asset(
                            _getTreeAsset(user.treeLevel),
                            fit: BoxFit.contain,
                            height: 60,
                            errorBuilder: (ctx, _, __) => const Icon(
                              Icons.forest,
                              color: kPrimaryGold,
                              size: 40
                            ),
                          ),
                          // Level Text
                          Positioned(
                            bottom: 0,
                            child: Text(
                              "LVL ${user.treeLevel}",
                              style: TextStyle(
                                color: kPrimaryGold.withOpacity(0.8),
                                fontSize: 8,
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

              const Divider(color: Colors.white10, height: 1, thickness: 1),

              // === 3. MENU ICONS ===
              _buildMenuItem(context, icon: Icons.calendar_month, title: 'Kalendar', id: 'kalendar'),
              _buildMenuItem(context, icon: Icons.menu_book, title: 'Sirah', id: 'sirah'),
              _buildMenuItem(context, icon: Icons.cake, title: 'H.Jadi', id: 'birthday'),
              _buildMenuItem(context, icon: Icons.event, title: 'Peristiwa', id: 'peristiwa'),
              _buildMenuItem(context, icon: Icons.notifications, title: 'Notifikasi', id: 'notifikasi'),
              _buildMenuItem(context, icon: Icons.person, title: 'Profil', id: 'profil'),

              const SizedBox(height: 10),

              // Coming Soon Section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "COMING SOON",
                  style: TextStyle(
                    fontSize: 7,
                    color: Colors.white.withOpacity(0.2),
                    letterSpacing: 1
                  )
                ),
              ),
              _buildMenuItem(context, icon: Icons.mosque, title: 'Qiblat', id: 'qiblat', isComingSoon: true),
              _buildMenuItem(context, icon: Icons.book, title: 'Quran', id: 'quran', isComingSoon: true),

              const SizedBox(height: 20),

              // Bottom Actions
              _buildMenuItem(context, icon: Icons.favorite, title: 'Infaq', id: 'infaq'),
              _buildMenuItem(context, icon: Icons.info, title: 'Info', id: 'info'),

              const SizedBox(height: 20),

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
    );
  }
}
