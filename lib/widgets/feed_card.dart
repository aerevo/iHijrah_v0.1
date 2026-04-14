import 'package:flutter/material.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final String author;
  final String type;
  final String? image;
  final int likes;
  final int comments;
  final String time;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.type,
    this.image,
    required this.likes,
    required this.comments,
    required this.time,
  });
}

const List<String> kZikir = [
  "Subhanallah",
  "Alhamdulillah",
  "Allahu Akbar",
  "La ilaha illallah",
  "Astaghfirullah",
  "MasyaAllah",
];

class FeedCard extends StatelessWidget {
  final Post post;
  final int index;
  final bool isCenter;

  const FeedCard({
    super.key,
    required this.post,
    required this.index,
    required this.isCenter,
  });

  String getZikir() {
    return kZikir[index % kZikir.length];
  }

  @override
  Widget build(BuildContext context) {
    final zikir = getZikir();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      transform: Matrix4.identity()..scale(isCenter ? 1.03 : 0.97),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: isCenter
            ? Border.all(color: Colors.cyanAccent.withOpacity(0.7), width: 1.5)
            : null,
        gradient: LinearGradient(
          colors: isCenter
              ? [
                  Colors.white.withOpacity(0.18),
                  Colors.white.withOpacity(0.10),
                ]
              : [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.06),
                ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔥 TITLE (PRIMARY)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),

                /// Thumbnail (optional)
                if (post.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      post.image!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            /// 🔥 META (badge + zikir + masa)
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "﷽",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zikir,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.cyanAccent.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        "${post.author} • ${post.time}",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 12),

            /// 🔥 CONTENT
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),

            const SizedBox(height: 14),

            /// 🔥 FOOTER
            Row(
              children: [
                _iconText(Icons.favorite_border, "${post.likes}"),
                const SizedBox(width: 14),
                _iconText(Icons.chat_bubble_outline, "${post.comments}"),
                const SizedBox(width: 14),
                const Spacer(),
                _iconText(Icons.share_outlined, "Kongsi"),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        )
      ],
    );
  }
}
