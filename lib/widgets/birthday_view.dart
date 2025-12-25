import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart';
import 'hijrah_tree.dart';

class BirthdayView extends StatefulWidget {
  const BirthdayView({Key? key}) : super(key: key);

  @override
  State<BirthdayView> createState() => _BirthdayViewState();
}

class _BirthdayViewState extends State<BirthdayView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _noteController = TextEditingController();
  
  // State untuk Animasi Zoom & Kertas
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
    
    // Tutup keyboard & Zoom out
    FocusScope.of(context).unfocus();
    setState(() {
      _isWritingMode = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✨ Warkah anda telah disimpan di pangkal pokok."),
          backgroundColor: kPrimaryGold,
        ),
      );
    }
  }

  void _toggleWritingMode() {
    setState(() {
      _isWritingMode = !_isWritingMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    return Column(
      children: [
        // HEADER (Kekal)
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
              // ================= TAB 1: AURA DIRI (INTERAKTIF ZOOM) =================
              Stack(
                alignment: Alignment.center,
                children: [
                  // 1. LAYER POKOK (BACKGROUND)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOutCubic,
                    // Bila zoom, kita tarik pokok ke atas sikit supaya nampak pangkal
                    top: _isWritingMode ? -150 : 20, 
                    left: 0, right: 0,
                    bottom: _isWritingMode ? 100 : 80, // Bagi ruang untuk pokok memanjang
                    child: AnimatedScale(
                      scale: _isWritingMode ? 1.8 : 0.9, // ZOOM 1.8x bila menulis
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeInOutCubic,
                      alignment: Alignment.bottomCenter, // Zoom fokus ke pangkal (bawah)
                      child: const HijrahTree(),
                    ),
                  ),

                  // 2. BUTANG MULA MENULIS (Hanya muncul bila belum zoom)
                  if (!_isWritingMode)
                    Positioned(
                      bottom: 40,
                      child: GestureDetector(
                        onTap: _toggleWritingMode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          decoration: BoxDecoration(
                            color: kPrimaryGold,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(color: kPrimaryGold.withOpacity(0.5), blurRadius: 15, spreadRadius: 1)
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.edit_note, color: Colors.black),
                              SizedBox(width: 8),
                              Text("TULIS WARKAH DI PANGKAL POKOK", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // 3. KERTAS NOTA ANTIK (Muncul bila Zoom)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.elasticOut,
                    bottom: _isWritingMode ? 20 : -500, // Slide dari bawah
                    left: 20, right: 20,
                    child: Container(
                      height: 380,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5AB), // Warna Vanilla/Kertas Lama
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          const BoxShadow(color: Colors.black54, blurRadius: 30, spreadRadius: 5),
                          BoxShadow(color: Colors.brown.withOpacity(0.3), blurRadius: 5, offset: const Offset(0, -2))
                        ],
                        border: Border.all(color: const Color(0xFF8D6E63), width: 2), // Border Coklat
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Kertas
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Warkah ${DateTime.now().year}", 
                                style: const TextStyle(
                                  color: Color(0xFF5D4037), 
                                  fontFamily: 'serif', 
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic
                                )
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Color(0xFF5D4037)),
                                onPressed: _toggleWritingMode, // Tutup/Zoom Out
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              )
                            ],
                          ),
                          const Divider(color: Color(0xFF8D6E63), thickness: 1),
                          
                          // Input Negeri (Dropdown Style Lama)
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _states.contains(_selectedState) ? _selectedState : _states[0],
                              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF5D4037)),
                              dropdownColor: const Color(0xFFF3E5AB),
                              isExpanded: true,
                              style: const TextStyle(color: Color(0xFF5D4037), fontWeight: FontWeight.bold, fontFamily: 'serif'),
                              items: _states.map((String value) {
                                return DropdownMenuItem<String>(value: value, child: Text(value));
                              }).toList(),
                              onChanged: (newValue) => setState(() => _selectedState = newValue!),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Text Area (Doa)
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              maxLines: 8,
                              style: const TextStyle(
                                color: Color(0xFF3E2723), 
                                fontSize: 16, 
                                fontFamily: 'serif', // Font gaya lama
                                height: 1.5,
                              ),
                              decoration: const InputDecoration(
                                hintText: "Catatkan doa dan harapanmu di sini...",
                                hintStyle: TextStyle(color: Colors.black38, fontStyle: FontStyle.italic, fontFamily: 'serif'),
                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          // Cap / Butang Simpan
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8D6E63), // Coklat Kayu
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                              ),
                              onPressed: _saveData,
                              child: const Text("SIMPAN (CAP JARI)", style: TextStyle(color: Color(0xFFF3E5AB), fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ================= TAB 2: TAMAN SAHABAT (Kekal) =================
              Center(
                child: Opacity(
                  opacity: 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.diversity_1, size: 50, color: kPrimaryGold),
                      const SizedBox(height: 20),
                      const Text("KOMUNITI AKAN DATANG", style: TextStyle(color: Colors.white, letterSpacing: 1.5)),
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Ruang untuk mengaminkan doa sahabat.", style: TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
