// lib/widgets/about_view.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart';
import 'canopy_mark.dart';

class AboutView extends StatelessWidget {
  const AboutView({Key? key}) : super(key: key);

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── LOGO + NAMA ────────────────────────────────────
        Center(
          child: Column(
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: kPrimaryGold.withOpacity(0.5), width: 1.5),
                  color: kPrimaryGold.withOpacity(0.08),
                ),
                child: const Center(
                  child: CanopyMark(size: 38, color: kPrimaryGold),
                ),
              ),
              const SizedBox(height: 12),
              MetallicGold(
                child: Text(
                  'iHijrah',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Embun Jiwa',
                style: TextStyle(
                  color: kTextSecondary,
                  fontSize: 12,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: kPrimaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: kPrimaryGold.withOpacity(0.25)),
                ),
                child: const Text(
                  'Versi 1.0.0',
                  style: TextStyle(
                      color: kPrimaryGold,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── MISI ──────────────────────────────────────────
        _section(
          icon:  Icons.favorite_rounded,
          title: 'Misi Kami',
          body:  'iHijrah hadir untuk membantu umat Islam menemui semula identiti Hijrah mereka. '
                 'Setiap tarikh lahir, setiap umur — ada maknanya dalam kalendar Islam.',
        ),

        const SizedBox(height: 14),

        // ── CIRI ──────────────────────────────────────────
        _section(
          icon:  Icons.star_rounded,
          title: 'Ciri Utama',
          body:  '🌙  Identiti & umur Hijrah\n'
                 '🌳  Pokok Hijrah gamifikasi\n'
                 '📖  Hadith, amalan & sirah harian\n'
                 '🤝  Komuniti Muslim tempatan\n'
                 '🕌  Waktu solat & azan',
        ),

        const SizedBox(height: 14),

        // ── PEMBANGUN ─────────────────────────────────────
        _section(
          icon:  Icons.code_rounded,
          title: 'Dibangunkan Oleh',
          body:  'Solo developer dengan penuh semangat dan doa.\n'
                 'Dibina dengan Flutter & cinta kepada Islam. 💛',
        ),

        const SizedBox(height: 20),

        // ── PAUTAN ────────────────────────────────────────
        const Text(
          'HUBUNGI KAMI',
          style: TextStyle(
            color: kTextSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),

        _linkTile(
          icon:    Icons.chat_rounded,
          label:   'WhatsApp Admin',
          sub:     'Pertanyaan & infaq',
          color:   const Color(0xFF25D366),
          onTap:   () => _launch(
              'whatsapp://send?phone=+60133662440&text='
              'Assalamualaikum Admin iHijrah'),
        ),

        const SizedBox(height: 8),

        _linkTile(
          icon:    Icons.email_rounded,
          label:   'E-mel',
          sub:     'admin@ihijrah.my',
          color:   kAccentTeal,
          onTap:   () => _launch('mailto:admin@ihijrah.my'),
        ),

        const SizedBox(height: 20),

        // Disclaimer
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          ),
          child: const Text(
            'iHijrah adalah aplikasi bebas iklan. '
            'Infaq anda membantu pembangunan berterusan.',
            style: TextStyle(
              color: kTextMuted,
              fontSize: 10,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _section({
    required IconData icon,
    required String   title,
    required String   body,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCardDark,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: kBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimaryGold, size: 15),
              const SizedBox(width: 7),
              Text(title,
                  style: const TextStyle(
                    color: kGoldLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(
                color: kTextSecondary,
                fontSize: 12,
                height: 1.55,
              )),
        ],
      ),
    );
  }

  Widget _linkTile({
    required IconData  icon,
    required String    label,
    required String    sub,
    required Color     color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                Text(sub,
                    style: const TextStyle(
                        color: kTextSecondary, fontSize: 10)),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                color: color.withOpacity(0.5), size: 12),
          ],
        ),
      ),
    );
  }
}
