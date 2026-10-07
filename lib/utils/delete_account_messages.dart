// lib/utils/delete_account_messages.dart
// Pemetaan mesej ralat padam akaun — fungsi tulen (tiada Firebase / UI)
// supaya boleh diuji. Digunakan oleh SettingsView._deleteAccount().
//
// Kunci pembezaan: [deletionIncomplete] (UserModel.isDeletionIncomplete).
// Jika benar, permintaan padam akaun sudah dimulakan/dihantar dan hasilnya
// belum pasti, jadi mesej "Akaun TIDAK dipadam" akan menipu pengguna.

/// Mesej apabila `UserModel.deleteAccount()` pulang tanpa ralat: permintaan
/// DIHANTAR. BUKAN pengesahan akaun telah dipadam.
const String deleteAccountSubmittedMessage =
    'Permintaan padam akaun telah dihantar dan sedang diproses. '
    'Anda tidak boleh membuat perubahan baharu pada akaun ini.';

/// Mesej untuk ralat semasa `UserModel.deleteAccount()`.
///
/// [authErrorCode] ialah `FirebaseAuthException.code`, atau null untuk
/// ralat yang bukan FirebaseAuthException.
String deleteAccountErrorMessage({
  required bool deletionIncomplete,
  String? authErrorCode,
}) {
  if (deletionIncomplete) {
    return 'Permintaan padam akaun sudah dimulakan tetapi hasilnya belum '
        'dapat disahkan. Akaun ini kekal dibekukan. Tekan Padam Akaun '
        'sekali lagi untuk menyemak semula.';
  }
  if (authErrorCode == null) {
    return 'Ralat semasa memadam akaun. Sila cuba lagi atau hubungi sokongan.';
  }
  if (authErrorCode == 'wrong-password' ||
      authErrorCode == 'invalid-credential') {
    return 'Kata laluan salah. Akaun TIDAK dipadam.';
  }
  if (authErrorCode == 'too-many-requests') {
    return 'Terlalu banyak percubaan. Cuba lagi sebentar.';
  }
  return 'Pengesahan gagal. Akaun TIDAK dipadam.';
}
