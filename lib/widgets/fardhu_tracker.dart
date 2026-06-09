// lib/widgets/fardhu_tracker.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/animation_controller_model.dart';
import '../utils/constants.dart';

class FardhuTracker extends StatelessWidget {
  const FardhuTracker({Key? key}) : super(key: key);

  static const List<String> _prayers = [
    'Subuh', 'Zohor', 'Asar', 'Maghrib', 'Isyak'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Header
        Consumer<UserModel>(
          builder: (_, user, __) {
            final done = _prayers
                .where((p) => user.isFardhuDoneToday(p))
                .length;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Solat Fardu',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: AppFontSizes.xl,
                    fontFamily: 'Playfair',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: done == 5
                        ? kPrimaryGold.withOpacity(0.15)
                        : kCardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: done == 5
                          ? kPrimaryGold.withOpacity(0.4)
                          : kBorderSubtle,
                    ),
                  ),
                  child: Text(
                    '$done / 5',
                    style: TextStyle(
                      color: done == 5 ? kPrimaryGold : kTextSecondary,
                      fontSize: AppFontSizes.sm,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: AppSpacing.md),

        // Butang solat
        SizedBox(
          height: 88,
          child: Row(
            children: _prayers
                .map((p) => Expanded(
                      child: _PrayerBtn(
                        prayer: p,
                        onTap: () {
                          final user = Provider.of<UserModel>(
                              context, listen: false);
                          if (!user.isFardhuDoneToday(p)) {
                            user.recordFardhu(p);
                            Provider.of<AnimationControllerModel>(
                                    context, listen: false)
                                .triggerParticleSpray();
                            HapticFeedback.mediumImpact();
                          }
                        },
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ── BUTANG SOLAT ──────────────────────────────────────────────
class _PrayerBtn extends StatefulWidget {
  final String prayer;
  final VoidCallback onTap;

  const _PrayerBtn({required this.prayer, required this.onTap});

  @override
  State<_PrayerBtn> createState() => _PrayerBtnState();
}

class _PrayerBtnState extends State<_PrayerBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (_, user, __) {
        final done = user.isFardhuDoneToday(widget.prayer);
        return GestureDetector(
          onTapDown:  (_) => setState(() => _pressed = true),
          onTapUp:    (_) { setState(() => _pressed = false); widget.onTap(); },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            curve: Curves.easeOutBack,
            transform: Matrix4.identity()
              ..scale(_pressed ? 0.88 : 1.0),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: done ? kPrimaryGold : kCardDark,
              borderRadius:
                  BorderRadius.circular(AppSizes.cardRadiusLg),
              border: Border.all(
                color: done
                    ? kPrimaryGold
                    : kTextMuted.withOpacity(0.12),
              ),
              boxShadow: done
                  ? [
                      BoxShadow(
                        color: kPrimaryGold.withOpacity(0.35),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  done
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: done ? kBackgroundDark : kTextMuted,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.prayer,
                  style: TextStyle(
                    color: done ? kBackgroundDark : kTextMuted,
                    fontSize: AppFontSizes.xs,
                    fontWeight:
                        done ? FontWeight.w700 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
