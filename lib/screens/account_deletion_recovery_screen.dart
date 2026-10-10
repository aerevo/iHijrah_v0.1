import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import 'auth_screen.dart';
import 'splash_screen.dart';

/// Skrin fail-closed untuk permintaan pemadaman yang belum dapat disahkan.
/// Skrin ini tidak memadam data atau membuang marker sendiri.
class AccountDeletionRecoveryScreen extends StatefulWidget {
  const AccountDeletionRecoveryScreen({
    super.key,
    required this.initialResult,
  });

  final AccountDeletionReconciliationResult initialResult;

  @override
  State<AccountDeletionRecoveryScreen> createState() =>
      _AccountDeletionRecoveryScreenState();
}

class _AccountDeletionRecoveryScreenState
    extends State<AccountDeletionRecoveryScreen> {
  late AccountDeletionReconciliationResult _result = widget.initialResult;
  bool _busy = false;

  String get _message {
    switch (_result) {
      case AccountDeletionReconciliationResult.pending:
        return 'Permintaan pemadaman sedang menunggu pemprosesan.';
      case AccountDeletionReconciliationResult.processing:
        return 'Pembersihan akaun sedang dijalankan.';
      case AccountDeletionReconciliationResult.failed:
        return 'Backend melaporkan kegagalan. Sistem boleh mencuba semula.';
      case AccountDeletionReconciliationResult.statusMissing:
        return 'Status pelayan belum tersedia. Akaun kekal dibekukan.';
      case AccountDeletionReconciliationResult.completedButAuthStillExists:
        return 'Pembersihan dilaporkan selesai tetapi Auth masih wujud.';
      case AccountDeletionReconciliationResult.authDeleted:
        return 'Pemadaman Auth telah disahkan.';
      case AccountDeletionReconciliationResult.none:
      case AccountDeletionReconciliationResult.unverifiable:
        return 'Status pemadaman belum dapat disahkan. Akaun kekal dibekukan.';
    }
  }

  Future<void> _retry() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final UserModel model =
          Provider.of<UserModel>(context, listen: false);
      final AccountDeletionReconciliationResult result =
          await model.reconcileAccountDeletion();
      if (!mounted) return;

      if (result == AccountDeletionReconciliationResult.authDeleted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
          (_) => false,
        );
        return;
      }

      if (result == AccountDeletionReconciliationResult.none &&
          !model.hasOutstandingDeletionMarker) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const SplashScreen()),
          (_) => false,
        );
        return;
      }

      setState(() {
        _result = result == AccountDeletionReconciliationResult.none
            ? AccountDeletionReconciliationResult.unverifiable
            : result;
      });
    } catch (e) {
      debugPrint('D5 recovery retry gagal: $e');
      if (mounted) {
        setState(() {
          _result = AccountDeletionReconciliationResult.unverifiable;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semakan gagal. Akaun kekal dibekukan.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await Provider.of<UserModel>(context, listen: false).signOutAndReset();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
        (_) => false,
      );
    } catch (e) {
      debugPrint('D5 recovery sign-out gagal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Log keluar gagal. Cuba lagi.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Pemulihan pemadaman akaun'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_clock, size: 56),
                const SizedBox(height: 20),
                const Text(
                  'Akaun ini dikunci sementara',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(_message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _retry,
                    child: Text(_busy ? 'Menyemak…' : 'Semak semula status'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _busy ? null : _signOut,
                    child: const Text('Log keluar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
