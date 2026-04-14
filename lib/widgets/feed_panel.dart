import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// MODEL
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class Post {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime date;
  final String? image;
  final int likes;
  final int comments;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    this.image,
    required this.likes,
    required this.comments,
  });
}

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// MAIN PANEL
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class FeedPanel extends StatefulWidget {
  const FeedPanel({super.key});

  @override
  State<FeedPanel> createState() => _FeedPanelState();
}

class _FeedPanelState extends State<FeedPanel> {
  DateTime selectedDate = DateTime.now();
  bool isPickerActive = false;

  final ScrollController _scrollController = ScrollController();
  int centerIndex = 0;

  List<Post> allPosts = [];
  List<Post> filteredPosts = [];

  @override
  void initState() {
    super.initState();
    generateDummy();
    filterPosts();
    _scrollController.addListener(_detectCenter);
  }

  void generateDummy() {
    allPosts = List.generate(20, (i) {
      return Post(
        id: "$i",
        title: "Kata Hikmah $i",
        content: "Ini adalah contoh isi kandungan untuk post ke-$i.",
        author: "Ustaz $i",
        date: DateTime.now().subtract(Duration(days: i % 5)),
        image: i % 2 == 0
            ? "https://picsum.photos/200?random=$i"
            : null,
        likes: 10 + i * 3,
        comments: i,
      );
    });
  }

  void filterPosts() {
    filteredPosts = allPosts.where((p) {
      return p.date.day == selectedDate.day &&
          p.date.month == selectedDate.month &&
          p.date.year == selectedDate.year;
    }).toList();

    if (filteredPosts.isEmpty) {
      filteredPosts = allPosts.take(5).toList(); // fallback
    }

    setState(() {});
  }

  void _detectCenter() {
    double offset = _scrollController.offset;
    double itemHeight = 140; // adjust ikut UI sebenar

    int index = (offset / itemHeight).round();

    if (index != centerIndex && index < filteredPosts.length) {
      setState(() => centerIndex = index);
    }
  }

  void onDateChanged(DateTime date) {
    selectedDate = date;
    filterPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// ━━━━━━━━━━━━━━━━━
        /// 🔥 PICKER (STICKY)
        /// ━━━━━━━━━━━━━━━━━
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
          ),
          child: Stack(
            children: [
              /// Blur background
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(color: Colors.transparent),
                ),
              ),

              /// Picker
              NotificationListener<ScrollNotification>(
                onNotification: (notif) {
                  if (notif is ScrollStartNotification) {
                    setState(() => isPickerActive = true);
                  } else if (notif is ScrollEndNotification) {
                    setState(() => isPickerActive = false);
                  }
                  return true;
                },
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: selectedDate,
                  onDateTimeChanged: onDateChanged,
                ),
              ),
            ],
          ),
        ),

        /// ━━━━━━━━━━━━━━━━━
        /// 🔥 FEED
        /// ━━━━━━━━━━━━━━━━━
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: isPickerActive
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              final post = filteredPosts[index];

              return FeedCard(
                post: post,
                index: index,
                isCenter: index == centerIndex,
              );
            },
          ),
        ),
      ],
    );
  }
}
