// lib/providers/daily_content_provider.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';

// ── MODELS ──────────────────────────────────────────────────────

class SirahToday {
  final String tajuk;
  final String tahun;
  final String lokasi;
  final String pengajaran;

  SirahToday({
    required this.tajuk,
    required this.tahun,
    required this.lokasi,
    required this.pengajaran,
  });

  factory SirahToday.fromJson(Map<String, dynamic> json) {
    return SirahToday(
      tajuk: json['peristiwa'] ?? 'Tiada Tajuk',
      tahun: '${json['tahun_hijrah']}H (${json['tahun_masihi']}M)',
      lokasi: json['lokasi'] ?? 'Lokasi Tidak Dinyatakan',
      pengajaran: json['pengajaran'] ?? 'Tiada pengajaran direkodkan.',
    );
  }
}

class AmalanToday {
  final String id;
  final String title;
  final String source;
  final String type; // 'khas' | 'mingguan'
  final String reward;
  bool isCompleted;

  AmalanToday({
    required this.id,
    required this.title,
    required this.source,
    required this.type,
    this.reward = '',
    this.isCompleted = false,
  });
}

class HadithToday {
  final String text;
  final String riwayat;
  final String topik;
  final String kategori;
  final bool isSpecial; // true = hadith tarikh khas

  HadithToday({
    required this.text,
    required this.riwayat,
    required this.topik,
    required this.kategori,
    this.isSpecial = false,
  });
}

// ── PROVIDER ────────────────────────────────────────────────────

