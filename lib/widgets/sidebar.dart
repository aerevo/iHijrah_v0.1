// lib/widgets/sidebar.dart (LINE 1-10)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/sidebar_state_model.dart';  // ✅ Naik satu level
import '../utils/constants.dart';
import 'metallic_gold.dart';                  // ✅ Same level
import 'embun_ui/embun_ui.dart';              // ✅ Subfolder dalam widgets/

class Sidebar extends StatelessWidget {
  final double dockWidth;
  final Color backgroundColor;

  const Sidebar({
    Key? key,
    this.dockWidth = AppSizes.sidebarWidth,
    this.backgroundColor = kCardDark
  }) : super(key: key);

  // --- LOGIC: WHATSAPP ADMIN & INFAQ ---
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
             const SnackBar(content: Text("Ralat: Tidak dapat buka WhatsApp."), backgroundColor: kWarningRed)
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg)),
        title: const MetallicGold(
          child: Text('Infaq Pembangunan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Playfair')
          )
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Projek iHijrah dibangunkan atas dasar sukarela. Sumbangan anda membantu kos hosting, API, dan pembangunan ciri-ciri akan datang.",
              style: TextStyle(color: kTextSecondary, fontSize: AppFontSizes.sm, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.md),

            const MetallicGold(child: Text("Sila Hubungi Admin:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            const SizedBox(height: AppSpacing.sm),

            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeightMd,
              // ✅ CELEBRATION BUTTON UTK INFAQ
              child: CelebrationButton(
                onPressed: () => _launchWhatsApp(context),
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
            const SizedBox(height: AppSpacing.sm),
            const Text(
              "Kami akan berikan maklumat bank/FPX melalui WhatsApp untuk keselamatan data Tuan dan mematuhi dasar Google Play.",
              style: TextStyle(color: kTextSecondary, fontSize: AppFontSizes.xs, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: kTextSecondary))
          )
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dockWidth + 1,
      height: MediaQuery.of(context).size.height,
      color: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 25),
              child: MetallicGold(
                child: Icon(Icons.diamond_outlined, size: 30, color: Colors.white)
              ),
            ),

            _buildMenuItem(context, icon: Icons.person, title: 'Profil', id: 'profil'),
            _buildMenuItem(context, icon: Icons.calendar_month, title: 'Kalendar', id: 'kalendar'),
            _buildMenuItem(context, icon: Icons.event, title: 'Peristiwa', id: 'peristiwa'),
            _buildMenuItem(context, icon: Icons.notifications, title: 'Notifikasi', id: 'notifikasi'),

            const Spacer(),

            _buildMenuItem(context, icon: Icons.favorite, title: 'Infaq', id: 'infaq'),
            _buildMenuItem(context, icon: Icons.info, title: 'Info', id: 'info'),
            const SizedBox(height: 20),

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
    );
  }
}