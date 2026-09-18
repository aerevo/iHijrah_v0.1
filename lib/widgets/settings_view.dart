// lib/widgets/settings_view.dart  (V2 — skrin Tetapan penuh)
//
// Sebelum ni cuma redirect terus ke NotificationSettingsScreen (12
// baris). Kini skrin Tetapan sebenar: shortcut profil, peringatan
// solat (sedia ada, suis Embun Jiwa dibetulkan supaya real), Lokasi
// Solat (baru — PrayerService.updateLocation() dah wujud tapi tiada
// UI panggil dia langsung sblm ni, jadi semua org dapat waktu solat
// KL walau di mana pun), Tema (baru — Auto/Siang/Malam, gantikan
// flag debug kForceDayModeTemp yg dah dibuang), dan Tentang.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../models/sidebar_state_model.dart';
import '../screens/notification_settings_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../utils/constants.dart';
import '../utils/prayer_service.dart';

// Bandar utama Malaysia + koordinat — cukup utk anggaran waktu solat
// tepat. Boleh tambah lagi kalau perlu; ni bukan senarai lengkap
// semua daerah, cuma pusat negeri/bandar besar yg biasa digunakan.
const List<({String name, double lat, double lng})> _kCities = [
  (name: 'Kuala Lumpur',      lat: 3.1390,  lng: 101.6869),
  (name: 'Putrajaya',         lat: 2.9264,  lng: 101.6964),
  (name: 'Shah Alam',         lat: 3.0733,  lng: 101.5185),
  (name: 'Johor Bahru',       lat: 1.4927,  lng: 103.7414),
  (name: 'George Town',       lat: 5.4141,  lng: 100.3288),
  (name: 'Ipoh',              lat: 4.5975,  lng: 101.0901),
  (name: 'Kuching',           lat: 1.5533,  lng: 110.3592),
  (name: 'Kota Kinabalu',     lat: 5.9804,  lng: 116.0735),
  (name: 'Melaka',            lat: 2.1896,  lng: 102.2501),
  (name: 'Seremban',          lat: 2.7297,  lng: 101.9381),
  (name: 'Alor Setar',        lat: 6.1184,  lng: 100.3685),
  (name: 'Kuantan',           lat: 3.8077,  lng: 103.3260),
  (name: 'Kuala Terengganu',  lat: 5.3117,  lng: 103.1324),
  (name: 'Kota Bharu',        lat: 6.1254,  lng: 102.2381),
];

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user   = context.watch<UserModel>();
    final prayer = context.watch<PrayerService>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── PROFIL — shortcut ────────────────────────────
          _sectionCard(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_rounded, color: kPrimaryGold, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name.isEmpty ? 'Hamba Allah' : user.name,
                            style: const TextStyle(color: kTextPrimary,
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        const Text('Edit profil, avatar & bio',
                            style: TextStyle(color: kTextSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: kTextMuted, size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── PERINGATAN SOLAT (sedia ada) ─────────────────
          const NotificationSettingsScreen(),

          const SizedBox(height: 20),

          // ── LOKASI SOLAT ──────────────────────────────────
          _sectionCard(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
              onTap: () => _showCityPicker(context, prayer),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: kAccentTeal, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('LOKASI SOLAT',
                            style: TextStyle(color: kGoldLight, fontSize: 11.5,
                                fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                        const SizedBox(height: 2),
                        Text(prayer.locationLabel,
                            style: const TextStyle(color: kTextSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: kTextMuted, size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── TEMA ───────────────────────────────────────────
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.wb_twilight_rounded, color: kPrimaryGold, size: 18),
                    SizedBox(width: 8),
                    Text('TEMA',
                        style: TextStyle(color: kGoldLight, fontSize: 13,
                            fontWeight: FontWeight.w700, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(children: [
                  _themeChip(context, user, 'auto',  'Auto',  Icons.brightness_auto_rounded),
                  const SizedBox(width: 8),
                  _themeChip(context, user, 'day',   'Siang', Icons.light_mode_rounded),
                  const SizedBox(width: 8),
                  _themeChip(context, user, 'night', 'Malam', Icons.dark_mode_rounded),
                ]),
                const SizedBox(height: 8),
                Text(
                  user.themeMode == 'auto'
                      ? 'Ikut waktu Subuh/Maghrib sebenar di lokasi anda.'
                      : 'Dipaksa — abaikan waktu solat sebenar.',
                  style: const TextStyle(color: kTextMuted, fontSize: 10.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── TENTANG ─────────────────────────────────────────
          _sectionCard(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
              onTap: () =>
                  context.read<SidebarStateModel>().setActiveMenu('info'),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: kTextSecondary, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Tentang iHijrah',
                        style: TextStyle(color: kTextPrimary, fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                  Icon(Icons.chevron_right_rounded, color: kTextMuted, size: 18),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Center(
            child: Text('iHijrah Embun Jiwa · v1.0.0',
                style: TextStyle(color: kTextMuted, fontSize: 10)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: kCardDark,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          border: Border.all(color: kBorderSubtle),
        ),
        child: child,
      );

  Widget _themeChip(BuildContext context, UserModel user, String mode,
      String label, IconData icon) {
    final bool sel = user.themeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => user.setThemeMode(mode),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? kPrimaryGold.withOpacity(0.14) : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: sel ? kPrimaryGold : kBorderSubtle,
              width: sel ? 1.3 : 0.8,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 17, color: sel ? kPrimaryGold : kTextMuted),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? kGoldLight : kTextSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  void _showCityPicker(BuildContext context, PrayerService prayer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kBackgroundDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded, color: kAccentTeal, size: 18),
                  SizedBox(width: 8),
                  Text('Pilih Lokasi Solat',
                      style: TextStyle(color: kGoldLight, fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Divider(height: 1, color: kBorderSubtle),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetCtx).size.height * 0.5),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _kCities.length,
                itemBuilder: (_, i) {
                  final c = _kCities[i];
                  final bool sel = prayer.locationLabel == c.name;
                  return ListTile(
                    dense: true,
                    title: Text(c.name, style: TextStyle(
                        color: sel ? kGoldLight : kTextPrimary,
                        fontSize: 13.5,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
                    trailing: sel
                        ? const Icon(Icons.check_circle_rounded,
                            color: kPrimaryGold, size: 18)
                        : null,
                    onTap: () {
                      prayer.updateLocation(c.lat, c.lng, label: c.name);
                      Navigator.of(sheetCtx).pop();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
