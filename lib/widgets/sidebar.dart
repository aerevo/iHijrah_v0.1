// lib/widgets/sidebar.dart (SLIM MODE: 72px WIDTH)
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
    // FRANCOIS UPDATE: Force slim width (72.0) untuk maksimalkan ruang Feed
    this.dockWidth = 72.0, 
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

  // --- BUILD MENU ITEM (SLIM VERSION) ---
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
          padding: const EdgeInsets.symmetric(vertical: 10), // Reduced vertical padding
          decoration: BoxDecoration(
            color: isActive ? kPrimaryGold.withOpacity(0.15) : Colors.transparent,
            border: isActive 
              ? const Border(left: BorderSide(color: kPrimaryGold, width: 3)) 
              : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ SLIM MODE ICON SIZE
              MetallicGold(
                child: Icon(
                  icon,
                  color: isComingSoon 
                    ? Colors.grey.withOpacity(0.5) 
                    : (isActive ? Colors.white : Colors.white.withOpacity(0.7)),
                  size: 22 // Resize from 24 -> 22
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: TextStyle(
                  color: isComingSoon 
                    ? Colors.grey.withOpacity(0.5) 
                    : (isActive ? kPrimaryGold : kTextSecondary.withOpacity(0.7)),
                  fontSize: 8.5, // Resize from 9 -> 8.5
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
              // === 1. PROFILE SECTION (SLIM ADJUSTED) ===
              Padding(
                padding: const EdgeInsets.only(top: 25, bottom: 5),
                child: Consumer<UserModel>(
                  builder: (context, user, _) {
                    String rawAgeString = "";
                    if (user.hijriDOB != null && user.hijriDOB!.isNotEmpty) {
                      rawAgeString = HijriService.calculateHijriAge(user.hijriDOB!);
                    }
                    if (rawAgeString.isEmpty || rawAgeString == "-- Tahun" || rawAgeString == "Format Salah") {
                      if (user.birthdate != null) {
                        try {
                          final hijri = HijriService.fromDate(user.birthdate!);
                          final manualHijriString = '${hijri.hDay}/${hijri.hMonth}/${hijri.hYear}';
                          rawAgeString = HijriService.calculateHijriAge(manualHijriString);
                        } catch (e) {
                          rawAgeString = "Ralat";
                        }
                      } else {
                        rawAgeString = "Tetapkan Tarikh";
                      }
                    }

                    String ageYearOnly = "--";
                    bool isValidAge = rawAgeString.contains(RegExp(r'\d')); 
                    if (isValidAge) {
                      final match = RegExp(r'(\d+)').firstMatch(rawAgeString);
                      if (match != null) {
                        ageYearOnly = match.group(1)!;
                      }
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Profile Picture - Dikecilkan sikit
                        Container(
                          width: 42, // Resize from 50 -> 42
                          height: 42,
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

                        // User Name (Shortened)
                        MetallicGold(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Text(
                              user.name.isNotEmpty
                                ? (user.name.length > 7 ? '${user.name.substring(0, 6)}..' : user.name)
                                : "User",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10, // Smaller Font
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Playfair',
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // --- DISPLAY UMUR ---
                        isValidAge 
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "$ageYearOnly Thn", // Shortened "Tahun" -> "Thn"
                                style: TextStyle(
                                  color: kPrimaryGold.withOpacity(0.9),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                "Hijriah",
                                style: TextStyle(
                                  color: kTextSecondary.withOpacity(0.6),
                                  fontSize: 7,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                rawAgeString, 
                                style: TextStyle(
                                  color: kTextSecondary.withOpacity(0.7),
                                  fontSize: 8,
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

              // === 2. TREE SECTION (SLIM ADJUSTED) ===
              Consumer<UserModel>(
                builder: (context, user, _) {
                  return InkWell(
                    onTap: () {
                      Provider.of<SidebarStateModel>(context, listen: false)
                        .setActiveMenu('tree_progress');
                    },
                    child: Container(
                      height: 70, // Reduced height
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 35, // Smaller glow
                            height: 35,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryGold.withOpacity(0.15),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            _getTreeAsset(user.treeLevel),
                            fit: BoxFit.contain,
                            height: 50, // Smaller tree
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
                                fontSize: 7,
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
                    fontSize: 6,
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
