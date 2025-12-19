// lib/widgets/sidebar.dart (ICON EMAS BOOSTED)

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
    this.dockWidth = AppSizes.sidebarWidth, 
    this.backgroundColor = Colors.transparent, 
  }) : super(key: key);

  // --- WHATSAPP LOGIC ---
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
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: kPrimaryGold, width: 1)),
          title: const Text("Infaq Pembangunan",
              textAlign: TextAlign.center,
              style: TextStyle(color: kPrimaryGold, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.handshake, size: 50, color: kPrimaryGold),
              const SizedBox(height: 16),
              const Text(
                "Bantu kami membangunkan app iHijrah dengan lebih canggih. Sumbangan tuan/puan amat bermakna.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _launchWhatsApp(context);
                },
                icon: const Icon(Icons.chat),
                label: const Text("WhatsApp Admin"),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    final sidebarState = Provider.of<SidebarStateModel>(context);
    final bool isOpen = sidebarState.activeMenuId != null;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Hitung Umur Hijrah
    String ageDisplay = "-- Tahun";
    if (user.hijriDOB != null) {
      ageDisplay = HijriService.calculateHijriAge(user.hijriDOB!);
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      left: isOpen ? 0 : - (screenWidth - dockWidth), 
      top: 0,
      bottom: 0,
      width: screenWidth, 
      child: Row(
        children: [
          // 1. PANEL UTAMA (SIDEBAR MENU)
          Expanded(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.85),
                  child: Column(
                    children: [
                      // PROFILE HEADER
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: kCardDark,
                              backgroundImage: user.avatarPath != null 
                                ? FileImage(File(user.avatarPath!)) 
                                : const AssetImage(AppAssets.profileDefault) as ImageProvider,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(ageDisplay, style: const TextStyle(color: kPrimaryGold, fontSize: 12)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings, color: Colors.white54),
                              onPressed: () {},
                            )
                          ],
                        ),
                      ),

                      // MENU ITEMS
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          children: [
                            _buildMenuItem(context, icon: Icons.mosque, title: 'Utama', id: ''), // Reset
                            _buildMenuItem(context, icon: Icons.history_edu, title: 'Sirah', id: 'sirah'),
                            _buildMenuItem(context, icon: Icons.calendar_month, title: 'Kalendar', id: 'kalendar'),
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
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. DOCK SIDEBAR (SENTIASA KELIHATAN)
          Container(
            width: dockWidth,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black, // Solid Black untuk kontras tinggi
              border: Border(left: BorderSide(color: Colors.white.withOpacity(0.1))),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryGold.withOpacity(0.1), // Sedikit glow emas di tepi
                  blurRadius: 10,
                  offset: const Offset(-5, 0)
                )
              ]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: isOpen 
                    ? const Icon(Icons.close, color: Colors.white54)
                    : const Icon(Icons.menu, color: kPrimaryGold),
                  onPressed: () {
                    sidebarState.toggleMenu('menu'); 
                  },
                ),
                const SizedBox(height: 20),
                // Rotated Text
                RotatedBox(
                  quarterTurns: 3,
                  child: Text(
                    "iHIJRAH",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      letterSpacing: 3,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {
    required IconData icon, 
    required String title, 
    required String id,
    bool isComingSoon = false
  }) {
    final sidebarState = Provider.of<SidebarStateModel>(context, listen: false);

    return ListTile(
      leading: MetallicGold(
        // ✅ FIX 4: ICON EMAS DIBOOST
        // isLightMode: true (Paksa guna palet emas cerah)
        isLightMode: true, 
        child: Icon(
          icon, 
          size: 26, 
          color: Colors.white, // Base putih penting untuk ShaderMask
          shadows: const [
            // Tambah Shadow Emas supaya ikon nampak "Bloom" / Bercahaya
            BoxShadow(
              color: kPrimaryGold, 
              blurRadius: 10, 
              spreadRadius: 2
            )
          ],
        ),
      ),
      title: Text(
        title, 
        style: const TextStyle(color: Colors.white70, fontSize: 14)
      ),
      trailing: isComingSoon 
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(4)
            ),
            child: const Text("SOON", style: TextStyle(fontSize: 8, color: Colors.white54))
          )
        : null,
      onTap: () {
        if (!isComingSoon) {
          sidebarState.toggleMenu(id);
        }
      },
    );
  }
}
