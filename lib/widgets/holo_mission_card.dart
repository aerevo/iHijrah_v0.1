import 'package:flutter/material.dart';
import '../utils/constants.dart';

class HoloMissionCard extends StatelessWidget {
  final String title;
  final int current;
  final int target;
  final VoidCallback onIncrement;

  const HoloMissionCard({
    Key? key,
    required this.title,
    required this.current,
    required this.target,
    required this.onIncrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = (current / target).clamp(0.0, 1.0);
    bool isComplete = current >= target;

    return GestureDetector(
      onTap: isComplete ? null : onIncrement,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // Border menyala bila complete
            color: isComplete ? kSuccessGreen : Colors.white10,
            width: isComplete ? 2 : 1,
          ),
          boxShadow: isComplete
              ? [BoxShadow(color: kSuccessGreen.withOpacity(0.4), blurRadius: 15)]
              : [],
        ),
        child: Stack(
          children: [
            // 1. PROGRESS BAR BACKGROUND (Fill)
            LayoutBuilder(
              builder: (ctx, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutExpo,
                  width: constraints.maxWidth * progress,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: isComplete
                          ? [kSuccessGreen.withOpacity(0.2), kSuccessGreen.withOpacity(0.5)]
                          : [kPrimaryGold.withOpacity(0.1), kPrimaryGold.withOpacity(0.3)],
                    ),
                  ),
                );
              },
            ),

            // 2. CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Icon Status
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26,
                      border: Border.all(
                          color: isComplete ? kSuccessGreen : kPrimaryGold.withOpacity(0.5)),
                    ),
                    child: Icon(
                      isComplete ? Icons.check : Icons.bolt,
                      color: isComplete ? kSuccessGreen : kPrimaryGold,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 15),
                  
                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isComplete ? "MISSION COMPLETE" : "$current / $target COMPLETED",
                          style: TextStyle(
                            color: isComplete ? kSuccessGreen : Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Button Tambah (Check)
                  if (!isComplete)
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}