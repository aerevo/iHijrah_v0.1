import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Perlukan intl untuk format tarikh
import '../utils/constants.dart';
import 'metallic_gold.dart';

class SirahCard extends StatefulWidget {
  const SirahCard({Key? key}) : super(key: key);

  @override
  State<SirahCard> createState() => _SirahCardState();
}

class _SirahCardState extends State<SirahCard> {
  // Pangkalan Data Mini: Fakta Sirah
  final List<Map<String, String>> _sirahDatabase = [
    {"title": "Kelahiran Nabi SAW", "desc": "Nabi Muhammad SAW diputerakan pada 12 Rabiulawal Tahun Gajah di Makkah."},
    {"title": "Wahyu Pertama", "desc": "Wahyu pertama turun di Gua Hira' melalui Jibril AS (Surah Al-Alaq: 1-5)."},
    {"title": "Hijrah ke Madinah", "desc": "Peristiwa Hijrah menandakan permulaan kalendar Islam dan pembentukan negara Islam pertama."},
    {"title": "Perang Badar", "desc": "Kemenangan besar pertama tentera Islam berlaku pada 17 Ramadan tahun ke-2 Hijrah."},
    {"title": "Fathul Makkah", "desc": "Pembebasan kota Makkah berlaku pada tahun ke-8 Hijrah tanpa pertumpahan darah."},
    {"title": "Israk Mikraj", "desc": "Perjalanan agung Nabi dari Masjidil Haram ke Masjidil Aqsa, lalu ke Sidratul Muntaha."},
    {"title": "Piagam Madinah", "desc": "Perlembagaan bertulis pertama di dunia yang digubal oleh Rasulullah SAW."},
    {"title": "Kewafatan Nabi SAW", "desc": "Rasulullah SAW wafat pada 12 Rabiulawal tahun ke-11 Hijrah di Madinah."},
    {"title": "Saidina Abu Bakar", "desc": "Khalifah pertama Islam dan sahabat paling rapat dengan Rasulullah SAW."},
    {"title": "Saidina Umar", "desc": "Digelar Al-Faruq (Pemisah Hak & Batil). Islam berkembang pesat di zamannya."},
    {"title": "Perang Uhud", "desc": "Pengajaran tentang pentingnya taat kepada arahan pemimpin (Rasulullah SAW)."},
    {"title": "Perjanjian Hudaibiyah", "desc": "Gencatan senjata yang membuka jalan kepada penyebaran dakwah secara diplomatik."},
    {"title": "Baitul Maqdis", "desc": "Kiblat pertama umat Islam sebelum diperintahkan bertukar ke Kaabah."},
    {"title": "Bilal bin Rabah", "desc": "Muazzin pertama Islam, simbol keteguhan iman walaupun disiksa."},
    {"title": "Khadijah RA", "desc": "Wanita pertama memeluk Islam dan isteri tercinta Rasulullah SAW."},
    {"title": "Tahun Kesedihan", "desc": "Tahun kewafatan Khadijah RA dan Abu Talib, sebelum peristiwa Israk Mikraj."},
    {"title": "Masjid Quba", "desc": "Masjid pertama yang dibina oleh Rasulullah SAW semasa perjalanan Hijrah."},
    {"title": "Salman Al-Farisi", "desc": "Sahabat yang mencadangkan strategi gali parit dalam Perang Khandaq."},
    {"title": "Khalid Al-Walid", "desc": "Digelar 'Pedang Allah' yang tidak pernah kalah dalam pertempuran."},
    {"title": "Mus'ab bin Umair", "desc": "Duta pertama Islam yang dihantar ke Madinah sebelum Hijrah."},
  ];

  Map<String, String> _getTodaySirah() {
    final now = DateTime.now();
    // Gunakan 'Day of Year' (1-365) untuk pilih fakta supaya ia berubah setiap hari
    // tapi konsisten untuk semua user pada hari tersebut.
    int dayOfYear = int.parse(DateFormat("D").format(now));
    int index = dayOfYear % _sirahDatabase.length;
    
    // TODO: Di masa depan, boleh tambah logic check tarikh Hijrah spesifik (cth: 12 Rabiulawal)
    
    return _sirahDatabase[index];
  }

  @override
  Widget build(BuildContext context) {
    final sirah = _getTodaySirah();
    final dateStr = DateFormat('d MMMM yyyy', 'ms_MY').format(DateTime.now()); // Perlukan locale 'ms_MY'

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardDark,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        border: Border.all(color: Colors.white10),
        image: const DecorationImage(
          image: AssetImage('assets/images/logo.png'), // Watermark
          opacity: 0.05,
          alignment: Alignment.bottomRight,
          scale: 0.5,
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tarikh & Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.history_edu, color: kPrimaryGold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "SIRAH HARIAN",
                    style: TextStyle(
                      color: kPrimaryGold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              Text(
                dateStr, // Tarikh Hari Ini
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
          
          const SizedBox(height: 15),
          
          // Content: Title
          MetallicGold(
            isShimmering: false,
            child: Text(
              sirah['title']!.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                fontFamily: 'Playfair',
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Content: Description
          Text(
            sirah['desc']!,
            style: const TextStyle(
              color: kTextSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Footer: Read More
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "BACA LANJUT →",
              style: TextStyle(
                color: kAccentOlive,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}