// lib/widgets/profile_detail_view.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/hijri_service.dart';
import 'metallic_gold.dart';

class ProfileDetailView extends StatelessWidget {
  const ProfileDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel>();

    final double progress =
        user.nextLevelPoints > 0 ? user.progressPoints / 100.0 : 0.0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── HEADER PROFIL ──────────────────────────────
            _buildHeader(user),
            const SizedBox(height: 24),

            // ── LEVEL PROGRESS ─────────────────────────────
            _buildLevelBar(user.treeLevel, progress),
            const SizedBox(height: 24),

            // ── STAT — Streak + Pokok ─────────────────────
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon:  Icons.local_fire_department_rounded,
                    label: 'STREAK',
                    value: '${user.currentStreak}',
                    unit:  'HARI',
                    colors: [const Color(0xFFFF6B35), const Color(0xFFFF9500)],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon:  Icons.park_rounded,
                    label: 'POKOK',
                    value: 'LVL ${user.treeLevel}',
                    unit:  'XP ${user.totalPoints}',
                    colors: [const Color(0xFF4ADE80), const Color(0xFF22C55E)],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── PERJALANAN HIJRAH ──────────────────────────
            const MetallicGold(
              child: Text(
                'PERJALANAN HIJRAH',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontFamily: 'Playfair',
                ),
              ),
            ),

            const SizedBox(height: 14),

            _buildInfoCard(
              icon:    Icons.access_time_rounded,
              title:   'Umur Hijrah',
              value:   user.hijriAge,
              accent:  kPrimaryGold,
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
              icon:    Icons.wb_twilight_rounded,
              title:   'Fasa Kenabian',
              value:   user.propheticPhase,
              accent:  kAccentOlive,
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
              icon:    Icons.cake_rounded,
              title:   'Hari Jadi Hijrah',
              value:   user.hijriBirthdayDisplay,
              accent:  kAccentTeal,
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
              icon:    user.daysUntilBirthday == 0
                          ? Icons.celebration_rounded
                          : Icons.hourglass_top_rounded,
              title:   'Hari ke Ulangtahun',
              value:   user.daysUntilBirthday == 0
                          ? '🎉 Hari Ini!'
                          : '${user.daysUntilBirthday} Hari Lagi',
              accent:  user.daysUntilBirthday == 0
                          ? kWarningRed
                          : kTextSecondary,
            ),

            const SizedBox(height: 24),

            // ── PENCAPAIAN ─────────────────────────────────
            const MetallicGold(
              child: Text(
                'PENCAPAIAN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontFamily: 'Playfair',
                ),
              ),
            ),

            const SizedBox(height: 14),

            _buildAchievements(user),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────
  Widget _buildHeader(UserModel user) {
    final bool hasAvatar =
        user.avatarPath != null && user.avatarPath!.isNotEmpty;

    return Row(
      children: [

        // Avatar
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryGold.withOpacity(0.4),
                    blurRadius: 30, spreadRadius: 2,
                  ),
                ],
              ),
            ),
            Container(
              width: 86, height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kPrimaryGold, width: 2.5),
              ),
            ),
            Container(
              width: 78, height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kCardDark,
              ),
              child: ClipOval(
                child: hasAvatar
                    ? Image.file(File(user.avatarPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _avatarFallback(user))
                    : _avatarFallback(user),
              ),
            ),

            // Level badge
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: kGoldGradient,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF0A0A0A), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryGold.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  'L${user.treeLevel}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MetallicGold(
                child: Text(
                  (user.name.isEmpty ? 'Hamba Allah' : user.name)
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontFamily: 'Playfair',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00C9FF),
                      Color(0xFF92FE9D),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events_rounded,
                        size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${user.totalPoints} XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.gender,
                style: const TextStyle(
                    color: kTextSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _avatarFallback(UserModel user) => Center(
    child: Text(
      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'H',
      style: const TextStyle(
          color: kPrimaryGold,
          fontSize: 32,
          fontWeight: FontWeight.w900),
    ),
  );

  // ── LEVEL BAR ─────────────────────────────────────────────────
  Widget _buildLevelBar(int level, double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: kPrimaryGold.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('LEVEL $level',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                  Text('LEVEL ${level + 1}',
                      style: const TextStyle(
                          color: kGoldLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: kGoldGradient,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryGold.withOpacity(0.6),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${(progress * 100).toInt()}% ke Level ${level + 1}',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── STAT CARD ─────────────────────────────────────────────────
  Widget _buildStatCard({
    required IconData      icon,
    required String        label,
    required String        value,
    required String        unit,
    required List<Color>   colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[0].withOpacity(0.15),
            colors[1].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors[0].withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: colors[0].withOpacity(0.4), blurRadius: 8),
              ],
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1)),
          Text(unit,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 9)),
        ],
      ),
    );
  }

  // ── INFO CARD ─────────────────────────────────────────────────
  Widget _buildInfoCard({
    required IconData icon,
    required String   title,
    required String   value,
    required Color    accent,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: accent.withOpacity(0.25), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 3),
                    Text(value,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── PENCAPAIAN ────────────────────────────────────────────────
  Widget _buildAchievements(UserModel user) {
    final items = [
      {'icon': Icons.wb_sunny_rounded,                'title': 'Subuh Warrior',     'unlocked': user.currentStreak >= 7,       'color': const Color(0xFFFF9500)},
      {'icon': Icons.park_rounded,                    'title': 'Tree Guardian',     'unlocked': user.treeLevel >= 2,           'color': kAccentGreen},
      {'icon': Icons.local_fire_department_rounded,   'title': '30 Day Streak',     'unlocked': user.longestStreak >= 30,      'color': const Color(0xFFFF6B35)},
      {'icon': Icons.spa_rounded,                     'title': 'Amalan Hero',       'unlocked': user.totalPoints >= 500,       'color': kAccentOlive},
      {'icon': Icons.nightlight_rounded,              'title': 'Night Worshipper',  'unlocked': false,                        'color': kTextSecondary},
      {'icon': Icons.favorite_rounded,                'title': 'Charity Hero',      'unlocked': false,                        'color': kWarningRed},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final it         = items[i];
        final bool on    = it['unlocked'] as bool;
        final Color col  = it['color']    as Color;

        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: on
                    ? col.withOpacity(0.14)
                    : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: on
                      ? col.withOpacity(0.4)
                      : Colors.white.withOpacity(0.08),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(it['icon'] as IconData,
                      size: 26,
                      color: on ? col : Colors.white.withOpacity(0.2)),
                  const SizedBox(height: 6),
                  Text(it['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: on
                              ? Colors.white.withOpacity(0.85)
                              : Colors.white.withOpacity(0.2),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          height: 1.2)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
