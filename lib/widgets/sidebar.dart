// lib/widgets/sidebar.dart - ENHANCED INTERACTIVE SIDEBAR
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

class Sidebar extends StatefulWidget {
  final double dockWidth;
  final Color backgroundColor;
  
  const Sidebar({
    Key? key,
    this.dockWidth = AppSizes.sidebarWidth,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  String? _hoveredMenuId;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

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
        backgroundColor: kCardDark.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        ),
        title: const MetallicGold(
          child: Text(
            'Infaq Pembangunan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Playfair'
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Projek iHijrah dibangunkan atas dasar sukarela. Sumbangan anda amat dihargai.",
              style: TextStyle(
                color: kTextSecondary,
                fontSize: AppFontSizes.sm
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () => _launchWhatsApp(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  ),
                ),
                icon: const Icon(Icons.chat, size: AppSizes.iconSm),
                label: const Text("WhatsApp Admin"),
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

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          width: widget.dockWidth + 1,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.3),
              ],
            ),
            border: Border(
              right: BorderSide(
                color: kPrimaryGold.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Section - Enhanced
                  _buildProfileSection(),
                  
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Tree Section - Enhanced
                  _buildTreeSection(),
                  
                  Divider(
                    color: kPrimaryGold.withOpacity(0.2),
                    height: 1,
                    thickness: 1,
                  ),
                  
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Menu Icons - Enhanced
                  _buildMenuItem(
                    context,
                    icon: Icons.calendar_month,
                    title: 'Kalendar',
                    id: 'kalendar',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.menu_book,
                    title: 'Sirah',
                    id: 'sirah',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.cake,
                    title: 'H.Jadi',
                    id: 'birthday',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.event,
                    title: 'Peristiwa',
                    id: 'peristiwa',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications,
                    title: 'Notifikasi',
                    id: 'notifikasi',
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.person,
                    title: 'Profil',
                    id: 'profil',
                  ),
                  
                  const SizedBox(height: AppSpacing.xs),
                  
                  // Coming Soon Items
                  _buildMenuItem(
                    context,
                    icon: Icons.mosque,
                    title: 'Qiblat',
                    id: 'qiblat',
                    isComingSoon: true,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.book,
                    title: 'Quran',
                    id: 'quran',
                    isComingSoon: true,
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Bottom Actions
                  _buildMenuItem(
                    context,
                    icon: Icons.favorite,
                    title: 'Infaq',
                    id: 'infaq',
                    isPrimary: true,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.info,
                    title: 'Info',
                    id: 'info',
                  ),
                  
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
  
  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Consumer<UserModel>(
        builder: (context, user, _) {
          return Column(
            children: [
              // Avatar with glow effect
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryGold.withOpacity(0.3 * _pulseController.value),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: kGoldGradient,
                    border: Border.all(
                      color: kPrimaryGold,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      AppAssets.profileDefault,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xs),
              
              // Name
              MetallicGold(
                child: Text(
                  user.name.isNotEmpty
                    ? (user.name.length > 7 ? '${user.name.substring(0, 6)}..' : user.name)
                    : "User",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildTreeSection() {
    return Consumer<UserModel>(
      builder: (context, user, _) {
        return InkWell(
          onTap: () => Provider.of<SidebarStateModel>(context, listen: false)
              .setActiveMenu('tree_progress'),
          child: Container(
            height: 70,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(
              vertical: AppSpacing.xs,
              horizontal: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  kPrimaryGold.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Tree Image
                Image.asset(
                  _getTreeAsset(user.treeLevel),
                  fit: BoxFit.contain,
                  height: 50,
                ),
                
                // Level Badge
                Positioned(
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      gradient: kGoldGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "LVL ${user.treeLevel}",
                      style: const TextStyle(
                        color: kBackgroundDark,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String id,
    bool isComingSoon = false,
    bool isPrimary = false,
  }) {
    final model = Provider.of<SidebarStateModel>(context);
    final isActive = model.activeMenuId == id;
    final isHovered = _hoveredMenuId == id;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredMenuId = id),
      onExit: (_) => setState(() => _hoveredMenuId = null),
      child: InkWell(
        onTap: isComingSoon ? null : () => model.setActiveMenu(id),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: Curves.easeOut,
          width: widget.dockWidth,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive || isHovered
              ? LinearGradient(
                  colors: [
                    kPrimaryGold.withOpacity(isActive ? 0.2 : 0.1),
                    Colors.transparent,
                  ],
                )
              : null,
            border: isActive
              ? Border(
                  left: BorderSide(
                    color: kPrimaryGold,
                    width: 3,
                  ),
                )
              : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon dengan effect
              AnimatedContainer(
                duration: AppDurations.fast,
                transform: Matrix4.identity()
                  ..scale(isActive || isHovered ? 1.1 : 1.0),
                child: MetallicGold(
                  child: Icon(
                    icon,
                    color: isComingSoon
                      ? Colors.grey.withOpacity(0.3)
                      : isPrimary
                        ? Colors.red.shade300
                        : isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.7),
                    size: 22,
                  ),
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Label
              Text(
                title,
                style: TextStyle(
                  color: isComingSoon
                    ? Colors.grey.withOpacity(0.3)
                    : isPrimary
                      ? Colors.red.shade300
                      : isActive
                        ? kPrimaryGold
                        : kTextSecondary.withOpacity(0.7),
                  fontSize: 8.5,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Coming Soon Badge
              if (isComingSoon)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Soon',
                    style: TextStyle(
                      color: Colors.orange.shade300,
                      fontSize: 6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
