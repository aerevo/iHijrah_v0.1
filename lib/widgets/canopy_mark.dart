// lib/widgets/canopy_mark.dart
// Lambang kanopi pokok — kluster bulatan lembut, BUKAN segitiga cemara.
// Direka khusus supaya tak boleh disalah anggap pokok Krismas/loceng,
// isu yang timbul dua kali dengan ikon Material sedia ada (forest_rounded,
// park_rounded — dua-dua rupanya bersilhouette runcing/segitiga).

import 'package:flutter/material.dart';

class CanopyMark extends StatelessWidget {
  final double size;
  final Color color;
  const CanopyMark({Key? key, this.size = 36, this.color = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double u = size / 36; // unit skala, direka pada asas 36
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 0, child: _dot(20 * u)),
          Positioned(bottom: 3 * u, left: 0, child: _dot(15 * u)),
          Positioned(bottom: 3 * u, right: 0, child: _dot(15 * u)),
          Positioned(bottom: -1 * u, child: _dot(13 * u)),
        ],
      ),
    );
  }

  Widget _dot(double d) => Container(
        width: d,
        height: d,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
