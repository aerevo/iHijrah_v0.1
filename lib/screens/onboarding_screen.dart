// lib/screens/onboarding_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/hijri_service.dart';
import '../widgets/metallic_gold.dart';
import '../widgets/tree_of_life_logo.dart';
import '../widgets/iridescent_background.dart';
import '../home.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pages  = PageController();
  final TextEditingController _nameCtrl = TextEditingController();

  int      _step           = 0;
  DateTime _selectedDate   = DateTime(1995, 1, 1);
  String   _selectedGender = 'Lelaki';
  String?  _avatarPath;
  bool     _picking        = false;
  bool     _saving         = false;

  // Preview Hijri selepas pilih tarikh
  String get _hijriPreview {
    final h = HijriService.fromDate(_selectedDate);
    return '${h.hDay} ${HijriService.bulanMelayu(h.hMonth)} ${h.hYear}H';
  }

  String get _hijriAge {
    return HijriService.calculateHijriAge(_selectedDate.toIso8601String());
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (_step == 1 && _nameCtrl.text.trim().isEmpty) {
      _snack('Sila masukkan nama anda');
      return;
    }
    if (_step < 3) {
      _pages.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _submit();
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step > 0) {
      _pages.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: kWarningRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Salin ke storan KEKAL app (bukan simpan path cache image_picker
  // terus) — sama pattern macam EditProfileScreen, elak avatar "hilang"
  // bila OS bersihkan cache.
  Future<void> _pickAvatar() async {
    setState(() => _picking = true);
    try {
      final XFile? img = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 720,
        imageQuality: 85,
      );
      if (img == null) { setState(() => _picking = false); return; }

      final Directory docsDir = await getApplicationDocumentsDirectory();
      final String ext = img.path.contains('.') ? img.path.split('.').last : 'jpg';
      final String newPath =
          '${docsDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await File(img.path).copy(newPath);

      if (!mounted) return;
      setState(() { _avatarPath = newPath; _picking = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _picking = false);
      _snack('Tak dapat buka galeri. Cuba lagi.');
    }
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      final user = Provider.of<UserModel>(context, listen: false);
      user.name      = _nameCtrl.text.trim().isEmpty
          ? 'Hamba Allah'
          : _nameCtrl.text.trim();
      user.birthdate = _selectedDate;
      user.gender    = _selectedGender;
      user.avatarPath = _avatarPath;
      // Simpan hijriDOB sebagai ISO string supaya HijriService boleh parse
      user.hijriDOB  = _selectedDate.toIso8601String();
      await user.save();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } catch (e) {
      setState(() => _saving = false);
      _snack('Ralat menyimpan data. Cuba lagi.');
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundDark,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [

            // Latar — "oil on water" pastel lembut, kontra lebih baik dgn
            // teks/logo emas berbanding gradient putih-kelabu lama
            const Positioned.fill(child: IridescentBackground()),

            SafeArea(
              child: Column(
                children: [

                  const SizedBox(height: 24),

                  // ── Logo kecil — kilau emas ─────────────────
                  MetallicGold(
                    child: Text(
                      'iHijrah',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Progress dots ───────────────────────────
                  _buildDots(),

                  const SizedBox(height: 8),

                  // ── Pages ───────────────────────────────────
                  Expanded(
                    child: PageView(
                      controller: _pages,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (i) => setState(() => _step = i),
                      children: [
                        _stepWelcome(),
                        _stepIdentity(),
                        _stepGender(),
                        _stepAvatar(),
                      ],
                    ),
                  ),

                  // ── Bottom nav ──────────────────────────────
                  _buildNav(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STEP 1 — SELAMAT DATANG ──────────────────────────────────
  Widget _stepWelcome() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // Lambang Pokok Hayat — emas timbul, animasi masuk
          const TreeOfLifeLogo(size: 100, animated: true),

          const SizedBox(height: 28),

          MetallicGold(
            child: Text(
              'Assalamualaikum',
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Selamat datang ke iHijrah Embun Jiwa.\nPeneman ibadah harian anda.',
            style: TextStyle(
              color: kTextSecondary,
              fontSize: 14,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Ciri-ciri ringkas — ikon sebenar, bukan emoji
          ...[
            (Icons.nights_stay_rounded, 'Umur & identiti Hijrah anda'),
            (Icons.park_rounded,        'Pokok Hijrah yang tumbuh bersama ibadah'),
            (Icons.spa_rounded,         'Amalan, hadith & sirah harian'),
            (Icons.groups_rounded,      'Komuniti Muslim tempatan'),
          ].map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: kPrimaryGold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(e.$1, color: kGoldDark, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(e.$2,
                      style: const TextStyle(
                          color: kTextPrimary, fontSize: 13)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ── STEP 2 — NAMA & TARIKH LAHIR ────────────────────────────
  Widget _stepIdentity() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          MetallicGold(
            child: Text(
              'Siapakah anda?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Nama dan tarikh lahir untuk mengira identiti Hijrah anda.',
            style: TextStyle(color: kTextSecondary, fontSize: 12, height: 1.5),
          ),

          const SizedBox(height: 24),

          // Input nama
          _inputLabel('Nama Penuh'),
          const SizedBox(height: 6),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: kTextPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Masukkan nama anda',
              hintStyle: const TextStyle(color: kTextMuted),
              prefixIcon: const Icon(Icons.badge_outlined, color: kPrimaryGold, size: 20),
              filled: true,
              fillColor: kCardDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                borderSide: const BorderSide(color: kPrimaryGold, width: 1),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Tarikh lahir
          _inputLabel('Tarikh Lahir (Masihi)'),
          const SizedBox(height: 6),

          Container(
            height: 160,
            decoration: BoxDecoration(
              color: kCardDark,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: Border.all(color: kBorderSubtle, width: 1),
            ),
            child: CupertinoTheme(
              data: CupertinoThemeData(
                // BUG DIBAIKI: dulu Brightness.dark atas latar yang kini
                // cerah — teks kalendar Cupertino jadi pudar/hilang.
                brightness: Brightness.light,
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(
                    color: kGoldDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                minimumDate: DateTime(1900),
                maximumDate: DateTime.now(),
                backgroundColor: kCardDark,
                onDateTimeChanged: (d) => setState(() => _selectedDate = d),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Preview Hijri
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kPrimaryGold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: Border.all(color: kPrimaryGold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.nights_stay_rounded, color: kGoldDark, size: 20),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hijriPreview,
                      style: const TextStyle(
                          color: kGoldDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Umur Hijrah: $_hijriAge',
                      style: const TextStyle(
                          color: kTextSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 3 — JANTINA ────────────────────────────────────────
  Widget _stepGender() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          MetallicGold(
            child: Text(
              'Pilih Jantina',
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Untuk pengalaman yang lebih personal.',
            style: TextStyle(color: kTextSecondary, fontSize: 13),
          ),

          const SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _genderCard('Lelaki'),
              const SizedBox(width: 20),
              _genderCard('Wanita'),
            ],
          ),

          const SizedBox(height: 40),

          // Preview profil ringkas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCardDark,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: Border.all(color: kBorderSubtle, width: 1),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: kPrimaryGold.withOpacity(0.15),
                  child: Text(
                    _nameCtrl.text.trim().isNotEmpty
                        ? _nameCtrl.text.trim()[0].toUpperCase()
                        : 'H',
                    style: GoogleFonts.playfairDisplay(
                      color: kGoldDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameCtrl.text.trim().isEmpty
                          ? 'Hamba Allah'
                          : _nameCtrl.text.trim(),
                      style: const TextStyle(
                          color: kTextPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _hijriPreview,
                      style: const TextStyle(
                          color: kGoldDark, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _hijriAge,
                      style: const TextStyle(
                          color: kTextSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── STEP 4 — GAMBAR PROFIL (pilihan, boleh langkau) ──────────
  Widget _stepAvatar() {
    final bool hasAvatar = _avatarPath != null && _avatarPath!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          MetallicGold(
            child: Text(
              'Tambah Gambar Profil',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Pilihan sahaja — boleh langkau & tambah kemudian dalam Tetapan.',
            style: TextStyle(color: kTextSecondary, fontSize: 12.5, height: 1.5),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 36),

          GestureDetector(
            onTap: _picking ? null : _pickAvatar,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kCardDark,
                    border: Border.all(
                        color: kPrimaryGold.withOpacity(0.4), width: 1.5),
                  ),
                  child: ClipOval(
                    child: _picking
                        ? const Center(child: SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: kPrimaryGold)))
                        : (hasAvatar
                            ? Image.file(File(_avatarPath!), fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _avatarPlaceholder())
                            : _avatarPlaceholder()),
                  ),
                ),
                Positioned(
                  bottom: 2, right: 2,
                  child: Container(
                    width: 34, height: 34,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, gradient: kGoldGradient),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 17, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (!hasAvatar)
            TextButton(
              onPressed: _next,
              child: const Text('Langkau buat masa ini →',
                  style: TextStyle(color: kTextSecondary, fontSize: 12.5)),
            ),
        ],
      ),
    );
  }

  Widget _avatarPlaceholder() => const Center(
        child: Icon(Icons.person_rounded, color: kTextMuted, size: 50),
      );

  // ── WIDGET HELPERS ────────────────────────────────────────────
  Widget _inputLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.w500),
  );

  Widget _genderCard(String label) {
    final bool sel = _selectedGender == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = label),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: 130, height: 130,
        decoration: BoxDecoration(
          color: sel ? kPrimaryGold.withOpacity(0.12) : kCardDark,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          border: Border.all(
            color: sel ? kPrimaryGold : kBorderSubtle,
            width: sel ? 1.5 : 0.8,
          ),
          boxShadow: sel
              ? [
                  BoxShadow(
                      color: kPrimaryGold.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: sel ? kGoldDark : kTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: AppDurations.fast,
                    width: sel ? 28 : 16,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: sel ? kPrimaryGold : kBorderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            if (sel)
              Positioned(
                top: 10, right: 10,
                child: Container(
                  width: 20, height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: kGoldGradient,
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) => AnimatedContainer(
        duration: AppDurations.fast,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: _step == i ? 24 : 7,
        height: 7,
        decoration: BoxDecoration(
          color: _step == i ? kPrimaryGold : kBorderSubtle,
          borderRadius: BorderRadius.circular(4),
        ),
      )),
    );
  }

  Widget _buildNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [

          if (_step > 0)
            TextButton(
              onPressed: _back,
              child: const Text('Kembali',
                  style: TextStyle(color: kTextSecondary)),
            )
          else
            const Spacer(),

          const Spacer(),

          SizedBox(
            width: 140,
            height: AppSizes.buttonHeightMd,
            child: ElevatedButton(
              onPressed: _saving ? null : _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGold,
                foregroundColor: Colors.black,
                disabledBackgroundColor: kPrimaryGold.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black))
                  : Text(
                      _step == 3 ? 'Mulakan' : 'Seterusnya',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, letterSpacing: 0.5),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
