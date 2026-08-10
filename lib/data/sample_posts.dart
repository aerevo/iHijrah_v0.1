// lib/data/sample_posts.dart
//
// Dummy posts untuk development — guna assets sedia ada.
// Import dan guna dalam feed screen:
//
//   import '../data/sample_posts.dart';
//   final posts = kSamplePosts;

import '../models/user_model.dart';

const List<PostModel> kSamplePosts = [

  // ── 1. SIRAH — artikel ────────────────────────────────────
  PostModel(
    id:           'p001',
    type:         'sirah',
    category:     'Sirah',
    title:        'Kisah Hijrah Rasulullah',
    content:      'Detik cemas di Gua Thur. Bagaimana laba-laba dan burung '
                  'merpati menjadi saksi agung pertolongan Allah kepada baginda '
                  'Rasulullah ﷺ dalam perjalanan hijrah yang penuh pengorbanan '
                  'dan tawakkal yang sempurna.',
    author:       'Ustaz Don',
    authorAge:    '40H',
    time:         '2j lalu',
    likes:        247,
    commentsCount: 18,
    assetPath:    'assets/images/dummy_post1.jpg',
  ),

  // ── 2. VIDEO — tazkirah ───────────────────────────────────
  PostModel(
    id:           'p002',
    type:         'video',
    category:     'Video',
    title:        'Tentang Dosa Tersembunyi',
    content:      'Dosa yang paling berbahaya bukan dosa yang nampak besar, '
                  'tetapi dosa kecil yang kita ulang-ulang tanpa sedar hingga '
                  'menghitamkan hati secara perlahan-lahan.',
    author:       'Ustaz Ridhwan',
    authorAge:    '52H',
    time:         '12:34',
    likes:        89,
    commentsCount: 5,
    assetPath:    'assets/images/langit.png',
  ),

  // ── 3. PETIKAN — Imam Malik ───────────────────────────────
  PostModel(
    id:           'p003',
    type:         'quote',
    category:     'Petikan',
    title:        '',
    content:      'Ilmu bukan pada apa yang dihafal, tetapi pada apa yang '
                  'memberi manfaat.',
    author:       'Imam Malik',
    authorAge:    '88H',
    time:         '1 hari lalu',
    likes:        3200,
    commentsCount: 0,
  ),

  // ── 4. HADITH — Sahih Muslim ──────────────────────────────
  PostModel(
    id:           'p004',
    type:         'hadith',
    category:     'Sahih Muslim · No. 145',
    title:        '',
    content:      'Islam itu dimulai dalam keadaan asing dan akan kembali '
                  'asing sebagaimana permulaannya. Maka beruntunglah '
                  'orang-orang yang asing itu.',
    author:       'Daripada Abu Hurairah r.a. · Riwayat Muslim · '
                  'Bab al-Islam bada\'a ghariban',
    authorAge:    '58H',
    time:         '3 hari lalu',
    likes:        1800,
    commentsCount: 12,
  ),

  // ── 5. ARTIKEL — amalan ───────────────────────────────────
  PostModel(
    id:           'p005',
    type:         'amalan',
    category:     'Amalan',
    title:        'Faedah Solat Subuh',
    content:      'Mereka yang bangun untuk solat Subuh berjemaah akan '
                  'mendapat cahaya yang sempurna pada hari Kiamat. Inilah '
                  'janji Allah kepada hamba-hambaNya yang setia menjaga '
                  'waktu solat pertama hari.',
    author:       'Ustaz Azmi',
    authorAge:    '33H',
    time:         '5j lalu',
    likes:        412,
    commentsCount: 31,
    assetPath:    'assets/images/pokok_intro.png',
  ),

  // ── 6. VIDEO — sirah ─────────────────────────────────────
  PostModel(
    id:           'p006',
    type:         'video',
    category:     'Sirah',
    title:        'Tentang Perang Badar',
    content:      'Perang pertama dalam sejarah Islam. 313 orang Muslim '
                  'menentang 1,000 tentera Quraish. Ketika akal manusia '
                  'berkata mustahil, pertolongan Allah membuktikan sebaliknya.',
    author:       'Ustaz Fadzillah',
    authorAge:    '61H',
    time:         '08:42',
    likes:        156,
    commentsCount: 9,
    assetPath:    'assets/images/dummy_post2.jpg',
  ),

  // ── 7. PETIKAN — Imam Syafii ─────────────────────────────
  PostModel(
    id:           'p007',
    type:         'quote',
    category:     'Petikan',
    title:        '',
    content:      'Sabar itu ada dua jenis: sabar atas apa yang '
                  'menyakitkan kamu, dan sabar menahan diri daripada '
                  'apa yang kamu inginkan.',
    author:       'Imam al-Syafii',
    authorAge:    '72H',
    time:         '2 hari lalu',
    likes:        2100,
    commentsCount: 7,
  ),

  // ── 8. TIKET — acara ─────────────────────────────────────
  PostModel(
    id:           'p008',
    type:         'event',
    category:     'Acara',
    title:        'Majlis Ilmu Perdana',
    content:      '',
    author:       'Admin iHijrah',
    authorAge:    '',
    time:         '8:00 pagi',
    likes:        500,
    commentsCount: 0,
  ),

  // ── 9. ARTIKEL — tazkirah ────────────────────────────────
  PostModel(
    id:           'p009',
    type:         'tazkirah',
    category:     'Tazkirah',
    title:        'Tawakal Kepada Allah',
    content:      'Tawakal bukan bermaksud duduk diam tanpa usaha. Tawakal '
                  'adalah kamu berusaha sepenuh hati, kemudian kamu serahkan '
                  'hasilnya kepada Allah yang Maha Mengetahui apa yang terbaik '
                  'untuk hambaNya.',
    author:       'Ustaz Hanif',
    authorAge:    '28H',
    time:         '8j lalu',
    likes:        318,
    commentsCount: 22,
    assetPath:    'assets/images/wallpaper.png',
  ),

  // ── 10. HADITH — Sahih Bukhari ────────────────────────────
  PostModel(
    id:           'p010',
    type:         'hadith',
    category:     'Sahih Bukhari · No. 6018',
    title:        '',
    content:      'Sesiapa yang beriman kepada Allah dan hari akhirat, '
                  'maka hendaklah ia berkata yang baik atau diam.',
    author:       'Daripada Abu Hurairah r.a. · Riwayat Bukhari & Muslim · '
                  'Bab man kana yu\'minu billahi',
    authorAge:    '58H',
    time:         '4 hari lalu',
    likes:        945,
    commentsCount: 3,
  ),

  // ── 11. ARTIKEL — sirah ───────────────────────────────────
  PostModel(
    id:           'p011',
    type:         'sirah',
    category:     'Sirah',
    title:        'Tentang Khadijah al-Kubra',
    content:      'Wanita pertama yang memeluk Islam. Beliau adalah peniaga '
                  'yang berjaya, isteri yang setia, dan ibu yang penyayang. '
                  'Pengorbanan Siti Khadijah menjadi asas kepada perkembangan '
                  'dakwah Rasulullah ﷺ di peringkat awal.',
    author:       'Ustazah Halimah',
    authorAge:    '45H',
    time:         '1j lalu',
    likes:        533,
    commentsCount: 41,
    assetPath:    'assets/images/pokok_level2.png',
  ),

  // ── 12. PETIKAN — Ibn Qayyim ─────────────────────────────
  PostModel(
    id:           'p012',
    type:         'quote',
    category:     'Petikan',
    title:        '',
    content:      'Hati yang hidup adalah hati yang sentiasa mengingati Allah, '
                  'kerana zikir adalah makanan roh sebagaimana makanan '
                  'adalah keperluan jasad.',
    author:       'Ibn Qayyim al-Jawziyyah',
    authorAge:    '91H',
    time:         '6 jam lalu',
    likes:        1650,
    commentsCount: 14,
  ),
];
