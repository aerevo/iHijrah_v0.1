// lib/utils/hadith_service.dart (UPGRADED 7.8/10)

import 'package:hijri/hijri_calendar.dart';
import 'hijri_service.dart';

/// Service untuk daily Hadith rotation
/// 
/// Features:
/// - Hadith collection (hardcoded, no JSON needed)
/// - Special hadith for specific dates (Asyura, Ramadan, etc)
/// - Daily rotation based on Hijri date (consistent per day)
/// - Category & topic classification
class HadithService {
  // ===== HADITH COLLECTION =====

  static final List<Map<String, String>> _hadithCollection = [
    {
      "text": "Amalan yang paling dicintai oleh Allah adalah amalan yang dilakukan secara berterusan (istiqamah) walaupun sedikit.",
      "riwayat": "Riwayat Bukhari & Muslim",
      "topik": "Istiqamah",
      "kategori": "Amalan"
    },
    {
      "text": "Tidaklah beriman salah seorang di antara kamu sehingga dia mencintai saudaranya sebagaimana dia mencintai dirinya sendiri.",
      "riwayat": "Riwayat Bukhari & Muslim",
      "topik": "Kasih Sayang",
      "kategori": "Akhlak"
    },
    {
      "text": "Senyummu di hadapan saudaramu adalah sedekah.",
      "riwayat": "Riwayat Tirmidzi",
      "topik": "Sedekah",
      "kategori": "Akhlak"
    },
    {
      "text": "Barangsiapa yang menempuh satu jalan untuk menuntut ilmu, maka Allah akan mudahkan baginya jalan menuju Syurga.",
      "riwayat": "Riwayat Muslim",
      "topik": "Menuntut Ilmu",
      "kategori": "Ilmu"
    },
    {
      "text": "Sebaik-baik manusia adalah yang paling bermanfaat bagi manusia lain.",
      "riwayat": "Riwayat Ahmad",
      "topik": "Kebaikan",
      "kategori": "Akhlak"
    },
    {
      "text": "Dunia ini adalah perhiasan, dan sebaik-baik perhiasan dunia adalah wanita yang solehah.",
      "riwayat": "Riwayat Muslim",
      "topik": "Keluarga",
      "kategori": "Kehidupan"
    },
    {
      "text": "Kebersihan itu sebahagian daripada iman.",
      "riwayat": "Riwayat Muslim",
      "topik": "Kebersihan",
      "kategori": "Akhlak"
    },
    {
      "text": "Solat berjemaah itu lebih afdal daripada solat bersendirian dengan dua puluh tujuh darjat.",
      "riwayat": "Riwayat Bukhari",
      "topik": "Solat Jemaah",
      "kategori": "Ibadah"
    },
    {
      "text": "Orang yang kuat bukanlah orang yang pandai bergulat, tetapi orang yang dapat menahan dirinya ketika marah.",
      "riwayat": "Riwayat Bukhari & Muslim",
      "topik": "Menahan Marah",
      "kategori": "Akhlak"
    },
    {
      "text": "Barangsiapa yang beriman kepada Allah dan hari akhir, maka hendaklah ia berkata baik atau diam.",
      "riwayat": "Riwayat Bukhari & Muslim",
      "topik": "Perkataan Baik",
      "kategori": "Akhlak"
    },
    {
      "text": "Sesungguhnya Allah tidak melihat kepada rupa dan harta kamu, tetapi Dia melihat kepada hati dan amalan kamu.",
      "riwayat": "Riwayat Muslim",
      "topik": "Keikhlasan",
      "kategori": "Hati"
    },
    {
      "text": "Mukmin yang kuat lebih baik dan lebih dicintai Allah daripada mukmin yang lemah.",
      "riwayat": "Riwayat Muslim",
      "topik": "Kekuatan",
      "kategori": "Iman"
    },
  ];

  // ===== SPECIAL DATE HADITHS =====

  static final Map<String, Map<String, String>> _specialHadiths = {
    "10 Muharram": {
      "text": "Puasa hari Asyura, aku berharap kepada Allah agar ia menghapuskan dosa setahun yang lalu.",
      "riwayat": "Riwayat Muslim",
      "topik": "Puasa Asyura",
      "kategori": "Puasa"
    },
    "1 Ramadan": {
      "text": "Apabila datang bulan Ramadan, pintu-pintu Syurga dibuka, pintu-pintu Neraka ditutup dan syaitan-syaitan dibelenggu.",
      "riwayat": "Riwayat Bukhari",
      "topik": "Ramadan",
      "kategori": "Puasa"
    },
    "15 Syaaban": {
      "text": "Sesungguhnya Allah melihat kepada makhluk-Nya pada malam nisfu Syaaban, lalu Dia mengampuni semua makhluk-Nya kecuali orang musyrik dan orang yang menyimpan dendam.",
      "riwayat": "Riwayat Ibnu Majah",
      "topik": "Nisfu Syaaban",
      "kategori": "Ampunan"
    },
    "27 Rajab": {
      "text": "Isra dan Mikraj adalah perjalanan paling mulia yang menunjukkan keagungan Allah dan keistimewaan Rasulullah SAW.",
      "riwayat": "Tafsir Sirah",
      "topik": "Isra Mikraj",
      "kategori": "Sejarah"
    },
  };

