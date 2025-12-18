// lib/widgets/flyout_panel.dart - PREMIUM GLASSMORPHISM PANEL
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import '../models/sidebar_state_model.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart';

// Import Views
import 'profile_detail_view.dart';
import 'calendar_view.dart';
import 'event_view.dart';
import 'settings_view.dart';
import 'about_view.dart';
import 'hijrah_tree.dart';

class FlyoutPanel extends StatefulWidget {
  final double panelWidth;
  
  const FlyoutPanel({
    Key? key,
    this.panelWidth = AppSizes.flyoutWidth,
  }) : super(key: key);

  @override
  State<FlyoutPanel> createState() => _FlyoutPanelState();
}

class _FlyoutPanelState extends State<FlyoutPanel> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }
  
  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Widget _buildContent(String menuId) {
    switch (menuId) {
      case 'profil':
        return const ProfileDetailView();
      case 'kalendar':
        return const CalendarView();
      case 'peristiwa':
        return const EventView();
      case 'notifikasi':
        return const SettingsView();
      case 'info':
        return const AboutView();
      case 'tree_progress':
        return const HijrahTree();
      case 'sirah':
        return _buildComingSoonView('Sirah Nabi', Icons.menu_book);
      case 'birthday':
        return _buildComingSoonView('Hari Jadi', Icons.cake);
      case 'infaq':
        return _buildComingSoonView('Infaq', Icons.favorite);
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildComingSoonView(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: kGoldGradient.scale(0.3),
            ),
            child: Icon(
              icon,
              size: 64,
              color: kPrimaryGold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: const TextStyle(
              color: kTextPrimary,
              fontSize: AppFontSizes.xl,
              fontWeight: FontWeight.bold,
              fontFamily: 'Playfair',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Akan datang tidak lama lagi',
            style: TextStyle(
              color: kTextSecondary.withOpacity(0.7),
              fontSize: AppFontSizes.sm,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SidebarStateModel>(
      builder: (context, model, child) {
        final double width = model.isClosed ? 0 : widget.panelWidth;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          width: width,
          height: double.infinity,
          child: OverflowBox(
            minWidth: widget.panelWidth,
            maxWidth: widget.panelWidth,
            alignment: Alignment.centerLeft,
            child: model.isClosed
              ? const SizedBox.shrink()
              : _buildPremiumGlassContainer(context, model),
          ),
        );
      },
    );
  }

  Widget _buildPremiumGlassContainer(BuildContext context, SidebarStateModel model) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: widget.panelWidth,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.3),
              ],
            ),
            border: Border(
              right: BorderSide(
                color: kPrimaryGold.withOpacity(0.2),
                width: 1,
              ),
              left: BorderSide(
                color: kPrimaryGold.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Stack(
            children: [
              // Animated shimmer overlay
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.transparent,
                            kPrimaryGold.withOpacity(0.05 * _shimmerController.value),
                            Colors.transparent,
                          ],
                          stops: [
                            _shimmerController.value - 0.3,
                            _shimmerController.value,
                            _shimmerController.value + 0.3,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(model),
                  
                  // Content Area
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          _buildContent(model.activeMenuId!),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(SidebarStateModel model) {
    return Container(
      padding: const EdgeInsets.only(
        top: 50,
        left: AppSpacing.md,
        right: AppSpacing.sm,
        bottom: AppSpacing.md,
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
        border: Border(
          bottom: BorderSide(
            color: kPrimaryGold.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon & Title
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: kGoldGradient.scale(0.3),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppShadows.glow,
                  ),
                  child: Icon(
                    _getMenuIcon(model.activeMenuId ?? ''),
                    color: kBackgroundDark,
                    size: AppSizes.iconMd,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: MetallicGold(
                    child: Text(
                      model.menuTitle.toUpperCase(),
                      style: const TextStyle(
                        fontSize: AppFontSizes.lg,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontFamily: 'Playfair',
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Close Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: kTextPrimary,
                size: AppSizes.iconMd,
              ),
              onPressed: () => model.closeMenu(),
              tooltip: 'Tutup',
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getMenuIcon(String menuId) {
    switch (menuId) {
      case 'profil':
        return Icons.person;
      case 'kalendar':
        return Icons.calendar_month;
      case 'peristiwa':
        return Icons.event;
      case 'notifikasi':
        return Icons.notifications;
      case 'info':
        return Icons.info;
      case 'tree_progress':
        return Icons.park;
      case 'sirah':
        return Icons.menu_book;
      case 'birthday':
        return Icons.cake;
      case 'infaq':
        return Icons.favorite;
      default:
        return Icons.menu;
    }
  }
}