class DailyContentProvider with ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  SirahToday? _todaySirah;
  SirahToday? get todaySirah => _todaySirah;

  List<AmalanToday> _todayAmalanList = [];
  List<AmalanToday> get todayAmalanList => _todayAmalanList;

  HadithToday? _todayHadith;
  HadithToday? get todayHadith => _todayHadith;

  String? popupMessage;

  DailyContentProvider() {
    loadDailyContent();
  }

  Future<void> loadDailyContent() async {
    _isLoading = true;
    popupMessage = null;
    notifyListeners();

    final HijriCalendar today = HijriCalendar.now();

    try {
      // ── 1. SIRAH ──────────────────────────────────────────────
      final String sirahRaw =
          await rootBundle.loadString('assets/data/sirah_data.json');
      final Map<String, dynamic> sirahData = json.decode(sirahRaw);

      final String sirahKey =
          '${today.hDay.toString().padLeft(2, '0')}-${today.hMonth.toString().padLeft(2, '0')}';

      if (sirahData.containsKey(sirahKey)) {
        _todaySirah = SirahToday.fromJson(sirahData[sirahKey]);
      } else {
        final keys = sirahData.keys.toList();
        if (keys.isNotEmpty) {
          _todaySirah =
              SirahToday.fromJson(sirahData[keys[Random().nextInt(keys.length)]]);
        }
      }

      // ── 2. AMALAN SUNNAH ──────────────────────────────────────
      final String amalanRaw =
          await rootBundle.loadString('assets/data/amalan_sunnah.json');
      final List<dynamic> amalanData = json.decode(amalanRaw);

      _todayAmalanList = [];

      final DateTime now = DateTime.now();
      final String dayNameMy = _getDayName(now.weekday);

      final List<String> bulanHijrah = [
        'Muharram', 'Safar', 'Rabiulawal', 'Rabiulakhir',
        'Jamadilawal', 'Jamadilakhir', 'Rejab', 'Syaaban',
        'Ramadan', 'Syawal', 'Zulkaedah', 'Zulhijjah',
      ];
      final String hijriDateStr =
          '${today.hDay} ${bulanHijrah[today.hMonth - 1]}';

      // Ayyamul Bidh = 13, 14, 15 setiap bulan Hijri
      final bool isAyyamulBidh =
          today.hDay == 13 || today.hDay == 14 || today.hDay == 15;

      // Malam = selepas Isyak (8pm) atau sebelum Subuh (5am)
      final bool isMalam = now.hour >= 20 || now.hour < 5;

      for (var item in amalanData) {
        final String hariItem = item['hari'].toString();
        bool include = false;
        String type = 'mingguan';

        if (hariItem == hijriDateStr) {
          // Tarikh Hijri tepat — contoh "10 Muharram", "9 Zulhijjah"
          include = true;
          type = 'khas';
        } else if (hariItem == 'Ayyamul Bidh' && isAyyamulBidh) {
          // 13/14/15 bulan Hijri
          include = true;
          type = 'khas';
        } else if (hariItem == 'Malam' && isMalam) {
          // Amalan malam — Tahajjud, Witir, 3 Qul, dll
          include = true;
        } else if (hariItem.toLowerCase() == dayNameMy.toLowerCase()) {
          if (['Isnin', 'Khamis', 'Jumaat'].contains(dayNameMy)) {
            include = true;
          }
        } else if (hariItem == 'Setiap hari') {
          if (now.hour > 7 && now.hour < 12 && popupMessage == null) {
            popupMessage = 'Peringatan Dhuha: 2 rakaat yang mencukupkan rezeki.';
          }
        }

        if (include) {
          _todayAmalanList.add(AmalanToday(
            id: item['id'],
            title: item['amalan'],
            source: item['sumber'] ?? '',
            type: type,
            reward: item['huraian'] ?? '',
          ));
        }
      }

      _todayAmalanList.sort((a, b) {
        if (a.type == 'khas' && b.type != 'khas') return -1;
        if (a.type != 'khas' && b.type == 'khas') return 1;
        return 0;
      });

      if (_todayAmalanList.isEmpty) {
        _todayAmalanList.add(AmalanToday(
          id: 'rest_day',
          title: 'Tiada Amalan Khusus Hari Ini',
          source: 'Rehat & Fokus Ibadah Wajib',
          type: 'mingguan',
          reward: 'Fokus pada kualiti solat fardu anda hari ini.',
        ));
      }

      // ── 3. HADITH ─────────────────────────────────────────────
      _todayHadith = _getHadithForToday(today);

    } catch (e) {
      debugPrint('❌ DailyContentProvider error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleAmalan(String id) {
    final int index = _todayAmalanList.indexWhere((a) => a.id == id);
    if (index != -1) {
      _todayAmalanList[index].isCompleted =
          !_todayAmalanList[index].isCompleted;
      notifyListeners();
    }
  }

  // ── HADITH LOGIC (inline) ──────────────────────────────────────

  static const List<Map<String, String>> _hadithCollection = [
    {'text': 'Amalan yang paling dicintai oleh Allah adalah amalan yang dilakukan secara berterusan walaupun sedikit.', 'riwayat': 'Bukhari & Muslim', 'topik': 'Istiqamah', 'kategori': 'Amalan'},
    {'text': 'Tidaklah beriman salah seorang di antara kamu sehingga dia mencintai saudaranya sebagaimana dia mencintai dirinya sendiri.', 'riwayat': 'Bukhari & Muslim', 'topik': 'Kasih Sayang', 'kategori': 'Akhlak'},
    {'text': 'Senyummu di hadapan saudaramu adalah sedekah.', 'riwayat': 'Tirmidzi', 'topik': 'Sedekah', 'kategori': 'Akhlak'},
    {'text': 'Barangsiapa yang menempuh satu jalan untuk menuntut ilmu, maka Allah akan mudahkan baginya jalan menuju Syurga.', 'riwayat': 'Muslim', 'topik': 'Menuntut Ilmu', 'kategori': 'Ilmu'},
    {'text': 'Sebaik-baik manusia adalah yang paling bermanfaat bagi manusia lain.', 'riwayat': 'Ahmad', 'topik': 'Kebaikan', 'kategori': 'Akhlak'},
    {'text': 'Kebersihan itu sebahagian daripada iman.', 'riwayat': 'Muslim', 'topik': 'Kebersihan', 'kategori': 'Akhlak'},
    {'text': 'Solat berjemaah itu lebih afdal daripada solat bersendirian dengan dua puluh tujuh darjat.', 'riwayat': 'Bukhari', 'topik': 'Solat Jemaah', 'kategori': 'Ibadah'},
    {'text': 'Orang yang kuat bukanlah orang yang pandai bergulat, tetapi orang yang dapat menahan dirinya ketika marah.', 'riwayat': 'Bukhari & Muslim', 'topik': 'Menahan Marah', 'kategori': 'Akhlak'},
    {'text': 'Barangsiapa yang beriman kepada Allah dan hari akhir, maka hendaklah ia berkata baik atau diam.', 'riwayat': 'Bukhari & Muslim', 'topik': 'Perkataan Baik', 'kategori': 'Akhlak'},
    {'text': 'Sesungguhnya Allah tidak melihat kepada rupa dan harta kamu, tetapi Dia melihat kepada hati dan amalan kamu.', 'riwayat': 'Muslim', 'topik': 'Keikhlasan', 'kategori': 'Hati'},
    {'text': 'Mukmin yang kuat lebih baik dan lebih dicintai Allah daripada mukmin yang lemah.', 'riwayat': 'Muslim', 'topik': 'Kekuatan', 'kategori': 'Iman'},
    {'text': 'Dunia ini adalah perhiasan, dan sebaik-baik perhiasan dunia adalah wanita yang solehah.', 'riwayat': 'Muslim', 'topik': 'Keluarga', 'kategori': 'Kehidupan'},
  ];

  static const Map<String, Map<String, String>> _specialHadiths = {
    '10 Muharram': {'text': 'Puasa hari Asyura, aku berharap kepada Allah agar ia menghapuskan dosa setahun yang lalu.', 'riwayat': 'Muslim', 'topik': 'Puasa Asyura', 'kategori': 'Puasa'},
    '1 Ramadan':   {'text': 'Apabila datang bulan Ramadan, pintu-pintu Syurga dibuka, pintu-pintu Neraka ditutup dan syaitan-syaitan dibelenggu.', 'riwayat': 'Bukhari', 'topik': 'Ramadan', 'kategori': 'Puasa'},
    '15 Syaaban':  {'text': 'Sesungguhnya Allah melihat kepada makhluk-Nya pada malam nisfu Syaaban, lalu Dia mengampuni semua makhluk-Nya kecuali orang musyrik dan orang yang menyimpan dendam.', 'riwayat': 'Ibn Majah', 'topik': 'Nisfu Syaaban', 'kategori': 'Ampunan'},
    '27 Rejab':    {'text': 'Isra dan Mikraj adalah perjalanan paling mulia yang menunjukkan keagungan Allah dan keistimewaan Rasulullah SAW.', 'riwayat': 'Tafsir Sirah', 'topik': 'Isra Mikraj', 'kategori': 'Sejarah'},
  };

  HadithToday _getHadithForToday(HijriCalendar today) {
    final List<String> bulanEng = [
      'Muharram', 'Safar', 'Rabi al-awwal', 'Rabi al-thani',
      'Jumada al-awwal', 'Jumada al-thani', 'Rajab', "Sha'ban",
      'Ramadan', 'Shawwal', "Dhu al-Qi'dah", 'Dhu al-Hijjah',
    ];
    // Try Malay name first (matches _specialHadiths keys)
    final List<String> bulanMy = [
      'Muharram', 'Safar', 'Rabiulawal', 'Rabiulakhir',
      'Jamadilawal', 'Jamadilakhir', 'Rejab', 'Syaaban',
      'Ramadan', 'Syawal', 'Zulkaedah', 'Zulhijjah',
    ];

    final String dateKeyMy = '${today.hDay} ${bulanMy[today.hMonth - 1]}';

    if (_specialHadiths.containsKey(dateKeyMy)) {
      final m = _specialHadiths[dateKeyMy]!;
      return HadithToday(
        text: m['text']!,
        riwayat: m['riwayat']!,
        topik: m['topik']!,
        kategori: m['kategori']!,
        isSpecial: true,
      );
    }

    final int index =
        (today.hDay + today.hMonth) % _hadithCollection.length;
    final m = _hadithCollection[index];
    return HadithToday(
      text: m['text']!,
      riwayat: m['riwayat']!,
      topik: m['topik']!,
      kategori: m['kategori']!,
    );
  }

  String _getDayName(int weekday) {
    const days = ['', 'Isnin', 'Selasa', 'Rabu', 'Khamis', 'Jumaat', 'Sabtu', 'Ahad'];
    return days[weekday];
  }
}
