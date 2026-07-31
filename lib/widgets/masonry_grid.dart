// lib/widgets/masonry_grid.dart
// Grid masonry 2-lajur ringan — pure Flutter, tiada pakej luar.
//
// Kenapa perlu: SliverGrid + childAspectRatio tetap memaksa SEMUA kad
// masuk kotak yang sama saiz — itu punca rupa "kaku". Widget ini
// mengagihkan setiap kad ke lajur yang PALING PENDEK setakat itu
// (greedy shortest-column-first, teknik masonry klasik), berdasarkan
// anggaran tinggi kad (`heightWeight`) yang dikira oleh pemanggil.
// Hasilnya: dua lajur kekal seimbang tinggi keseluruhannya, tapi
// kad individu boleh berbeza tinggi mengikut kandungan sebenar.

import 'package:flutter/material.dart';

class MasonryTile {
  final Widget child;
  final double heightWeight; // anggaran tinggi relatif kad ini
  const MasonryTile({required this.child, required this.heightWeight});
}

class TwoColumnMasonry extends StatelessWidget {
  final List<MasonryTile> tiles;
  final double columnSpacing;
  final double runSpacing;

  const TwoColumnMasonry({
    Key? key,
    required this.tiles,
    this.columnSpacing = 12,
    this.runSpacing = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> colLeft = [];
    final List<Widget> colRight = [];
    double heightLeft = 0;
    double heightRight = 0;

    for (final tile in tiles) {
      final bool goLeft = heightLeft <= heightRight;

      final wrapped = Padding(
        padding: EdgeInsets.only(bottom: runSpacing),
        child: tile.child,
      );

      if (goLeft) {
        colLeft.add(wrapped);
        heightLeft += tile.heightWeight + runSpacing;
      } else {
        colRight.add(wrapped);
        heightRight += tile.heightWeight + runSpacing;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: colLeft,
          ),
        ),
        SizedBox(width: columnSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: colRight,
          ),
        ),
      ],
    );
  }
}
