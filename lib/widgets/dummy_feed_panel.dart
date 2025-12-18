// lib/widgets/dummy_feed_panel.dart - PREMIUM AAA FEED
import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart';

class DummyFeedPanel extends StatefulWidget {
  const DummyFeedPanel({Key? key}) : super(key: key);

  @override
  State<DummyFeedPanel> createState() => _DummyFeedPanelState();
}

class _DummyFeedPanelState extends State<DummyFeedPanel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: AppSpacing.lg,
          left: AppSpacing.sm,
          right: AppSpacing.sm,
          bottom: 100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header dengan animation
            _buildWelcomeHeader(),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Quick Stats Row
            _buildQuickStats(),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Section Header
            _buildSectionHeader('Aktiviti Terkini', Icons.rss_feed),
            
            const SizedBox(height: AppSpacing.md),
            
            // Post 1 - Featured
            const _PremiumPostCard(
              userName: 'Syafiq Aiman',
              timeAgo: '2j',
              content: 'Alhamdulillah, hari ni genap 30 hari istiqamah solat Subuh berjemaah. Rasa tenang sangat hati ni. Doakan saya terus kuat ya sahabat semua! 🌅',
              initialLikes: 42,
              initialComments: 5,
              isFeatured: true,
              category: 'Istiqamah',
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Post 2 - Question
            const _PremiumPostCard(
              userName: 'Sarah Liyana',
              timeAgo: 'Semalam',
              content: 'Ada sesiapa tahu kat mana nak cari kelas tajwid asas area Seremban yang sesuai untuk wanita bekerja? Terima kasih. 🙏',
              initialLikes: 12,
              initialComments: 8,
              isQuestion: true,
              category: 'Soalan',
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Post 3 - Inspiration
            const _PremiumPostCard(
              userName: 'Ustaz Ahmad',
              timeAgo: '3j',
              content: 'Ingatlah, "Barangsiapa yang keluar mencari ilmu, maka dia berada di jalan Allah." - Hadis Riwayat Tirmidzi ✨',
              initialLikes: 67,
              initialComments: 12,
              hasQuote: true,
              category: 'Nasihat',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWelcomeHeader() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? 'Selamat Pagi' : hour < 18 ? 'Selamat Petang' : 'Selamat Malam';
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: kGoldGradient,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        boxShadow: AppShadows.glow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.wb_sunny_outlined,
              color: kBackgroundDark,
              size: AppSizes.iconLg,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    color: kBackgroundDark,
                    fontSize: AppFontSizes.lg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Semoga hari ini penuh barakah',
                  style: TextStyle(
                    color: kBackgroundDark.withOpacity(0.8),
                    fontSize: AppFontSizes.sm,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('42', 'Amalan', Icons.check_circle, kSuccessGreen)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildStatCard('15', 'Hari', Icons.calendar_today, kAccentTeal)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildStatCard('8', 'Level', Icons.trending_up, kPrimaryGold)),
      ],
    );
  }
  
  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: kCardElevated,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: AppSizes.iconMd),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: AppFontSizes.xl,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: kTextSecondary,
              fontSize: AppFontSizes.xs,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: kPrimaryGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: kPrimaryGold, size: AppSizes.iconSm),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: const TextStyle(
            color: kTextPrimary,
            fontSize: AppFontSizes.lg,
            fontWeight: FontWeight.bold,
            fontFamily: 'Playfair',
          ),
        ),
      ],
    );
  }
}

// ===== PREMIUM POST CARD =====
class _PremiumPostCard extends StatefulWidget {
  final String userName;
  final String timeAgo;
  final String content;
  final int initialLikes;
  final int initialComments;
  final bool isFeatured;
  final bool isQuestion;
  final bool hasQuote;
  final String? category;
  
  const _PremiumPostCard({
    Key? key,
    required this.userName,
    required this.timeAgo,
    required this.content,
    required this.initialLikes,
    required this.initialComments,
    this.isFeatured = false,
    this.isQuestion = false,
    this.hasQuote = false,
    this.category,
  }) : super(key: key);

  @override
  State<_PremiumPostCard> createState() => _PremiumPostCardState();
}

class _PremiumPostCardState extends State<_PremiumPostCard> {
  bool _isLiked = false;
  late int _likeCount;
  
  @override
  void initState() {
    super.initState();
    _likeCount = widget.initialLikes;
  }
  
  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        gradient: widget.isFeatured ? kCardGradient : null,
        color: widget.isFeatured ? null : kCardDark,
        border: Border.all(
          color: widget.isFeatured 
            ? kPrimaryGold.withOpacity(0.3)
            : Colors.white.withOpacity(0.05),
          width: widget.isFeatured ? 2 : 1,
        ),
        boxShadow: widget.isFeatured ? AppShadows.medium : AppShadows.small,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: kGlassGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                
                const SizedBox(height: AppSpacing.md),
                
                // Content
                _buildContent(),
                
                const SizedBox(height: AppSpacing.md),
                
                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar with gradient border
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: widget.isFeatured ? kGoldGradient : null,
            border: widget.isFeatured ? null : Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            width: AppSizes.avatarMd,
            height: AppSizes.avatarMd,
            decoration: const BoxDecoration(
              color: kCardElevated,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: kPrimaryGold,
              size: AppSizes.iconMd,
            ),
          ),
        ),
        
        const SizedBox(width: AppSpacing.sm),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: kTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: AppFontSizes.md,
                    ),
                  ),
                  if (widget.isFeatured) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.verified,
                      color: kPrimaryGold,
                      size: AppSizes.iconXs,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    widget.timeAgo,
                    style: const TextStyle(
                      color: kTextSecondary,
                      fontSize: AppFontSizes.xs,
                    ),
                  ),
                  if (widget.category != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.category!,
                        style: TextStyle(
                          color: _getCategoryColor(),
                          fontSize: AppFontSizes.xxs,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: kTextSecondary,
            size: AppSizes.iconSm,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
  
  Widget _buildContent() {
    return Text(
      widget.content,
      style: TextStyle(
        color: kTextPrimary,
        fontSize: AppFontSizes.md,
        height: 1.5,
        fontStyle: widget.hasQuote ? FontStyle.italic : FontStyle.normal,
      ),
    );
  }
  
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          icon: _isLiked ? Icons.favorite : Icons.favorite_border,
          label: '$_likeCount',
          color: _isLiked ? Colors.red : kTextSecondary,
          onTap: _toggleLike,
        ),
        _buildActionButton(
          icon: Icons.chat_bubble_outline,
          label: '${widget.initialComments}',
          color: kTextSecondary,
          onTap: () {},
        ),
        _buildActionButton(
          icon: Icons.share_outlined,
          label: 'Kongsi',
          color: kTextSecondary,
          onTap: () {},
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizes.iconSm, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: AppFontSizes.sm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getCategoryColor() {
    switch (widget.category?.toLowerCase()) {
      case 'istiqamah':
        return kSuccessGreen;
      case 'soalan':
        return kInfoBlue;
      case 'nasihat':
        return kPrimaryGold;
      default:
        return kAccentOlive;
    }
  }
}
