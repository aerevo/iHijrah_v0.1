// lib/widgets/dialogs/fardhu_warning_dialog.dart (UPGRADED 7.8/10)
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

// Fungsi global untuk memanggil dialog amaran
void showFardhuWarningDialog(BuildContext context, VoidCallback onContinue) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: kCardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        side: BorderSide(color: kWarningRed.withOpacity(0.8)),
      ),
      title: const Text(
        'Amaran Mentor Fardhu',
        style: TextStyle(color: kWarningRed, fontWeight: FontWeight.bold)
      ),
      content: const Text(
        'Anda belum merekodkan sebarang Solat Fardhu hari ini.\n\n'
        'Amalan sunat adalah hebat, tetapi Pokok Embun Jiwa anda paling subur dengan siraman FARDHU.\n\n'
        'Utamakan yang wajib dahulu?',
        style: TextStyle(color: kTextSecondary, height: 1.5, fontSize: AppFontSizes.md),
      ),
      actions: [
        TextButton(
          child: const Text('Rekod Fardhu', style: TextStyle(color: kPrimaryGold)),
          onPressed: () => Navigator.of(ctx).pop(), // Tutup dialog
        ),
        TextButton(
          child: const Text('Teruskan Sunat', style: TextStyle(color: kTextSecondary)),
          onPressed: () {
            Navigator.of(ctx).pop();
            onContinue(); // Jalankan amalan sunat
          },
        ),
      ],
    ),
  );
}