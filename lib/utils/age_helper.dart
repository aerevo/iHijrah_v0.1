// lib/utils/age_helper.dart
//
// Kira umur Gregorian TEPAT — ambil kira sama ada hari lahir tahun ni
// dah lepas atau belum, bukan sekadar (tahunSekarang - tahunLahir).
//
// NOTA PENTING (baca sebelum guna / ubah fail ni):
//
// 1) DATE-ONLY, bukan DateTime penuh.
//    Semua fungsi di sini baca .year/.month/.day sahaja daripada input.
//    Jam/minit/timezone pada objek DateTime yang dihantar caller
//    LANGSUNG DIABAIKAN. Sebab: kalau kita compare DateTime penuh
//    (dengan time-of-day), "sekarang" yang dikira lewat malam di satu
//    zon waktu boleh accidentally jatuh ke hari sebelum/lepas di zon
//    lain, lalu tersalah kira hari lahir dah lepas atau belum. Dengan
//    hanya guna komponen kalendar (year/month/day), isu ni terus tak
//    wujud — tak kira apa timezone asal DateTime tu datang dari.
//
// 2) 29 FEBRUARI (leap day).
//    Pada tahun BUKAN leap, hari lahir 29 Feb dianggap disambut PADA
//    28 FEBRUARI. Ini KEPUTUSAN PRODUK yang eksplisit dibuat di sini
//    (bukan bug/oversight) — kalau nak convention lain (cth. 1 Mac),
//    tukar SAHAJA di _observedBirthdayInYear(); semua fungsi lain
//    dalam fail ni guna helper tu, jadi konsisten automatik.
//
// 3) BUKAN age-gate / security enforcement.
//    Fail ni cuma kira fakta umur. Ia TIDAK membuat keputusan sama ada
//    seseorang "dibenarkan" atau tidak — itu keputusan business logic
//    di tempat lain (cth. UI pendaftaran) yang PANGGIL isAtLeastAge()
//    dengan minAge pilihan mereka sendiri.
//
// 4) TIADA minimum umur "default" dikunci di sini.
//    isAtLeastAge() mewajibkan caller hantar minAge secara eksplisit.
//    Sebarang angka (cth. 13) adalah PRODUCT SETTING yang caller
//    tetapkan sendiri — fail ni tidak claim ia sebagai keperluan
//    undang-undang.

/// Umur Gregorian tepat pada tarikh `now` (default: tarikh sistem hari
/// ni). Pulangkan 0 kalau birthdate tersilap di masa depan (elak umur
/// negatif memualukan UI) — caller yang patut validate input asal.
int calculateExactAge(DateTime birthdate, [DateTime? now]) {
  final DateTime today = now ?? DateTime.now();

  int age = today.year - birthdate.year;
  // Guna _observedBirthdayInYear() + _dayNumber() — SAMA convention
  // dengan isBirthdayToday()/daysUntilNextBirthday() (nota 2 di atas
  // fail). Sebelum ni fungsi ni compare today.month/today.day terus,
  // jadi orang lahir 29 Feb boleh dapat isBirthdayToday()==true pada
  // 28 Feb (tahun bukan leap) sedangkan umur di sini belum bertambah —
  // dua sumber kebenaran tak sync. Guna _dayNumber() je (bukan
  // .month/.day terus) supaya tak perlu uruskan kes bulan berbeza.
  final DateTime observedBirthdayThisYear =
      _observedBirthdayInYear(birthdate, today.year);
  final bool birthdayReachedThisYear =
      _dayNumber(today) >= _dayNumber(observedBirthdayThisYear);
  if (!birthdayReachedThisYear) age -= 1;

  return age < 0 ? 0 : age;
}

/// True jika umur (pada `now`) sudah >= `minAge`. `minAge` WAJIB
/// dihantar caller — lihat nota (4) di atas fail.
bool isAtLeastAge(DateTime birthdate, int minAge, [DateTime? now]) {
  return calculateExactAge(birthdate, now) >= minAge;
}

/// Paparan ringkas Bahasa Melayu, cth. "34 Tahun".
String ageDisplayString(DateTime birthdate, [DateTime? now]) {
  return '${calculateExactAge(birthdate, now)} Tahun';
}

/// Baki hari ke hari lahir seterusnya (0 = hari ni). Dikira melalui
/// nombor hari kalendar (UTC-anchored), BUKAN Duration.difference()
/// atas DateTime tempatan — supaya DST (hari 23/25 jam) tak jadikan
/// jawapan off-by-one berhampiran pertukaran waktu.
int daysUntilNextBirthday(DateTime birthdate, [DateTime? now]) {
  final DateTime today = now ?? DateTime.now();

  DateTime next = _observedBirthdayInYear(birthdate, today.year);
  if (_dayNumber(next) < _dayNumber(today)) {
    next = _observedBirthdayInYear(birthdate, today.year + 1);
  }
  return _dayNumber(next) - _dayNumber(today);
}

/// True jika hari ni ialah hari lahir (ikut convention 29 Feb → 28 Feb
/// pada tahun bukan leap — lihat nota (2) di atas fail).
bool isBirthdayToday(DateTime birthdate, [DateTime? now]) {
  return daysUntilNextBirthday(birthdate, now) == 0;
}

// ── HELPER DALAMAN ─────────────────────────────────────────────────

/// Tarikh hari lahir "disambut" pada tahun `year` — lihat nota (2).
DateTime _observedBirthdayInYear(DateTime birthdate, int year) {
  if (birthdate.month == 2 && birthdate.day == 29 && !_isLeapYear(year)) {
    return DateTime(year, 2, 28);
  }
  return DateTime(year, birthdate.month, birthdate.day);
}

bool _isLeapYear(int year) =>
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

/// Nombor hari kalendar sejak epoch, dikira guna komponen y/m/d
/// SAHAJA (anchor ke UTC tengah malam) — tiada DST langsung terlibat,
/// tak kira DateTime input tu tempatan atau ada time-of-day apa pun.
int _dayNumber(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;
