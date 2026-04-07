import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../home.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  
  int _currentStep = 0;
  DateTime _selectedDate = DateTime(2000, 1, 1);
  String _selectedGender = 'Lelaki';

  void _dismissKeyboard() => FocusScope.of(context).unfocus();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _dismissKeyboard,
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset('assets/images/langit.png', fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.2))),
            Column(
              children: [
                const SizedBox(height: 80),
                _buildProgressDots(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentStep = i),
                    children: [
                      _stepOneAuth(),
                      _stepTwoIdentity(),
                      _stepThreeAvatar(),
                    ],
                  ),
                ),
                _buildBottomNav(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 1: PILIHAN SAMBUTAN ---
  Widget _stepOneAuth() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("SELAMAT DATANG", style: TextStyle(color: kPrimaryGold, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 40),
          _authBtn("Teruskan dengan Google", Icons.g_mobiledata, Colors.white),
          _authBtn("Teruskan dengan E-mel", Icons.email_outlined, kPrimaryGold),
          TextButton(
            onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.ease),
            child: const Text("DAFTAR KEMUDIAN (LANGKAU)", style: TextStyle(color: Colors.white54, decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }

  // --- STEP 2: NAMA & TARIKH ---
  Widget _stepTwoIdentity() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("MAKLUMAT PERIBADI", style: TextStyle(color: kPrimaryGold, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.badge_outlined, color: kPrimaryGold),
              labelText: "Nama Penuh",
              labelStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 30),
          const Text("Tarikh Lahir", style: TextStyle(color: Colors.white54, fontSize: 12)),
          SizedBox(
            height: 150,
            child: CupertinoTheme(
              data: const CupertinoThemeData(brightness: Brightness.dark),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _selectedDate,
                onDateTimeChanged: (d) => _selectedDate = d,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 3: JANTINA & AVATAR ---
  Widget _stepThreeAvatar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("PILIH KARAKTER", style: TextStyle(color: kPrimaryGold, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _genderTab("Lelaki"),
            const SizedBox(width: 20),
            _genderTab("Wanita"),
          ],
        ),
        const SizedBox(height: 40),
        // Placeholder Avatar (Professional Look)
        CircleAvatar(
          radius: 60,
          backgroundColor: kPrimaryGold.withOpacity(0.1),
          child: Icon(
            _selectedGender == "Lelaki" ? Icons.person : Icons.person_3, 
            size: 80, 
            color: kPrimaryGold
          ),
        ),
        const SizedBox(height: 10),
        const Text("(Pilihan Avatar akan tersedia di versi penuh)", style: TextStyle(color: Colors.white24, fontSize: 10)),
      ],
    );
  }

  // --- WIDGET HELPERS ---
  Widget _authBtn(String label, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.bottom(15),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white10,
          foregroundColor: color,
          padding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.3))),
        ),
        onPressed: () => _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.ease),
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _genderTab(String label) {
    bool isSel = _selectedGender == label;
    return InkWell(
      onTap: () => setState(() => _selectedGender = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        decoration: BoxDecoration(
          color: isSel ? kPrimaryGold : Colors.white10,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(label, style: TextStyle(color: isSel ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: _currentStep == i ? 25 : 8,
        height: 8,
        decoration: BoxDecoration(color: _currentStep == i ? kPrimaryGold : Colors.white24, borderRadius: BorderRadius.circular(4)),
      )),
    );
  }

  Widget _buildBottomNav() {
    if (_currentStep == 0) return const SizedBox(height: 100);
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.ease), child: const Text("KEMBALI", style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () {
              if (_currentStep == 2) _submit();
              else _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.ease);
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGold, foregroundColor: Colors.black),
            child: Text(_currentStep == 2 ? "SELESAI" : "SETERUSNYA"),
          )
        ],
      ),
    );
  }

  void _submit() async {
    final user = Provider.of<UserModel>(context, listen: false);
    user.name = _nameController.text.isEmpty ? "Hamba Allah" : _nameController.text;
    user.birthdate = _selectedDate;
    user.gender = _selectedGender;
    await user.save();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
  }
}
