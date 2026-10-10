import '../models/user_model.dart';

/// Keputusan gate navigasi D5 (Splash / login / pengesahan e-mel).
enum DeletionGateAction {
  /// Tiada marker tertunggak untuk UID semasa — navigasi biasa dibenarkan.
  proceed,

  /// Auth disahkan telah dipadam dan cleanup tempatan selesai.
  showAuth,

  /// Marker masih tertunggak / status belum disahkan: fail-closed. Tiada
  /// pull cloud, tiada Onboarding, tiada Home.
  showRecovery,
}

/// Satu-satunya tempat yang memutuskan sama ada navigasi biasa dibenarkan.
///
/// Hanya `none` TANPA marker tertunggak yang membenarkan [proceed]. Setiap
/// hasil lain (`pending`, `processing`, `failed`, `statusMissing`,
/// `completedButAuthStillExists`, `unverifiable`) bukan bukti siap.
DeletionGateAction deletionGateAction(
  AccountDeletionReconciliationResult result, {
  required bool markerOutstanding,
}) {
  if (result == AccountDeletionReconciliationResult.authDeleted &&
      !markerOutstanding) {
    return DeletionGateAction.showAuth;
  }
  if (result == AccountDeletionReconciliationResult.none &&
      !markerOutstanding) {
    return DeletionGateAction.proceed;
  }
  return DeletionGateAction.showRecovery;
}
