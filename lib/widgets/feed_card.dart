// lib/widgets/feed_card.dart (UPGRADED 7.8/10)

import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Reusable card untuk feed/event/sirah display
/// 
/// Features:
/// - Consistent styling
/// - Icon + Title + Subtitle layout
/// - Premium shadow & border
class FeedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final VoidCallback? onTap;
  
  const FeedCard({
    Key? key,
    required this.title,
    required this.subtitle,
    this.leadingIcon = Icons.article,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: kCardDark,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: kPrimaryGold.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm + 4),
            decoration: BoxDecoration(
              color: kPrimaryGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              leadingIcon,
              color: kPrimaryGold,
              size: AppSizes.iconMd,
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSizes.lg - 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs + 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: kTextSecondary,
                    fontSize: AppFontSizes.sm + 1,
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Wrap dengan GestureDetector jika ada onTap
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: card,
      );
    }

    return card;
  }
}