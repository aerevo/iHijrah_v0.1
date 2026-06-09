// lib/widgets/birthday_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/hijri_service.dart';
import 'living_tree.dart';

class BirthdayView extends StatefulWidget {
  const BirthdayView({Key? key}) : super(key: key);
  @override
  State<BirthdayView> createState() => _BirthdayViewState();
}

class _BirthdayViewState extends State<BirthdayView>
    with SingleTickerProviderStateMixin {

  late TabController _tabs;
  final TextEditingController _noteCtrl = TextEditingController();
  bool _writingMode = false;
  String _selectedState = 'Pilih Negeri';

  static const List<String> _states = [
    'Pilih Negeri','Johor','Kedah','Kelantan','Melaka','Negeri Sembilan',
    'Pahang','Perak','Perlis','Pulau Pinang','Sabah','Sarawak',
    'Selangor','Terengganu','W.P. Kuala Lumpur','W.P. Labuan','W.P. Putrajaya',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedState = p.getString('birthday_state') ?? 'Pilih Negeri';
        _noteCtrl.text = p.getString('birthday_note') ?? '';
      });
    }
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('birthday_state', _selectedState);
    await p.setString('birthday_note', _noteCtrl.text);
    FocusScope.of(context).unfocus();
    setState(() => _writingMode = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Warkah disimpan di pangkal pokok.'),
          backgroundColor: kPrimaryGold,
        ),
      );
    }
  }

  String _treeAsset(int level) {
    if (level <= 1) return AppAssets.treeV1;
    if (level <= 3) return AppAssets.treeV2;
    if (level <= 5) return AppAssets.treeV3;
    return AppAssets.treeV4;
  }

  @override
  Widget build(BuildContext context) {
    final user   = context.watch<UserModel>();
    final double h = MediaQuery.of(context).size.height;

    return Column(
      children: [

        // ── HEADER ─────────────────────────────────────────
        if (!_writingMode) ...[
          _buildHijriCard(user),
          const SizedBox(height: 10),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabs,
              indicator: BoxDecoration(
                color: kPrimaryGold,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: kTextSecondary,
              tabs: const [
                Tab(text: 'AURA DIRI'),
                Tab(text: 'TAMAN SAHABAT'),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // ── TAB CONTENT ────────────────────────────────────
        SizedBox(
          height: h * 0.65,
          child: TabBarView(
            controller: _tabs,
            physics: _writingMode
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            children: [
              _buildAuraDiri(user),
              _buildTamanSahabat(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHijriCard(UserModel user) {
    final bool bday  = user.isBirthdayToday;
    final int  days  = user.daysUntilBirthday;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          kPrimaryGold.withOpacity(0.8),
          const Color(0xFF5D4037),
        ]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(bday ? '🎉' : '🌙',
              style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bday
                      ? 'Selamat Hari Jadi Hijrah!'
                      : 'Hari Jadi Hijrah — ${user.hijriBirthdayDisplay}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
                Text(
                  bday
                      ? user.hijriAge
                      : '$days hari lagi · ${user.hijriAge}',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuraDiri(UserModel user) {
    return Stack(
      alignment: Alignment.center,
      children: [

        // Pokok
        AnimatedPositioned(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCubic,
          top:    _writingMode ? -100 : 0,
          left: 0, right: 0,
          bottom: _writingMode ? 100 : 50,
          child: AnimatedScale(
            scale: _writingMode ? 1.6 : 0.9,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.bottomCenter,
            child: LivingTree(
              assetPath: _treeAsset(user.treeLevel),
              height: 450,
              onTap: () {},
            ),
          ),
        ),

        // Butang tulis
        if (!_writingMode)
          Positioned(
            bottom: 20,
            child: GestureDetector(
              onTap: () => setState(() => _writingMode = true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: kPrimaryGold,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryGold.withOpacity(0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, color: Colors.black, size: 16),
                    SizedBox(width: 8),
                    Text('TULIS WARKAH',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),

        // Kertas warkah
        AnimatedPositioned(
          duration: const Duration(milliseconds: 1200),
          curve: Curves.elasticOut,
          bottom: _writingMode ? 0 : -800,
          left: 0, right: 0,
          child: Container(
            height: 420,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF3E5AB),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(color: Colors.black54, blurRadius: 40),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Warkah ${DateTime.now().year}',
                      style: const TextStyle(
                          color: Color(0xFF5D4037),
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                          fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Color(0xFF5D4037)),
                      onPressed: () =>
                          setState(() => _writingMode = false),
                    ),
                  ],
                ),

                const Divider(
                    color: Color(0xFF8D6E63), thickness: 1.5),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _states.contains(_selectedState)
                          ? _selectedState
                          : _states[0],
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Color(0xFF5D4037)),
                      dropdownColor: const Color(0xFFF3E5AB),
                      isExpanded: true,
                      style: const TextStyle(
                          color: Color(0xFF5D4037),
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                      items: _states
                          .map((s) => DropdownMenuItem(
                              value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedState = v!),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: TextField(
                    controller: _noteCtrl,
                    maxLines: 8,
                    style: const TextStyle(
                        color: Color(0xFF3E2723),
                        fontSize: 16,
                        height: 1.5),
                    decoration: const InputDecoration(
                      hintText: 'Catatkan doa dan harapanmu...',
                      hintStyle: TextStyle(
                          color: Colors.black26,
                          fontStyle: FontStyle.italic),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8D6E63),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _save,
                    child: const Text('SIMPAN (CAP JARI)',
                        style: TextStyle(
                            color: Color(0xFFF3E5AB),
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTamanSahabat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline,
              size: 60,
              color: kPrimaryGold.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'Taman Sahabat',
            style: TextStyle(
                color: kGoldLight,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Playfair'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ucapan hari jadi Hijrah dari komuniti\nakan hadir tidak lama lagi 🌱',
            style: TextStyle(
                color: kTextSecondary, fontSize: 12, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
