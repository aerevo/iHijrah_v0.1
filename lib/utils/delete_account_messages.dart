// lib/utils/delete_account_messages.dart
// Pemetaan mesej ralat padam akaun — fungsi tulen (tiada Firebase / UI)
// supaya boleh diuji. Digunakan oleh SettingsView._deleteAccount().
//
// Kunci pembezaan: [deletionIncomplete] (UserModel.isDeletionIncomplete).
// Jika benar, sesuatu SUDAH dipadam sebelum ralat berlaku, jadi mesej
// "Akaun TIDAK dipadam" akan menipu pengguna — walaupun ralat itu
// FirebaseAuthException (mis. langkah padam Auth gagal selepas data
// Firestore dipadam).

/// Mesej untuk ralat semasa `UserModel.deleteAccount()`.
///
/// [authErrorCode] ialah `FirebaseAuthException.code`, atau null untuk
/// ralat yang bukan FirebaseAuthException.
String deleteAccountErrorMessage({
  required bool deletionIncomplete,
  String? authErrorCode,
}) {
  if (deletionIncomplete) {
    return 'Sebahagian data akaun sudah dipadam, tetapi akaun belum '
        'selesai dipadam. Tekan Padam Akaun sekali lagi untuk '
        'menyelesaikannya.';
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
