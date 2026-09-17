// lib/screens/edit_profile_screen.dart
// Skrin kemas kini profil — avatar, nama, jantina, bio. Berasingan drpd
// BirthdatePromptScreen (tu khusus tarikh lahir Hijri, kekal sendiri —
// dua kebimbangan berbeza, elak satu skrin buat terlalu banyak benda).
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _bioCtrl  = TextEditingController();
  String  _gender     = 'Lelaki';
  String? _avatarPath;
  bool    _picking    = false;
  bool    _saving     = false;

  static const int _bioMaxLen = 140;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserModel>(context, listen: false);
      _nameCtrl.text = user.name;
      _bioCtrl.text  = user.bio;
      if (mounted) {
        setState(() {
          _gender     = user.gender.isEmpty ? 'Lelaki' : user.gender;
          _avatarPath = user.avatarPath;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  // Salin ke storan KEKAL app — jangan simpan path cache image_picker
  // terus, sebab OS boleh bersihkan cache bila-bila & avatar "hilang".
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

  void _snack(String msg, {Color color = kWarningRed}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color,
          behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) { _snack('Sila masukkan nama anda'); return; }

    setState(() => _saving = true);
    try {
      final user = Provider.of<UserModel>(context, listen: false);
      user.name       = name;
      user.gender     = _gender;
      user.bio        = _bioCtrl.text.trim();
      user.avatarPath = _avatarPath;
      await user.save();
      // Mutasi field terus (bukan lalu method) — kena panggil manual
      // supaya ProfileDetailView & Sidebar yg watch UserModel refresh
      // serta-merta, bukan tunggu rebuild lain (cth. tick PrayerService).
      user.notifyListeners();

      if (!mounted) return;
      _snack('Profil dikemas kini.', color: kAccentGreen);
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Ralat menyimpan data. Cuba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAvatar = _avatarPath != null && _avatarPath!.isNotEmpty;

    return Scaffold(
      backgroundColor: kBackgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: kTextSecondary, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                alignment: Alignment.centerLeft,
              ),

              const SizedBox(height: 10),

              const Text('Kemas Kini Profil',
                  style: TextStyle(color: kGoldLight, fontSize: 26,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Gambar, nama, jantina dan bio ringkas anda.',
                  style: TextStyle(color: kTextSecondary, fontSize: 12, height: 1.5)),

              const SizedBox(height: 26),

              // ── AVATAR ────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: _picking ? null : _pickAvatar,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 96, height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kCardDark,
                          border: Border.all(
                              color: kPrimaryGold.withOpacity(0.4), width: 1.5),
                        ),
                        child: ClipOval(
                          child: _picking
                              ? const Center(child: SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: kPrimaryGold)))
                              : (hasAvatar
                                  ? Image.file(File(_avatarPath!), fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _avatarPlaceholder())
                                  : _avatarPlaceholder()),
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 30, height: 30,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, gradient: kGoldGradient),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 15, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('Ketik untuk tukar gambar',
                    style: TextStyle(color: kTextMuted, fontSize: 10.5)),
              ),

              const SizedBox(height: 26),

              // ── NAMA ─────────────────────────────────
              _label('Nama Penuh'),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: kTextPrimary, fontSize: 15),
                decoration: _inputDecoration('Masukkan nama anda',
                    icon: Icons.badge_outlined),
              ),

              const SizedBox(height: 20),

              // ── JANTINA ──────────────────────────────
              _label('Jantina'),
              const SizedBox(height: 8),
              Row(children: [
                _genderChip('Lelaki'),
                const SizedBox(width: 10),
                _genderChip('Wanita'),
              ]),

              const SizedBox(height: 20),

              // ── BIO ──────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _label('Bio Ringkas'),
                  Text('${_bioCtrl.text.length}/$_bioMaxLen',
                      style: const TextStyle(color: kTextMuted, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _bioCtrl,
                maxLength: _bioMaxLen,
                maxLines: 3,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: kTextPrimary, fontSize: 13.5, height: 1.4),
                decoration: InputDecoration(
                  hintText: 'Contoh: Berusaha istiqamah dlm solat & amalan harian',
                  hintStyle: const TextStyle(color: kTextMuted, fontSize: 12.5),
                  filled: true,
                  fillColor: kCardDark,
                  counterText: '',
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

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeightLg,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryGold,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: kPrimaryGold.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
                  ),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black))
                      : const Text('SIMPAN PROFIL',
                          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarPlaceholder() => const Center(
        child: Icon(Icons.person_rounded, color: kTextMuted, size: 40),
      );

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.w500));

  InputDecoration _inputDecoration(String hint, {required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kTextMuted),
        prefixIcon: Icon(icon, color: kPrimaryGold, size: 20),
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
      );

  Widget _genderChip(String label) {
    final bool sel = _gender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = label),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? kPrimaryGold.withOpacity(0.12) : kCardDark,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: sel ? kPrimaryGold : kBorderSubtle,
              width: sel ? 1.4 : 0.8,
            ),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                color: sel ? kGoldLight : kTextSecondary,
                fontSize: 13,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
              )),
        ),
      ),
    );
  }
}
