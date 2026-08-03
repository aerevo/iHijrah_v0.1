// lib/widgets/sidebar.dart
// Rel navigasi KIRI — gantikan navbar atas.
// - Keadaan lalai: ikon + label ringkas (kRailWidthCollapsed)
// - Tekan logo ATAU swipe kanan pada rel: kembang penuh (kRailWidthExpanded)
// - Scroll feed ke bawah: rel pudar/gelongsor keluar; scroll atas: kembali
// - Semua navigasi (logo, avatar, notis, carian, 6 tab) hidup di sini sahaja

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/sidebar_state_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/prayer_service.dart';
import 'metallic_icon.dart';
import 'living_tree.dart';

// ── SAIZ REL ──────────────────────────────────────────────────
const double kRailWidthCollapsed = 60.0;
const double kRailWidthExpanded  = 226.0;

class _RailTab {
  final String   id;
  final IconData icon;
  final String   label;
  const _RailTab(this.id, this.icon, this.label);
}

const List<_RailTab> _mainTabs = [
  _RailTab('utama',    Icons.home_rounded,             'Utama'),
  _RailTab('sirah',    Icons.auto_stories_rounded,     'Sirah'),
  _RailTab('amalan',   Icons.spa_rounded,              'Amalan'),
  _RailTab('kalendar', Icons.calendar_month_rounded,   'Jadual'),
  _RailTab('pokok',    Icons.park_rounded,             'Pokok'),
  _RailTab('profil',   Icons.person_rounded,           'Profil'),
];

