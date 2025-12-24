// lib/widgets/dummy_feed_panel.dart (JERNIH & NEON MALAP)
import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart'; 

class DummyFeedPanel extends StatelessWidget {
  const DummyFeedPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        top: 20, 
        left: 0, 
        right: 0,
        bottom: 150, 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: NEON TEXT (Opacity dikurangkan sedikit)
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 20),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      const Color(0xFFD500F9).withOpacity(0.9), // Kurang sikit opacity
                      const Color(0xFF00E5FF).withOpacity(0.9), 
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    "NEON FEED",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.0, 
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF), 
                    shape: BoxShape.circle,
                    boxShadow: [
                      // ✅ FIX 3: Silau dot dikurangkan
                      BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.5), blurRadius: 4)
                    ]
                  ),
                )
              ],
            ),
          ),

          // GENERATE POSTS
          ...List.generate(20, (index) {
            return _CyberNeonCard(
              index: index,
              userName: index % 2 == 0 ? 'Syafiq Aiman' : 'Sarah Liyana',
              timeAgo: '${index + 1}j',
              category: index % 2 == 0 ? 'Tazkirah' : 'Soalan',
              categoryColor: index % 2 == 0 ? const Color(0xFFD500F9) : const Color(0xFF00E5FF),
              content: index % 2 == 0
                ? 'Istiqamah itu berat, sebab ganjarannya Syurga. Kalau ringan, ganjarannya cuma "Super Ring". Teruskan berjuang sahabat! 🔥'
                : 'Ada sesiapa tahu kedai gunting rambut muslimah area Bangi yang "hidden gem"? Nak privacy sikit.',
              initialLikes: (index * 5) + 12,
              initialComments: index + 2,
            );
          }),
        ],
      ),
    );
  }
}

class _CyberNeonCard extends StatelessWidget {
  final int index;
  final String userName;
  final String timeAgo;
  final String category;
  final Color categoryColor;
  final String content;
  final int initialLikes;
  final int initialComments;

  const _CyberNeonCard({
    Key? key,
    required this.index,
    required this.userName,
    required this.timeAgo,
    required this.category,
    required this.categoryColor,
    required this.content,
    required this.initialLikes,
    required this.initialComments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 180, 
      child: Stack(
        clipBehavior: Clip.none, 
        children: [
          
          // 1. KAD UTAMA
          Positioned(
            left: 20, right: 0, top: 0, bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF120E16).withOpacity(0.8), // Lebih transparent
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),   
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                // ✅ FIX 3: Gradient Border lebih malap (Opacity rendah)
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD500F9).withOpacity(0.15), // Neon malap
                    const Color(0xFF120E16), 
                    const Color(0xFF00E5FF).withOpacity(0.15), // Cyan malap
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  // ✅ FIX 3: Glow belakang dikurangkan
                  BoxShadow(
                    color: const Color(0xFFD500F9).withOpacity(0.05), // Sangat nipis
                    blurRadius: 10, 
                    offset: const Offset(5, 5)
                  )
                ]
              ),
              child: ClipRRect( // Clip untuk Glass Effect
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),   
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: BackdropFilter(
                  // ✅ FIX 2: BLUR KACA DIKURANGKAN JADI 1.5 (Sangat Jernih)
                  filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(40, 16, 16, 16),
                    decoration: BoxDecoration(
                      // Tint hitam nipis untuk kebolehbacaan
                      color: Colors.black.withOpacity(0.4), 
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Nama User
                                  Text(
                                    userName,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.95),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      // ✅ FIX 3: Shadow teks dikurangkan
                                      shadows: [
                                        BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.3), blurRadius: 5)
                                      ]
                                    ),
                                  ),
                                  Text(timeAgo, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                                ],
                              ),
                            ),
                            
                            // Category Pill (Neon Nipis)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: categoryColor.withOpacity(0.5)), 
                                boxShadow: [BoxShadow(color: categoryColor.withOpacity(0.1), blurRadius: 4)]
                              ),
                              child: Text(
                                "#$category",
                                style: TextStyle(color: categoryColor.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Content Text
                        Text(
                          content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFE0E0E0),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. AVATAR TERAPUNG
          Positioned(
            left: 0, 
            top: -10,
            child: Container(
              width: 55, height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(color: const Color(0xFFD500F9).withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFD500F9).withOpacity(0.2), blurRadius: 8) // Glow avatar dikurangkan
                ]
              ),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF202020),
                child: MetallicGold(
                  // Ikon Avatar Emas
                  child: const Icon(Icons.person, size: 30, color: Colors.white),
                ),
              ),
            ),
          ),

          // 3. ACTION CAPSULE
          Positioned(
            right: 16,
            bottom: -10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6200EA).withOpacity(0.8), 
                    const Color(0xFFD500F9).withOpacity(0.8)
                  ], 
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFD500F9).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 4))
                ]
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text("$initialLikes", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  
                  Container(width: 1, height: 12, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 10)),
                  
                  const Icon(Icons.chat_bubble, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text("$initialComments", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
