// lib/services/social_failure.dart
// Pemetaan ralat Firebase → kategori ringkas + mesej mesra pengguna.
// Sengaja TIDAK mendedahkan kod/mesej dalaman Firebase kepada UI.
import 'package:firebase_core/firebase_core.dart';

enum SocialFailure {
  unauthenticated,
  permissionDenied,
  network,
  conflict,
  notFound,
  unknown,
}

extension SocialFailureMessage on SocialFailure {
  String get message {
    switch (this) {
      case SocialFailure.unauthenticated:
        return 'Sesi tamat. Sila log masuk semula.';
      case SocialFailure.permissionDenied:
        return 'Tindakan ini tidak dibenarkan. Pastikan e-mel anda sudah disahkan.';
      case SocialFailure.network:
        return 'Tiada sambungan. Semak internet dan cuba lagi.';
      case SocialFailure.conflict:
        return 'Data baru sahaja berubah. Cuba lagi.';
      case SocialFailure.notFound:
        return 'Kandungan ini sudah tiada.';
      case SocialFailure.unknown:
        return 'Sesuatu tidak kena. Cuba lagi sebentar.';
    }
  }
}

SocialFailure socialFailureFromError(Object error) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return SocialFailure.permissionDenied;
      case 'unauthenticated':
        return SocialFailure.unauthenticated;
      case 'unavailable':
      case 'deadline-exceeded':
      case 'network-request-failed':
      case 'cancelled':
        return SocialFailure.network;
      case 'already-exists':
      case 'aborted':
      case 'failed-precondition':
        return SocialFailure.conflict;
      case 'not-found':
        return SocialFailure.notFound;
    }
  }
  return SocialFailure.unknown;
}