const List<_RailTab> _utilityTabs = [
  _RailTab('notifikasi', Icons.notifications_none_rounded, 'Notis'),
  _RailTab('carian',     Icons.search_rounded,             'Cari'),
];

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SidebarStateModel>();
    final user  = context.watch<UserModel>();

    final double width =
        model.isExpanded ? kRailWidthExpanded : kRailWidthCollapsed;

    return Stack(
      children: [

        // ── REL UTAMA ────────────────────────────────────
        AnimatedPositioned(
          duration: AppDurations.normal,
          curve: AppCurves.smooth,
          left: model.isVisible ? 0 : -kRailWidthExpanded,
          top: 0, bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (d) {
              final vx = d.velocity.pixelsPerSecond.dx;
              if (vx > 250 && !model.isExpanded) model.toggleExpanded();
              if (vx < -250 && model.isExpanded) model.toggleExpanded();
            },
            child: AnimatedContainer(
              duration: AppDurations.normal,
              curve: AppCurves.smooth,
              width: width,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: kGlassRailGradientGreen,
                border: Border(
                  right: BorderSide(color: kGlassRailBorder, width: 1),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x59000000),
                    blurRadius: 28,
                    offset: Offset(6, 0),
                  ),
                ],
              ),
              child: _railContent(context, model, user),
            ),
          ),
        ),

        // ── HANDLE TERAPUNG — muncul bila rel tersembunyi ──
        AnimatedPositioned(
          duration: AppDurations.normal,
          curve: AppCurves.smooth,
          left: model.isVisible ? -50 : 0,
          top: MediaQuery.of(context).size.height * 0.42,
          child: _buildHandle(model),
        ),
      ],
    );
  }

  // ── ISI REL ─────────────────────────────────────────────────
  Widget _railContent(
      BuildContext ctx, SidebarStateModel model, UserModel user) {
    return SafeArea(
      child: Stack(
        children: [

          // Pencahayaan — glow keemasan lembut, statik (bukan animasi
          // berat), duduk di belakang avatar+pokok. Ni yg beza "biru
          // gelap kosong" drpd "biru gelap ADA pencahayaan" macam rujukan.
          // IgnorePointer supaya tak ganggu tap avatar/pokok di atasnya.
          Positioned(
            top: model.isExpanded ? 104 : 76,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: model.isExpanded ? 260 : 170,
                  height: model.isExpanded ? 260 : 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        kGoldLight.withOpacity(0.20),
                        kGoldLight.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 14),

              // Avatar + nama (2 baris, center) + umur Hijrah — tekan buka Profil
              _avatarBlock(model, user),

              const SizedBox(height: 10),
              _divider(),
              const SizedBox(height: 10),

              // Waktu solat seterusnya — halus sahaja, sekadar tanda app Islamik
              _prayerBlock(model),

              const SizedBox(height: 10),
              _divider(),
              const SizedBox(height: 12),

              // Pokok Embun Jiwa — video sebenar (sama macam tab Pokok),
              // tekan -> tab Pokok. Cuma dirender bila rel memang visible
              // (bila tersorok scroll-bawah, video di-dispose terus, jimat
              // prestasi — bukan main senyap belakang tabir).
              _miniTreeSlot(model, user),

              const SizedBox(height: 14),
              _divider(),
              const SizedBox(height: 6),

              // Tab utama
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: _mainTabs
                        .map((t) => _railItem(model, t))
                        .toList(),
                  ),
                ),
              ),

              _divider(),
              const SizedBox(height: 6),

              ..._utilityTabs.map((t) => _railItem(model, t)),

              SizedBox(height: MediaQuery.of(ctx).padding.bottom + 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              kGlassRailBorder.withOpacity(0.0),
              kGoldLight.withOpacity(0.45),
              kGlassRailBorder.withOpacity(0.0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      );

  // ── POKOK MINI (video sebenar, saiz sidebar) ─────────────────
  // FittedBox skalakan video ke kotak kecil ni tanpa kira aspect ratio
  // sebenar fail video — selamat dari overflow rel yang sempit (60px).
  //
  // Saiz: +30% bila expanded (92→120, muat selesa dlm rel 226px).
  // Bila COLLAPSED, rel cuma 60px lebar — kotak dikekalkan 58px (dah
  // nyaris maksimum ruang yg ada, 2px baki each side). Bingkai emas +
  // denyut di bawah dilukis DALAM 58px tu (border/padding inset, tak
  // tambah saiz luar), jadi tiada overflow — tapi ni maknanya +30% cuma
  // termakbul bila rel expanded. Nak lebih besar lagi waktu collapsed
  // kena naikkan kRailWidthCollapsed sendiri (ubah lebar rel tertutup
  // seluruh app) — bagitahu kalau nak pergi arah tu.
  Widget _miniTreeSlot(SidebarStateModel model, UserModel user) {
    final double boxSize = model.isExpanded ? 120 : 58;
    return _PulsingGoldFrame(
      size: boxSize,
      child: model.isVisible
          ? FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                height: 260,
                child: LivingTree(
                  assetPath: _treeAssetForLevel(user.treeLevel),
                  height: 260,
                  onTap: () => model.setActiveMenu('pokok'),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  String _treeAssetForLevel(int level) {
    if (level <= 1) return AppAssets.treeV1;
    if (level <= 3) return AppAssets.treeV2;
    if (level <= 6) return AppAssets.treeV3;
    return AppAssets.treeV4;
  }

  // ── AVATAR ──────────────────────────────────────────────────
  Widget _avatarBlock(SidebarStateModel model, UserModel user) {
    final bool hasAvatar =
        user.avatarPath != null && user.avatarPath!.isNotEmpty;
    final double avatarSize = model.isExpanded ? 58 : 44;

    return GestureDetector(
      onTap: () => model.setActiveMenu('profil'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _avatarCircle(user, hasAvatar, avatarSize),
            const SizedBox(height: 7),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: LuxuryGoldIcon.goldStops,
                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                user.name.isEmpty ? 'Hamba Allah' : user.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cormorantGaramond(
                  color: Colors.white, // asas ShaderMask — warna sebenar dari gradient
                  fontSize: model.isExpanded ? 16 : 13,
                  fontWeight: FontWeight.w700,
                  height: 1.05, // rapat drpd sebelum ni — kekal padat bila 2 baris
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 5), // jarak lebih luas — asing tahap hierarki
            Text(
              user.hijriAge,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: kGlassTextDim, // caption sekunder — sengaja tenang, bukan emas
                fontSize: model.isExpanded ? 10 : 8,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarCircle(UserModel user, bool hasAvatar, double size) {
    return Container(
      width: size, height: size,
      padding: const EdgeInsets.all(2.5), // jarak antara ring luar & dalam
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kGoldLight.withOpacity(0.25), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: kGoldLight.withOpacity(0.22),
            blurRadius: 8,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          color: kGlassRailBase.withOpacity(0.4),
        ),
        child: ClipOval(
          child: hasAvatar
              ? Image.file(File(user.avatarPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _avatarFallback(user))
              : _avatarFallback(user),
        ),
      ),
    );
  }

  Widget _avatarFallback(UserModel user) => Image.asset(
        AppAssets.profileDefault,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'H',
            style: const TextStyle(
                color: kGoldLight, fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ),
      );

  // ── WAKTU SOLAT (halus) ───────────────────────────────────────
  // Sekadar penanda "app Islamik" — tak interaktif, tak menonjol.
  // Consumer discreetly scoped di sini je (bukan watch kat top build())
  // supaya rebuild setiap minit (tick PrayerService) tak paksa seluruh
  // rel + tab + avatar sekali render balik.
  Widget _prayerBlock(SidebarStateModel model) {
    return Consumer<PrayerService>(
      builder: (_, prayer, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: model.isExpanded
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      prayer.nextPrayerName,
                      style: GoogleFonts.manrope(
                        color: kGoldLight,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        '· ${prayer.countdown}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          color: kGlassTextDim,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      prayer.nextPrayerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: kGoldLight,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      prayer.countdown,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: kGlassTextDim,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  // ── ITEM REL (tab / notis / carian) ────────────────────────
  Widget _railItem(SidebarStateModel model, _RailTab t) {
    final bool isUtama = t.id == 'utama';
    final bool active  = isUtama ? model.isClosed : model.isMenuActive(t.id);
    final Color labelColor = active
        ? kRailGoldActive
        : kGlassTextDim.withOpacity(0.62); // pudar sengaja — biar active menonjol

    return GestureDetector(
      onTap: () => isUtama ? model.closeMenu() : model.setActiveMenu(t.id),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        margin: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        padding: EdgeInsets.symmetric(
          horizontal: model.isExpanded ? 13 : 0,
          vertical: model.isExpanded ? 13 : 12, // lebih ruang bernafas (dulu 9-11)
        ),
        decoration: active
            ? BoxDecoration(
                // Kapsul kaca emas — GELAP & lutsinar (bukan emas terang
                // pekat), supaya ikon/label emas TERANG di atas dia masih
                // ada kontras kuat (terang-atas-gelap, bukan emas-atas-emas)
                color: kGoldDeep.withOpacity(0.30),
                borderRadius: BorderRadius.circular(20),
                border: Border(
                  top:    BorderSide(color: kGoldLight.withOpacity(0.55), width: 1),
                  left:   BorderSide(color: kGoldLight.withOpacity(0.30), width: 1),
                  bottom: BorderSide(color: Colors.black.withOpacity(0.35), width: 1),
                  right:  BorderSide(color: Colors.black.withOpacity(0.22), width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: kGoldLight.withOpacity(0.16),
                    blurRadius: 10,
                    spreadRadius: -1,
                  ),
                ],
              )
            : const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20))),
        child: model.isExpanded
            ? Row(
                children: [
                  _iconBadge(t, active, 22),
                  const SizedBox(width: 12),
                  Text(
                    t.label,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight:
                          active ? FontWeight.w800 : FontWeight.w600,
                      color: labelColor,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconBadge(t, active, 21),
                  const SizedBox(height: 3),
                  Text(
                    t.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 8.6,
                      fontWeight:
                          active ? FontWeight.w800 : FontWeight.w600,
                      color: labelColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Semua ikon guna gradient TERANG PENUH — status aktif tak lagi dibawa
  // oleh kecerahan ikon (mata kata semua rasa sama-sama silau, betul —
  // matte redupkan terlalu banyak). Status aktif kekal jelas drpd kapsul
  // kaca emas di belakang dia sahaja.
  Widget _iconBadge(_RailTab t, bool active, double size) {
    return LuxuryGoldIcon(icon: t.icon, size: size);
  }

  // ── HANDLE TERAPUNG ─────────────────────────────────────────
  Widget _buildHandle(SidebarStateModel model) {
    return GestureDetector(
      onTap: () => model.setSidebarVisibility(true),
      child: Container(
        width: 30, height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kGlassRailBase, kGlassRailDeep],
          ),
          border: Border.all(color: kGlassRailBorder, width: 1),
          borderRadius:
              const BorderRadius.horizontal(right: Radius.circular(18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 14,
              offset: const Offset(3, 0),
            ),
          ],
        ),
        child: const Icon(Icons.chevron_right_rounded,
            color: kGoldLight, size: 20),
      ),
    );
  }

}

// ── BINGKAI EMAS BERDENYUT (khas Pokok Embun Jiwa) ──────────────
// Border + glow beraksi (opacity/lebar/blur berayun perlahan) — bukan
// hiasan biasa, tapi sengaja tarik fokus mata pengguna terus ke pokok
// (satu2 nya elemen "hidup" dlm rel). Video pokok sendiri (child) tak
// rebuild setiap frame animasi — cuma bingkai luar je, jimat prestasi.
//
// `size` = saiz LUAR keseluruhan termasuk bingkai (bukan tambahan atas
// saiz video) — supaya boleh diletak terus dlm rel 60px tanpa overflow.
class _PulsingGoldFrame extends StatefulWidget {
  final Widget child;
  final double size;

  const _PulsingGoldFrame({required this.child, required this.size});

  @override
  State<_PulsingGoldFrame> createState() => _PulsingGoldFrameState();
}

class _PulsingGoldFrameState extends State<_PulsingGoldFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) {
          final double t = Curves.easeInOut.transform(_ctrl.value); // 0→1→0
          final double glow  = 0.35 + (t * 0.45); // 0.35 → 0.80
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: kGoldLight.withOpacity(0.7),
                width: 1.4, // nipis — cincin sahaja, bukan tumpuan utama
              ),
              boxShadow: [
                // Emas balik (bukan hijau lagi) — latar rel sekarang HIJAU
                // sendiri, jadi glow hijau atas hijau akan blend/hilang.
                // Emas ni yg jadi aksen menonjol atas latar hijau baru.
                BoxShadow(
                  color: kGoldLight.withOpacity(glow * 0.55),
                  blurRadius: 10 + (t * 10),
                  spreadRadius: 1 + (t * 1.8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2.5),
            child: child,
          );
        },
        child: ClipOval(child: widget.child),
      ),
    );
  }
}
