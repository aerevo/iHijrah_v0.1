// lib/widgets/profile_detail_view.dart (AAA EDITION - CYBERPUNK × ISLAMIC LUXURY)
import 'dart:ui';
import 'package:flutter/material.dart';

// ✅ INTEGRASI: Panggil fail Emas Kapten yang original
import 'metallic_gold.dart'; 

class ProfileDetailView extends StatelessWidget {
  const ProfileDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MOCK DATA (Nanti sambung ke Provider/Backend)
    final String userName = 'Abdullah';
    final int level = 12;
    final int totalPoints = 4850;
    final int streakDays = 47;
    final int totalZikir = 12450;
    final String hijriAge = '28 Thn 5 Bln';
    final String propheticPhase = 'Makkah (Akhlak)';
    final int daysUntilBirthday = 23;
    final double levelProgress = 0.68; // 68% to next level

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0A0A), // Deep Black
            Color(0xFF1A1A1A), // Charcoal
          ],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 100), // Padding bawah lebih utk scroll
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════════════════════
            // PROFILE HEADER (Avatar + Name + Level)
            // ═══════════════════════════════════════════════════════════
            _buildProfileHeader(
              userName: userName,
              level: level,
              totalPoints: totalPoints,
            ),

            const SizedBox(height: 32),

            // ═══════════════════════════════════════════════════════════
            // LEVEL PROGRESS BAR (Gamification HUD)
            // ═══════════════════════════════════════════════════════════
            _buildLevelProgressBar(
              currentLevel: level,
              progress: levelProgress,
            ),

            const SizedBox(height: 32),

            // ═══════════════════════════════════════════════════════════
            // STATS HUD (Amalan Streak + Total Zikir)
            // ═══════════════════════════════════════════════════════════
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'STREAK',
                    value: '$streakDays',
                    unit: 'HARI',
                    gradientColors: [
                      const Color(0xFFFF6B35),
                      const Color(0xFFFF9500),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.auto_awesome,
                    label: 'ZIKIR',
                    value: '${(totalZikir / 1000).toStringAsFixed(1)}K',
                    unit: 'TOTAL',
                    gradientColors: [
                      const Color(0xFF00C9FF),
                      const Color(0xFF92FE9D),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ═══════════════════════════════════════════════════════════
            // HIJRAH JOURNEY SECTION
            // ═══════════════════════════════════════════════════════════
            const MetallicGold(
              child: Text(
                'PERJALANAN HIJRAH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontFamily: 'Playfair',
                ),
              ),
            ),

            const SizedBox(height: 16),

            _buildGlassInfoCard(
              icon: Icons.access_time_rounded,
              title: 'Umur Hijrah',
              value: hijriAge,
              accentColor: const Color(0xFFFFD54F),
            ),

            const SizedBox(height: 12),

            _buildGlassInfoCard(
              icon: Icons.wb_twilight_rounded,
              title: 'Fasa Kenabian',
              value: propheticPhase,
              accentColor: const Color(0xFF9DBA7F),
            ),

            const SizedBox(height: 12),

            _buildGlassInfoCard(
              icon: Icons.cake_rounded,
              title: 'Hari ke Ulangtahun',
              value: daysUntilBirthday > 0
                  ? '$daysUntilBirthday Hari Lagi'
                  : '🎉 Hari Ini!',
              accentColor: daysUntilBirthday == 0
                  ? const Color(0xFFCF6679)
                  : const Color(0xFF6C757D),
            ),

            const SizedBox(height: 32),

            // ═══════════════════════════════════════════════════════════
            // ACHIEVEMENTS / BADGES
            // ═══════════════════════════════════════════════════════════
            const MetallicGold(
              child: Text(
                'PENCAPAIAN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontFamily: 'Playfair',
                ),
              ),
            ),

            const SizedBox(height: 16),

            _buildAchievementGrid(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PROFILE HEADER (Avatar + Name + Level)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildProfileHeader({
    required String userName,
    required int level,
    required int totalPoints,
  }) {
    return Row(
      children: [
        // Avatar with Glowing Ring
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer Glow
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD54F).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // Gold Ring Border
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 3,
                  color: const Color(0xFFFFD54F),
                ),
              ),
            ),
            // Inner Ring (Cyan accent)
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: const Color(0xFF00C9FF),
                ),
              ),
            ),
            // Avatar Image (Dengan Fallback Icon jika Offline)
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2A2A2A),
              ),
              child: ClipOval(
                child: Image.network(
                  'https://i.pravatar.cc/150?img=12', // URL Gambar
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback jika tiada internet
                    return const Icon(Icons.person, color: Colors.white54, size: 40);
                  },
                ),
              ),
            ),
            // Level Badge
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBF953F), Color(0xFFAA771C)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF0A0A0A),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD54F).withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  'L$level',
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

        const SizedBox(width: 20),

        // Name + Points
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MetallicGold(
                child: Text(
                  userName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontFamily: 'Playfair',
                    shadows: [
                      Shadow(
                        color: Color(0xFFFFD54F),
                        blurRadius: 20,
                      ),
                      Shadow(
                        color: Colors.black,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$totalPoints XP',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // LEVEL PROGRESS BAR (Cyberpunk Style)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildLevelProgressBar({
    required int currentLevel,
    required double progress,
  }) {
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
              color: const Color(0xFFFFD54F).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LEVEL $currentLevel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'LEVEL ${currentLevel + 1}',
                    style: TextStyle(
                      color: const Color(0xFFFFD54F).withOpacity(0.9),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Stack(
                children: [
                  // Background Track
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  // Progress Fill with Glow
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFBF953F),
                            Color(0xFFFFD54F),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD54F).withOpacity(0.6),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toInt()}% ke Level ${currentLevel + 1}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // STAT CARD (Game HUD Style)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required List<Color> gradientColors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientColors[0].withOpacity(0.15),
            gradientColors[1].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradientColors[0].withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with Glow
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Label
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          // Value
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // GLASS INFO CARD (Glassmorphism)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildGlassInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color accentColor,
  }) {
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
              color: accentColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Icon with Glow
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ACHIEVEMENT GRID (Premium Badges)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildAchievementGrid() {
    final List<Map<String, dynamic>> achievements = [
      {
        'icon': Icons.wb_sunny_rounded,
        'title': 'Subuh Warrior',
        'unlocked': true,
        'color': const Color(0xFFFF9500),
      },
      {
        'icon': Icons.park_rounded,
        'title': 'Tree Guardian',
        'unlocked': true,
        'color': const Color(0xFF9DBA7F),
      },
      {
        'icon': Icons.menu_book_rounded,
        'title': 'Quran Scholar',
        'unlocked': true,
        'color': const Color(0xFF00C9FF),
      },
      {
        'icon': Icons.favorite_rounded,
        'title': 'Charity Hero',
        'unlocked': false,
        'color': const Color(0xFFCF6679),
      },
      {
        'icon': Icons.local_fire_department_rounded,
        'title': '30 Day Streak',
        'unlocked': true,
        'color': const Color(0xFFFF6B35),
      },
      {
        'icon': Icons.nightlight_rounded,
        'title': 'Night Worshipper',
        'unlocked': false,
        'color': const Color(0xFF6C757D),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final bool isUnlocked = achievement['unlocked'];

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: isUnlocked
                    ? achievement['color'].withOpacity(0.15)
                    : Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isUnlocked
                      ? achievement['color'].withOpacity(0.4)
                      : Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    achievement['icon'],
                    size: 28,
                    color: isUnlocked
                        ? achievement['color']
                        : Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement['title'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isUnlocked
                          ? Colors.white.withOpacity(0.9)
                          : Colors.white.withOpacity(0.3),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
