import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart';
import 'living_tree.dart'; // Pastikan import widget pokok video

class BirthdayView extends StatefulWidget {
  const BirthdayView({Key? key}) : super(key: key);

  @override
  State<BirthdayView> createState() => _BirthdayViewState();
}

class _BirthdayViewState extends State<BirthdayView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _noteController = TextEditingController();
  
  // Data Lokasi
  final List<String> _states = [
    'Pilih Negeri', 'Johor', 'Kedah', 'Kelantan', 'Melaka', 'Negeri Sembilan',
    'Pahang', 'Perak', 'Perlis', 'Pulau Pinang', 'Sabah', 'Sarawak', 
    'Selangor', 'Terengganu', 'W.P. Kuala Lumpur', 'W.P. Labuan', 'W.P. Putrajaya'
  ];
  String _selectedState = 'Pilih Negeri';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData(); // Load data asing (tak kacau user_model)
  }

  // Load data dari memori telefon secara direct
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedState = prefs.getString('birthday_state') ?? 'Pilih Negeri';
      _noteController.text = prefs.getString('birthday_note') ?? '';
      _isLoading = false;
    });
  }

  // Simpan data ke memori telefon
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('birthday_state', _selectedState);
    await prefs.setString('birthday_note', _noteController.text);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Aura Diri disimpan!"),
          backgroundColor: kPrimaryGold,
          duration: Duration(seconds: 1),
        ),
      );
      // Tutup keyboard
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Helper untuk dapatkan video pokok (Sama macam sidebar)
  String _getTreeAsset(int level) {
    if (level <= 1) return 'assets/videos/tree_v1.mp4'; 
    if (level <= 3) return 'assets/videos/tree_v2.mp4';
    if (level <= 5) return 'assets/videos/tree_v3.mp4';
    return 'assets/videos/tree_v1.mp4'; 
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data level pokok dari User Model (Cuma baca, tak tulis)
    final user = Provider.of<UserModel>(context);

    return Column(
      children: [
        // --- TAB BAR ---
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(25),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: kPrimaryGold,
              borderRadius: BorderRadius.circular(25),
            ),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            tabs: const [
              Tab(text: "AURA DIRI"),
              Tab(text: "TAMAN SAHABAT"),
            ],
          ),
        ),

        // --- KANDUNGAN TAB ---
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // ================= TAB 1: AURA DIRI =================
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 1. POKOK DIRI (Preview)
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Pokok Video
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: LivingTree(
                              assetPath: _getTreeAsset(user.treeLevel),
                              height: 220,
                              onTap: () {}, // No action needed here
                            ),
                          ),
                          // Label Level
                          Positioned(
                            top: 10, right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: kPrimaryGold,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "LVL ${user.treeLevel}",
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. INPUT NEGERI
                    Align(alignment: Alignment.centerLeft, child: Text("Lokasi (Negeri):", style: TextStyle(color: kTextSecondary, fontSize: 12))),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kPrimaryGold.withOpacity(0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _states.contains(_selectedState) ? _selectedState : _states[0],
                          dropdownColor: const Color(0xFF222222),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          icon: const Icon(Icons.arrow_drop_down, color: kPrimaryGold),
                          items: _states.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() => _selectedState = newValue!);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 3. INPUT DOA / NOTA
                    Align(alignment: Alignment.centerLeft, child: Text("Warkah Hati & Doa Ulangtahun:", style: TextStyle(color: kTextSecondary, fontSize: 12))),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _noteController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Tulis doa atau harapan anda di sini...",
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12, fontStyle: FontStyle.italic),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: kPrimaryGold.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(color: kPrimaryGold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // 4. BUTANG SIMPAN
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryGold,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _saveData,
                        child: const Text("SIMPAN MAKLUMAT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 100), // Ruang bawah
                  ],
                ),
              ),

              // ================= TAB 2: TAMAN SAHABAT =================
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 60, color: kPrimaryGold.withOpacity(0.3)),
                    const SizedBox(height: 15),
                    const MetallicGold(
                      child: Text(
                        "KOMUNITI AKAN DATANG",
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Di sini anda akan melihat pokok-pokok sahabat lain yang menyambut ulang tahun Hijrah mereka.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
