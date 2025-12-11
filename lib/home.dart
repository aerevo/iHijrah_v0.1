// lib/home.dart (LESS OPACITY ON BACKGROUND OVERLAY)
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models
import 'models/user_model.dart';
// Utils
import 'utils/constants.dart';
import 'utils/audio_service.dart';
import 'utils/hijri_service.dart';

// Widgets
import 'widgets/metallic_gold.dart';
import 'widgets/prayer_time_overlay.dart';
import 'screens/onboarding_dob.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _pageController;
  
  // State
  int _selectedIndex = 0;
  bool _isMenuExpanded = false; 

  // DUMMY DATA (Feed) - KEKALKAN
  final List<Map<String, String>> _dummyPosts = [
    {
      "name": "Ustaz Don",
      "time": "2 minit lepas",
      "content": "Jangan lupa Al-Kahfi hari ini sahabat semua. Cahaya di antara dua Jumaat.",
    },
    {
      "name": "Komuniti iHijrah",
      "time": "15 minit lepas",
      "content": "Ramai yang dah berjaya penuhkan solat 5 waktu minggu ini. Teruskan istiqamah! 🔥",
    },
    {
      "name": "Sarah",
      "time": "1 jam lepas",
      "content": "Subhanallah, tenang hati dengar zikir pagi tadi.",
    },
    {
      "name": "Admin",
      "time": "3 jam lepas",
      "content": "Update baru: Kami telah menambah ciri 'Jejak Amalan'. Cuba sekarang di menu profil.",
    },
    {
      "name": "Haziq",
      "time": "4 jam lepas",
      "content": "Alhamdulillah selesai qadha solat subuh yang tertinggal.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pageController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AudioService>(context, listen: false).playBismillah();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Logic Tukar Wallpaper Siang/Malam
  String _getBackgroundImage() {
    final hour = DateTime.now().hour;
    bool isDay = hour >= 6 && hour < 19;
    return isDay 
        ? 'assets/images/masjid_nabawi.png' 
        : 'assets/images/sunnah_mekah.png';
  }

  void _toggleMenu() {
    setState(() => _isMenuExpanded = !_isMenuExpanded);
    Provider.of<AudioService>(context, listen: false).playClick();
  }

  String _calculateHijriAge(DateTime? birthDate) {
    if (birthDate == null) return "Unknown";
    final hijriBirth = HijriService.fromDate(birthDate);
    final hijriNow = HijriService.nowHijri();
    final age = hijriNow.hYear - hijriBirth.hYear;
    return "$age Tahun";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Builder(
          builder: (context) {
            try {
              return _buildMainContent(); // Function asal kau
            } catch (e, stackTrace) {
              print('❌ HomePage ERROR: $e');
              print('Stack: $stackTrace');

              // Fallback UI
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 60),
                    const SizedBox(height: 20),
                    Text('Error: $e',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const OnboardingDOB()),
                      ),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    final user = Provider.of<UserModel>(context);

    return Stack(
      children: [
        // === LAYER 1: DYNAMIC BACKGROUND (OPACITY DIUBAH) ===
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            child: Container(
              key: ValueKey(_getBackgroundImage()),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_getBackgroundImage()),
                  fit: BoxFit.cover,
                ),
              ),
              // OPACITY DIKURANGKAN DARI 0.4 KE 0.2
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
        ),

        // === LAYER 2: SOCIAL FEED (SCROLLABLE) ===
        Positioned.fill(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 120),
            itemCount: _dummyPosts.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const SizedBox(height: 160);
              }

              final post = _dummyPosts[index - 1];
              return _buildSocialPostCard(post);
            },
          ),
        ),

        // === LAYER 3: WAKTU SOLAT HUD (MINIMALIS) ===
        const Positioned(top: 60, left: 20, right: 20, child: PrayerTimeOverlay()),

        // === LAYER 4: SIDEBAR MENU (FULLSCREEN OVERLAY) ===
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _isMenuExpanded
              ? _buildFullscreenMenu(user)
              : const SizedBox.shrink(),
        ),

        // === LAYER 5: FLOATING DOCK ===
        if (!_isMenuExpanded)
          Positioned(bottom: 30, left: 20, right: 20, child: _buildGlassDock()),
      ],
    );
  }

  // === WIDGET: SOCIAL POST CARD (GANTUNG DARI HOME.DART) ===
  Widget _buildSocialPostCard(Map<String, String> post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: kPrimaryGold.withOpacity(0.2),
                      child: const Icon(Icons.person, color: kPrimaryGold, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post["name"]!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins'),
                        ),
                        Text(
                          post["time"]!,
                          style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post["content"]!,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4, fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.favorite_border, color: Colors.white54, size: 18),
                    const SizedBox(width: 6),
                    Text("Suka", style: TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Poppins')),
                    const SizedBox(width: 20),
                    Icon(Icons.chat_bubble_outline, color: Colors.white54, size: 18),
                    const SizedBox(width: 6),
                    Text("Komen", style: TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Poppins')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // === WIDGET: FULLSCREEN SIDEBAR MENU ===
  Widget _buildFullscreenMenu(UserModel user) {
    // ... (Kod _buildFullscreenMenu kekal sama seperti sebelum ini) ...
    // Saya salin sebahagian untuk memastikan font Poppins digunakan
    return Positioned.fill(
      key: const ValueKey("MenuOverlay"),
      child: GestureDetector(
        onTap: _toggleMenu,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: const AssetImage('assets/images/latar_corak.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.85),
                BlendMode.darken,
              ),
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: IconButton(
                          onPressed: _toggleMenu,
                          icon: const Icon(Icons.close, color: Colors.white54, size: 35),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // HERO: MASKOT POKOK
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kPrimaryGold, width: 2),
                        boxShadow: [
                          BoxShadow(color: kPrimaryGold.withOpacity(0.3), blurRadius: 40, spreadRadius: 5),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.black,
                        backgroundImage: AssetImage('assets/images/logo.png'), 
                      ),
                    ),
                    
                    const SizedBox(height: 25),
                    
                    // NAMA USER
                    MetallicGold(
                      child: Text(
                        user.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),

                    // UMUR HIJRAH
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        "UMUR HIJRAH: ${_calculateHijriAge(user.birthdate)}",
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      ),
                    ),

                    const SizedBox(height: 40),
                    Divider(color: Colors.white.withOpacity(0.1), indent: 50, endIndent: 50),
                    const SizedBox(height: 20),

                    // MENU ITEMS
                    _buildMenuItem("Panduan Sirah", Icons.menu_book),
                    _buildMenuItem("Jejak Amalan", Icons.track_changes),
                    _buildMenuItem("Statistik Ibadah", Icons.bar_chart),
                    _buildMenuItem("Tetapan", Icons.settings),
                    _buildMenuItem("Log Keluar", Icons.logout),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildMenuItem, _buildGlassDock, _buildDockIcon, _buildMainActionButton 
  // (KEKAL SAMA - Font Poppins sudah diset dalam main.dart)

  Widget _buildMenuItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GestureDetector(
        onTap: () => Provider.of<AudioService>(context, listen: false).playClick(),
        child: Container(
          color: Colors.transparent, 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white54, size: 26),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.5,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassDock() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDockIcon(0, Icons.home_filled),
              _buildDockIcon(1, Icons.history_edu),
              _buildMainActionButton(),
              _buildDockIcon(2, Icons.calendar_month),
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white54, size: 28),
                onPressed: _toggleMenu, 
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDockIcon(int index, IconData icon) {
    final bool isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(icon, color: isSelected ? kPrimaryGold : Colors.white54, size: 28),
      onPressed: () {
        setState(() => _selectedIndex = index);
        Provider.of<AudioService>(context, listen: false).playClick();
      },
    );
  }

  Widget _buildMainActionButton() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [kPrimaryGold, Color(0xFFAA771C)]),
          boxShadow: [BoxShadow(color: kPrimaryGold.withOpacity(0.4), blurRadius: 20)],
        ),
        child: IconButton(
          icon: const Icon(Icons.check, color: Colors.black, size: 32),
          onPressed: () => Provider.of<AudioService>(context, listen: false).playClick(),
        ),
      ),
    );
  }
}
