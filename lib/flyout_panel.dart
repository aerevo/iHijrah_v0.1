// lib/widgets/flyout_panel.dart (UPGRADED 7.8/10)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sidebar_state_model.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart';

// === IMPORT VIEWS ===
import 'profile_detail_view.dart';
import 'calendar_view.dart';
import 'event_view.dart';
import 'settings_view.dart';
import 'about_view.dart';

class FlyoutPanel extends StatelessWidget {
  final double panelWidth;
  const FlyoutPanel({Key? key, this.panelWidth = AppSizes.flyoutWidth}) : super(key: key);

  Widget _buildContent(String menuId) {
    switch (menuId) {
      case 'profil': return const ProfileDetailView();
      case 'kalendar': return const CalendarView();
      case 'peristiwa': return const EventView();
      case 'notifikasi': return const SettingsView();
      case 'info': return const AboutView();
      default: return const Center(child: Text("Sila Pilih Menu", style: TextStyle(color: kTextSecondary)));
    }
  }

  String _getTitle(String menuId) {
    switch (menuId) {
      case 'profil': return 'Profil Saya';
      case 'kalendar': return 'Kalendar Islam';
      case 'peristiwa': return 'Peristiwa Penting';
      case 'notifikasi': return 'Tetapan & Notifikasi';
      case 'info': return 'Tentang Aplikasi';
      default: return 'Menu Sampingan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SidebarStateModel>(
      builder: (context, model, child) {
        final isActive = model.activeMenuId != null;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
          width: isActive ? panelWidth : 0,
          height: double.infinity,
          decoration: BoxDecoration(
            color: kCardDark,
            border: Border(
              right: BorderSide(color: Colors.black.withOpacity(0.5), width: isActive ? 2 : 0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SingleChildScrollView(
             child: AnimatedOpacity(
              opacity: isActive ? 1.0 : 0.0,
              duration: AppDurations.fast,
              curve: isActive ? Curves.easeIn : Curves.easeOut,
              child: model.activeMenuId == null
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER PREMIUM
                        Container(
                          padding: const EdgeInsets.only(top: kToolbarHeight + 10, left: 20, right: 20, bottom: 20),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: kTextSecondary.withOpacity(0.1), width: 1)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black12, Colors.transparent],
                            ),
                          ),
                          child: MetallicGold(
                            child: Text(
                              _getTitle(model.activeMenuId!),
                              style: const TextStyle(
                                fontSize: AppFontSizes.xxl,
                                fontFamily: 'Playfair',
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: Colors.white, // Color overridden by shader
                              ),
                            ),
                          ),
                        ),

                        // KANDUNGAN
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.screenH),
                          child: _buildContent(model.activeMenuId!),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}