// lib/screens/user_profile_screen.dart
// Profil awam pengguna lain + butang Follow.
// Data profil datang dari profiles/{uid}; follow guna ProfileService.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../services/social_failure.dart';

/// Keadaan butang Ikuti/Mengikuti. Logik tulen supaya boleh diuji tanpa Firebase.
@visibleForTesting
class FollowButtonState {
  const FollowButtonState({
    required this.label,
    required this.enabled,
    required this.targetFollow,
  });

  /// Teks butang (Bahasa Melayu).
  final String label;

  /// Butang boleh ditekan hanya apabila status dimuat dan tiada operasi berjalan.
  final bool enabled;

  /// Nilai `follow` yang dihantar ke ProfileService.setFollowing apabila ditekan.
  final bool targetFollow;
}

@visibleForTesting
FollowButtonState followButtonState({
  required bool following,
  required bool loading,
  required bool busy,
}) {
  return FollowButtonState(
    label: following ? 'Mengikuti' : 'Ikuti',
    enabled: !loading && !busy,
    targetFollow: !following,
  );
}

class UserProfileScreen extends StatefulWidget {
  final String uid;

  const UserProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ProfileService _profiles = ProfileService.instance;
  bool _busy = false;

  String? get _myUid => FirebaseAuth.instance.currentUser?.uid;

  bool get _isMyProfile => _myUid == widget.uid;

  Future<void> _toggleFollow(bool follow) async {
    if (_busy) return;
    setState(() => _busy = true);

    final result = await _profiles.setFollowing(
      widget.uid,
      follow: follow,
    );

    if (!mounted) return;
    setState(() => _busy = false);

    if (result.isFailure) {
      final SocialFailure? failure = result.error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure?.message ?? 'Cuba lagi sebentar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: StreamBuilder<ProfileModel?>(
        stream: _profiles.watchProfile(widget.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ProfileModel? profile = snapshot.data;
          if (snapshot.hasError || profile == null) {
            return const Center(
              child: Text('Profil ini tidak dijumpai.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  child: Text(
                    profile.initial,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (profile.bio.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    profile.bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  '${profile.followersCount} pengikut',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                if (_isMyProfile)
                  const Text(
                    'Ini profil anda.',
                    style: TextStyle(color: Colors.white70),
                  )
                else
                  StreamBuilder<bool>(
                    stream: _profiles.watchIsFollowing(widget.uid),
                    builder: (context, followSnapshot) {
                      final bool following =
                          followSnapshot.data ?? false;
                      final bool loading =
                          followSnapshot.connectionState ==
                              ConnectionState.waiting;

                      final FollowButtonState state = followButtonState(
                        following: following,
                        loading: loading,
                        busy: _busy,
                      );

                      return ElevatedButton.icon(
                        onPressed: state.enabled
                            ? () => _toggleFollow(state.targetFollow)
                            : null,
                        icon: Icon(
                          following
                              ? Icons.check_rounded
                              : Icons.person_add_alt_rounded,
                        ),
                        label: Text(state.label),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
