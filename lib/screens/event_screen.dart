// lib/screens/event_screen.dart
// PENTING: Tiada Scaffold — digunakan dalam flyout_panel
import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({Key? key}) : super(key: key);
  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {

  String _filter = 'Semua';

  static const List<String> _filters = [
    'Semua','Ilmu','Sirah','Tasawuf','Video','Petikan',
  ];

  static const List<Map<String, dynamic>> _items = [
    {'name':'Imam Ghazali', 'desc':'Ilmu tanpa amal itu gila.',           'badge':'ILMU',    'style':'X', 'color':Color(0xFF0F4C75)},
    {'name':'Rumi',         'desc':'Luka adalah tempat cahaya masuk.',    'badge':'TASAWUF', 'style':'Y', 'color':Color(0xFF5B4B8A)},
    {'name':'Hikmah',       'desc':'Sabar itu separuh iman.',             'badge':'ADAB',    'style':'X', 'color':Color(0xFF006A71)},
    {'name':'Ibn Taymiyyah','desc':'Hati yang hidup adalah hati yang zikir.','badge':'ILMU', 'style':'Y', 'color':Color(0xFF1B262C)},
    {'name':'Imam Syafie',  'desc':'Masa ibarat pedang jika kamu tidak menebas, ia menebas kamu.','badge':'MASA','style':'X','color':Color(0xFF3282B8)},
    {'name':'Hamka',        'desc':'Kecantikan ada pada adab bukan rupa.','badge':'ADAB',    'style':'Y', 'color':Color(0xFF0F4C75)},
    {'name':'Sirah',        'desc':'Peristiwa Badr Al-Kubra.',            'badge':'SIRAH',   'style':'Z', 'color':Color(0xFF2C5364)},
    {'name':'Ibn Qayyim',   'desc':'Hati yang kosong dari zikir adalah hati yang mati.','badge':'JIWA','style':'X','color':Color(0xFF5B4B8A)},
    {'name':'Buya Hamka',   'desc':'Hidup adalah ladang amal.',           'badge':'ILMU',    'style':'Y', 'color':Color(0xFF006A71)},
    {'name':'Sirah',        'desc':'Fathu Makkah — kemenangan tanpa pertumpahan darah.','badge':'SIRAH','style':'Z','color':Color(0xFF0F4C75)},
    {'name':'Ibn Sina',     'desc':'Tenang adalah ubat.',                 'badge':'MEDIK',   'style':'X', 'color':Color(0xFF1B262C)},
    {'name':'Peristiwa',    'desc':'Israk Mikraj — perjalanan agung.',    'badge':'SIRAH',   'style':'Z', 'color':Color(0xFF3282B8)},
  ];

  List<Map<String, dynamic>> get _filtered =>
      _filter == 'Semua'
          ? _items
          : _items.where((i) {
              final b = (i['badge'] as String).toUpperCase();
              final f = _filter.toUpperCase();
              return b.contains(f) ||
                  (f == 'VIDEO'   && b == 'VIDEO') ||
                  (f == 'PETIKAN' && (b == 'ILMU' || b == 'ADAB' || b == 'JIWA'));
            }).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // ── FILTER BAR ──────────────────────────────────
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: _filters.length,
            itemBuilder: (_, i) {
              final sel = _filters[i] == _filter;
              return GestureDetector(
                onTap: () => setState(() => _filter = _filters[i]),
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14),
                  decoration: BoxDecoration(
                    color: sel
                        ? kPrimaryGold
                        : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: sel
                          ? kPrimaryGold
                          : kBorderSubtle,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _filters[i],
                    style: TextStyle(
                      color: sel
                          ? Colors.black
                          : kTextSecondary,
                      fontWeight: sel
                          ? FontWeight.w700
                          : FontWeight.w400,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // ── GRID ────────────────────────────────────────
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.72,
            ),
            itemCount: _filtered.length,
            itemBuilder: (_, i) {
              final item = _filtered[i];
              return item['style'] == 'Y'
                  ? _frostTile(item)
                  : _jewelTile(item);
            },
          ),
        ),
      ],
    );
  }

  // ── KAD JEWEL ───────────────────────────────────────────────
  Widget _jewelTile(Map<String, dynamic> item) {
    final Color base = item['color'] as Color;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            base.withOpacity(0.85),
            base.withOpacity(0.45),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
              color: base.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.format_quote_rounded,
              color: Colors.white38, size: 14),
          const SizedBox(height: 4),
          Expanded(
            child: Center(
              child: Text(
                item['desc'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontStyle: FontStyle.italic,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            (item['name'] as String).toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 7,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ── KAD FROST ────────────────────────────────────────────────
  Widget _frostTile(Map<String, dynamic> item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: Colors.white.withOpacity(0.25), width: 1.2),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [
                        Color(0xFFE0E0E0),
                        Colors.white,
                        Color(0xFFB0B0B0)
                      ],
                    ).createShader(b),
                    child: Text(
                      item['desc'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              Container(
                width: 18, height: 1,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
              Text(
                item['name'] as String,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 7,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
