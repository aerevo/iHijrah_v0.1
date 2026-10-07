// lib/utils/bounded_timeout.dart
// Pengiraan had masa bagi satu operasi rangkaian dalam laluan padam akaun.
// Fungsi tulen (tiada Firebase) supaya boleh diuji.

/// Had masa untuk SATU operasi: [cap], tetapi tidak sekali-kali melebihi
/// baki bajet [remaining]. Pulangkan [Duration.zero] jika bajet sudah habis
/// (atau negatif) — pemanggil mesti menganggap itu "jangan mulakan operasi".
Duration boundedOpTimeout({
  required Duration remaining,
  required Duration cap,
}) {
  if (remaining <= Duration.zero) {
    return Duration.zero;
  }
  return remaining < cap ? remaining : cap;
}
