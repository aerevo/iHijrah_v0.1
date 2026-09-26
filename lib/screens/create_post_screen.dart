// lib/screens/create_post_screen.dart
// Buat post KOMUNITI — v1 minimal: teks sahaja (renungan/petikan),
// tiada upload gambar lagi (perlukan Firebase Storage, belum disetup
// — fasa lain). Tulis terus ke Firestore collection "posts"; muncul
// di atas sekali dlm feed sbb FeedPanel order by createdAt descending.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleCtrl   = TextEditingController();
  final TextEditingController _contentCtrl = TextEditingController();

  String _postType = 'article'; // 'article' (renungan) | 'quote' (petikan)
  bool   _posting  = false;

  static const int _contentMin = 10;
  static const int _contentMax = 1000;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg, {Color color = kWarningRed}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color,
          behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _submit() async {
    final String content = _contentCtrl.text.trim();
    final String title   = _titleCtrl.text.trim();

    if (_postType == 'article' && title.isEmpty) {
      _snack('Sila masukkan tajuk ringkas');
      return;
    }
    if (content.length < _contentMin) {
      _snack('Kandungan terlalu pendek (min $_contentMin aksara)');
      return;
    }
    if (content.length > _contentMax) {
      _snack('Kandungan terlalu panjang (maks $_contentMax aksara)');
      return;
    }

    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _snack('Sila log masuk semula.');
      return;
    }

    setState(() => _posting = true);
    try {
      final user = Provider.of<UserModel>(context, listen: false);
      await FirebaseFirestore.instance.collection('posts').add({
        'type':          _postType,
        'title':         _postType == 'quote' ? '' : title,
        'content':       content,
        'author':        user.name.isEmpty ? 'Hamba Allah' : user.name,
        'authorId':      uid,
        'likes':         0,
        'commentsCount': 0,
        'assetPath':     null,
        'category':      null,
        'createdAt':     FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _snack('Post berjaya diterbitkan!', color: kAccentGreen);
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _posting = false);
      _snack('Gagal terbitkan post. Cuba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final int len = _contentCtrl.text.length;
    final bool overLimit = len > _contentMax;

    return Scaffold(
      backgroundColor: kBackgroundDark,
      appBar: AppBar(
        backgroundColor: kBackgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: kTextSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Buat Post',
            style: TextStyle(color: kGoldLight, fontSize: 16, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _posting ? null : _submit,
              child: _posting
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryGold))
                  : const Text('Terbit',
                      style: TextStyle(color: kPrimaryGold, fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Jenis post ────────────────────────────────
              Row(children: [
                _typeChip('article', 'Renungan', Icons.article_rounded),
                const SizedBox(width: 10),
                _typeChip('quote', 'Petikan', Icons.format_quote_rounded),
              ]),

              const SizedBox(height: 20),

              // ── Tajuk (hanya utk Renungan) ─────────────────
              if (_postType == 'article') ...[
                const Text('Tajuk',
                    style: TextStyle(color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleCtrl,
                  maxLength: 80,
                  style: const TextStyle(color: kTextPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Tajuk ringkas...',
                    hintStyle: const TextStyle(color: kTextMuted),
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
                const SizedBox(height: 16),
              ],

              // ── Kandungan ───────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_postType == 'quote' ? 'Petikan' : 'Kandungan',
                      style: const TextStyle(color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                  Text('$len/$_contentMax',
                      style: TextStyle(
                          color: overLimit ? kWarningRed : kTextMuted, fontSize: 10.5)),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _contentCtrl,
                maxLines: 8,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: kTextPrimary, fontSize: 14, height: 1.5),
                decoration: InputDecoration(
                  hintText: _postType == 'quote'
                      ? 'Tulis petikan/kata hikmah...'
                      : 'Kongsi renungan, pengalaman, atau tazkirah anda...',
                  hintStyle: const TextStyle(color: kTextMuted),
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

              const SizedBox(height: 10),
              const Text(
                'Gambar/video belum disokong lagi — teks sahaja buat masa ini.',
                style: TextStyle(color: kTextMuted, fontSize: 10.5, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String type, String label, IconData icon) {
    final bool sel = _postType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _postType = type),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? kPrimaryGold.withOpacity(0.12) : kCardDark,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: sel ? kPrimaryGold : kBorderSubtle,
              width: sel ? 1.3 : 0.8,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: sel ? kPrimaryGold : kTextMuted),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? kGoldLight : kTextSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