  // ===== PUBLIC METHODS =====

  /// Get hadith untuk hari ini (consistent sepanjang hari)
  /// 
  /// Logic: Guna formula matematik based on Hijri date
  /// supaya hadith kekal sama untuk hari yang sama
  static Map<String, String> getHadithForToday() {
    final today = HijriCalendar.now();
    final dateKey = "${today.hDay} ${today.getLongMonthName()}";

    // 1. Check special hadiths first
    if (_specialHadiths.containsKey(dateKey)) {
      return _specialHadiths[dateKey]!;
    }

    // 2. Use formula untuk select dari general collection
    // Formula: (day + month) % collection_length
    // Ini ensures hadith sama untuk tarikh yang sama
    int uniqueIndex = (today.hDay + today.hMonth) % _hadithCollection.length;
    
    return _hadithCollection[uniqueIndex];
  }

  /// Get hadith by topic
  static List<Map<String, String>> getByTopic(String topic) {
    final topicLower = topic.toLowerCase();
    return _hadithCollection
        .where((h) => (h['topik'] ?? '').toLowerCase().contains(topicLower))
        .toList();
  }

  /// Get hadith by category
  static List<Map<String, String>> getByCategory(String category) {
    final categoryLower = category.toLowerCase();
    return _hadithCollection
        .where((h) => (h['kategori'] ?? '').toLowerCase() == categoryLower)
        .toList();
  }

  /// Get random hadith (untuk variasi)
  static Map<String, String> getRandomHadith() {
    final now = DateTime.now();
    final randomIndex = now.millisecondsSinceEpoch % _hadithCollection.length;
    return _hadithCollection[randomIndex];
  }

  /// Get all hadiths
  static List<Map<String, String>> getAllHadiths() {
    return List.from(_hadithCollection);
  }

  /// Get all special date hadiths
  static Map<String, Map<String, String>> getSpecialHadiths() {
    return Map.from(_specialHadiths);
  }

  // ===== UTILITY =====

  /// Get total hadith count
  static int get totalCount => _hadithCollection.length;

  /// Get special hadith count
  static int get specialCount => _specialHadiths.length;

  /// Get all unique topics
  static List<String> getAllTopics() {
    final topics = <String>{};
    for (var hadith in _hadithCollection) {
      final topic = hadith['topik'];
      if (topic != null && topic.isNotEmpty) {
        topics.add(topic);
      }
    }
    return topics.toList()..sort();
  }

  /// Get all unique categories
  static List<String> getAllCategories() {
    final categories = <String>{};
    for (var hadith in _hadithCollection) {
      final category = hadith['kategori'];
      if (category != null && category.isNotEmpty) {
        categories.add(category);
      }
    }
    return categories.toList()..sort();
  }

  /// Search hadiths by keyword
  static List<Map<String, String>> search(String keyword) {
    final keywordLower = keyword.toLowerCase();
    
    return _hadithCollection.where((hadith) {
      final text = (hadith['text'] ?? '').toLowerCase();
      final topik = (hadith['topik'] ?? '').toLowerCase();
      final kategori = (hadith['kategori'] ?? '').toLowerCase();
      
      return text.contains(keywordLower) ||
             topik.contains(keywordLower) ||
             kategori.contains(keywordLower);
    }).toList();
  }

  /// Get hadith statistics
  static Map<String, dynamic> getStatistics() {
    final categories = <String, int>{};
    
    for (var hadith in _hadithCollection) {
      final category = hadith['kategori'] ?? 'Lain-lain';
      categories[category] = (categories[category] ?? 0) + 1;
    }

    return {
      'total': _hadithCollection.length,
      'special_dates': _specialHadiths.length,
      'by_category': categories,
      'topics': getAllTopics().length,
    };
  }

  // ===== HELPERS FOR FUTURE EXPANSION =====

  /// Add custom hadith (for future feature - user can add their own)
  static void addCustomHadith(Map<String, String> hadith) {
    // Validate required fields
    if (hadith.containsKey('text') && 
        hadith.containsKey('riwayat')) {
      _hadithCollection.add(hadith);
    }
  }

  /// Format hadith untuk display
  static String formatHadith(Map<String, String> hadith, {bool includeSource = true}) {
    final text = hadith['text'] ?? '';
    final riwayat = hadith['riwayat'] ?? '';
    
    if (includeSource && riwayat.isNotEmpty) {
      return '$text\n\n— $riwayat';
    }
    
    return text;
  }
}