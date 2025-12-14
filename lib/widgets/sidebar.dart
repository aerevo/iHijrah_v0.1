// lib/widgets/sidebar.dart (VISUAL FIX)
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

  // ... (Kekalkan kod _whatsappNumber, _launchWhatsApp, _showInfaqDialog, _buildMenuItem seperti asal)
  // ... (Guna kod asal Kapten untuk bahagian LOGIC di atas, saya hanya update bahagian BUILD di bawah)
  
  // Sila pastikan _whatsappNumber, _launchWhatsApp dsb ada di sini...

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dockWidth + 1,
      height: MediaQuery.of(context).size.height,
      color: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // ✅ PROFILE SECTION (UPDATED & FIXED)
            Padding(
              padding: const EdgeInsets.only(top: 25, bottom: 15), // Jarak lebih selesa
              child: Consumer<UserModel>(
                builder: (context, user, _) {
                  
                  // Dapatkan umur Hijrah
                  String displayAge = HijriService.calculateHijriAge(user.hijriDOB ?? '');
                  
                  // Fallback jika kosong
                  if (displayAge == "-- Tahun" || displayAge.isEmpty) {
                    displayAge = "Tetapkan Tarikh";
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Profile Picture
                      Container(
                        width: 58, // Besar sikit dari 50
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kPrimaryGold, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 5)
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
                      
                      const SizedBox(height: 10),
                      
                      // User Name
                      MetallicGold(
                        child: Text(
                          user.name.isNotEmpty 
                            ? (user.name.length > 10 ? '${user.name.substring(0, 9)}...' : user.name)
                            : "Pengguna",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12, // Besar sikit dari 11
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Playfair',
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(height: 5),
                      
                      // ✅ HIJRI AGE (FIXED SIZE)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.05),
                           borderRadius: BorderRadius.circular(4)
                        ),
                        child: Text(
                          displayAge,
                          style: TextStyle(
                            color: kPrimaryGold.withOpacity(0.9), // Warna Emas, bukan grey
                            fontSize: 10, // Jauh lebih jelas dari 9
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            const Divider(color: Colors.white10, height: 1, thickness: 1),
            const SizedBox(height: 10),

            // ... (Kekalkan menu items di bawah)
            // SAYA LETAK CONTOH SAHAJA, GUNA YANG ASAL KAPTEN:
            _buildMenuItem(context, icon: Icons.person, title: 'Profil', id: 'profil'),
            _buildMenuItem(context, icon: Icons.calendar_month, title: 'Kalendar', id: 'kalendar'),
            // ... dan seterusnya
            
            const Spacer(),
            // ... butang Infaq, Info dsb
          ],
        ),
      ),
    );
  }
  
  // (Pastikan method _buildMenuItem ada di dalam class ini seperti asal)
   Widget _buildMenuItem(BuildContext context, {required IconData icon, required String title, required String id}) {
    final model = Provider.of<SidebarStateModel>(context);
    final isActive = model.activeMenuId == id;

    return Tooltip(
      message: title,
      child: InkWell(
        onTap: () => model.setActiveMenu(id),
        child: Container(
          width: dockWidth,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? kPrimaryGold.withOpacity(0.15) : Colors.transparent,
            border: isActive ? const Border(left: BorderSide(color: kPrimaryGold, width: 3)) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isActive ? kPrimaryGold : kTextSecondary.withOpacity(0.7), size: 24),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(color: isActive ? kPrimaryGold : kTextSecondary.withOpacity(0.7), fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
