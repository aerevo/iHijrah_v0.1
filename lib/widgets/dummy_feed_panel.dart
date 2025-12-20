// lib/widgets/dummy_feed_panel.dart (THEME: CYBERPUNK NEON PURPLE)
import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart'; // Masih guna untuk Avatar (Sentuhan Mewah)

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
          // HEADER: NEON GRADIENT TEXT
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 20),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFD500F9), // Neon Purple
                      Color(0xFF00E5FF), // Neon Cyan
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
                // Dot Indicator (Cyber blink)
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF), 
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.8), blurRadius: 6)
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
              // Warna label ikut Cyberpunk palette
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
          
          // 1. KAD UTAMA (NEON BORDER & GLOW)
          Positioned(
            left: 20, right: 0, top: 0, bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                // Background Hitam + Sedikit Tint Ungu
                color: const Color(0xFF120E16).withOpacity(0.9), 
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),   
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                // BORDER GRADIENT (UNGU -> BIRU)
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD500F9).withOpacity(0.3), // Purple
                    const Color(0xFF120E16), // Tengah gelap
                    const Color(0xFF00E5FF).withOpacity(0.3), // Cyan
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  // GLOW UNGU DI BELAKANG KAD
                  BoxShadow(
                    color: const Color(0xFFD500F9).withOpacity(0.15), 
                    blurRadius: 15, 
                    offset: const Offset(5, 5)
                  )
                ]
              ),
              child: Container(
                // Layer dalam untuk tutup gradient border
                margin: const EdgeInsets.all(1.5), 
                decoration: BoxDecoration(
                   color: Colors.black.withOpacity(0.6), // Kaca gelap
                   borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),   
                    topRight: Radius.circular(19),
                    bottomLeft: Radius.circular(19),
                    bottomRight: Radius.circular(19),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 16, 16, 16),
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
                                // NAMA GUNA WARNA CYAN/PUTIH (Lebih Tech)
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      BoxShadow(color: Color(0xFF00E5FF), blurRadius: 10) // Glow Cyan Teks
                                    ]
                                  ),
                                ),
                                Text(timeAgo, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
                              ],
                            ),
                          ),
                          
                          // NEON PILL (Outline Style)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: categoryColor), // Border Neon
                              boxShadow: [BoxShadow(color: categoryColor.withOpacity(0.2), blurRadius: 6)]
                            ),
                            child: Text(
                              "#$category",
                              style: TextStyle(color: categoryColor, fontSize: 10, fontWeight: FontWeight.bold),
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

          // 2. AVATAR TERAPUNG (EMAS VS NEON)
          // Kita kekalkan Emas pada Avatar sebagai "Status Simbol", tapi glow dia Ungu
          Positioned(
            left: 0, 
            top: -10,
            child: Container(
              width: 55, height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                border: Border.all(color: const Color(0xFFD500F9), width: 2), // Ring Ungu
                boxShadow: [
                  BoxShadow(color: const Color(0xFFD500F9).withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 0)) // Glow Ungu Kuat
                ]
              ),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF202020),
                // Icon dalam masih Emas (Luxury Touch)
                child: MetallicGold(
                  child: const Icon(Icons.person, size: 30, color: Colors.white),
                ),
              ),
            ),
          ),

          // 3. ACTION CAPSULE (GRADIENT UNGU-BIRU)
          Positioned(
            right: 16,
            bottom: -10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                // Gradient Cyberpunk sebenar
                gradient: const LinearGradient(
                  colors: [Color(0xFF6200EA), Color(0xFFD500F9)], // Deep Purple -> Neon Purple
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFD500F9).withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))
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
