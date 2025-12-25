import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart';
import 'living_tree.dart'; // ✅ GUNA LIVING TREE TERUS (LEBIH STABIL UNTUK ZOOM)

class BirthdayView extends StatefulWidget {
  const BirthdayView({Key? key}) : super(key: key);

  @override
  State<BirthdayView> createState() => _BirthdayViewState();
}

class _BirthdayViewState extends State<BirthdayView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _noteController = TextEditingController();
  
  // State Zoom
  bool _isWritingMode = false; 

  // Data Lokasi
  final List<String> _states = [
    'Pilih Negeri', 'Johor', 'Kedah', 'Kelantan', 'Melaka', 'Negeri Sembilan',
    'Pahang', 'Perak', 'Perlis', 'Pulau Pinang', 'Sabah', 'Sarawak', 
    'Selangor', 'Terengganu', 'W.P. Kuala Lumpur', 'W.P. Labuan', 'W.P. Putrajaya'
  ];
  String _selectedState = 'Pilih Negeri';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedState = prefs.getString('birthday_state') ?? 'Pilih Negeri';
        _noteController.text = prefs.getString('birthday_note') ?? '';
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('birthday_state', _selectedState);
    await prefs.setString('birthday_note', _noteController.text);
    
    FocusScope.of(context).unfocus();
    setState(() {
      _isWritingMode = false; // Zoom out lepas simpan
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✨ Warkah disimpan di pangkal pokok."),
          backgroundColor: kPrimaryGold,
        ),
      );
    }
  }

  // Helper aset video
  String _getTreeAsset(int level) {
    if (level <= 1) return 'assets/videos/tree_v1.mp4'; 
    if (level <= 3) return 'assets/videos/tree_v2.mp4';
    if (level <= 5) return 'assets/videos/tree_v3.mp4';
    return 'assets/videos/tree_v1.mp4'; 
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    return Column(
      children: [
        // HEADER (Hilang bila tulis)
        if (!_isWritingMode) ...[
           Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [kPrimaryGold.withOpacity(0.8), const Color(0xFF5D4037)]),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.cake, color: Colors.white),
                const SizedBox(width: 10),
                const Text("Raikan Hijrahmu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 40,
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(color: kPrimaryGold, borderRadius: BorderRadius.circular(10)),
              labelColor: Colors.black, unselectedLabelColor: Colors.grey,
              tabs: const [Tab(text: "AURA DIRI"), Tab(text: "TAMAN SAHABAT")],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // ISI KANDUNGAN
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: _isWritingMode ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
            children: [
              // ================= TAB 1: AURA DIRI =================
              Stack(
                alignment: Alignment.center,
                children: [
                  // 1. LAYER POKOK (DIJAMIN MUNCUL)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOutCubic,
                    // Kita mainkan posisi Bottom supaya dia naik/turun
                    bottom: _isWritingMode ? -50 : 20, 
                    left: 0, 
                    right: 0,
                    height: 500, // ✅ SIZE TETAP: Takkan jadi penyek!
                    child: AnimatedScale(
                      scale: _isWritingMode ? 1.5 : 0.85, // Zoom 1.5x bila tulis
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeInOutCubic,
                      alignment: Alignment.bottomCenter, // Zoom dari pangkal
                      child: LivingTree( // Guna widget video terus
                        assetPath: _getTreeAsset(user.treeLevel),
                        height: 500, // Pastikan tinggi video cukup
                        onTap: () {},
                      ),
                    ),
                  ),

                  // 2. BUTANG "MULA MENULIS"
                  if (!_isWritingMode)
                    Positioned(
                      bottom: 40,
                      child: GestureDetector(
                        onTap: () => setState(() => _isWritingMode = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: kPrimaryGold,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [BoxShadow(color: kPrimaryGold.withOpacity(0.5), blurRadius: 15)],
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.edit, color: Colors.black, size: 16),
                              SizedBox(width: 8),
                              Text("TULIS WARKAH", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // 3. KERTAS ANTIK (Slide Naik)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.elasticOut,
                    bottom: _isWritingMode ? 0 : -600, // Sorok kat bawah skrin
                    left: 0, right: 0,
                    child: Container(
                      height: 400,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5AB), // Warna Kertas Lama
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                        boxShadow: [const BoxShadow(color: Colors.black54, blurRadius: 30)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Warkah ${DateTime.now().year}", style: const TextStyle(color: Color(0xFF5D4037), fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                              IconButton(
                                icon: const Icon(Icons.close, color: Color(0xFF5D4037)),
                                onPressed: () => setState(() => _isWritingMode = false),
                              )
                            ],
                          ),
                          const Divider(color: Color(0xFF8D6E63)),
                          
                          // Dropdown Negeri
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _states.contains(_selectedState) ? _selectedState : _states[0],
                              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF5D4037)),
                              dropdownColor: const Color(0xFFF3E5AB),
                              isExpanded: true,
                              style: const TextStyle(color: Color(0xFF5D4037), fontWeight: FontWeight.bold),
                              items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (v) => setState(() => _selectedState = v!),
                            ),
                          ),
                          
                          // Input Doa
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              maxLines: 8,
                              style: const TextStyle(color: Color(0xFF3E2723), fontSize: 16, height: 1.5, fontFamily: 'serif'),
                              decoration: const InputDecoration(
                                hintText: "Catatkan doa di sini...",
                                hintStyle: TextStyle(color: Colors.black38, fontStyle: FontStyle.italic),
                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          // Butang Simpan
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8D6E63)),
                              onPressed: _saveData,
                              child: const Text("SIMPAN (CAP JARI)", style: TextStyle(color: Color(0xFFF3E5AB))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ================= TAB 2: TAMAN SAHABAT =================
              Center(child: Text("Komuniti Akan Datang", style: TextStyle(color: Colors.grey))),
            ],
          ),
        ),
      ],
    );
  }
}
