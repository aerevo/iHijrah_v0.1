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
  final TextEditingController _emailController = TextEditingController();
  
  int _currentStep = 0;
  DateTime _selectedDate = DateTime(2000, 1, 1);
  String _selectedGender = 'Lelaki';
  String _authMethod = 'E-mel';

  // 🔙 FUNGSI TUTUP KEYBOARD (YANG KAU NAK)
  void _dismissKeyboard() => FocusScope.of(context).unfocus();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _dismissKeyboard, // Tekan mana-mana, keyboard hilang!
        child: Stack(
          children: [
            // Background Langit Premium
            Positioned.fill(
              child: Image.asset('assets/images/langit.png', fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.2)),
            ),
            
            Column(
              children: [
                const SizedBox(height: 70),
                _buildProgressDots(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // User kena tekan butang
                    onPageChanged: (i) => setState(() => _currentStep = i),
                    children: [
                      _stepAuth(),     // Step 1: Kaedah Daftar
                      _stepIdentity(), // Step 2: Nama & Tarikh
                      _stepFinal(),    // Step 3: Jantina & Avatar
                    ],
                  ),
                ),
                _buildBottomButtons(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 1: AUTHENTICATION (STYLE FB) ---
  Widget _stepAuth() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("SELAMAT DATANG", style: TextStyle(color: kPrimaryGold, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 10),
          const Text("Mulakan perjalanan hijrah anda", style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 50),
          _authButton("Teruskan dengan Google", Icons.g_mobiledata, Colors.redAccent),
          _authButton("Teruskan dengan E-mel", Icons.email_outlined, kPrimaryGold),
          _authButton("Masuk sebagai Tetamu", Icons.person_outline, Colors.white24),
        ],
      ),
    );
  }

  // --- STEP 2: NAMA & TARIKH ---
  Widget _stepIdentity() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const SizedBox(height: 100),
          _inputField(_nameController, "Nama Penuh", Icons.face),
          const SizedBox(height: 20),
          _inputField(_emailController, "Alamat E-mel", Icons.alternate_email),
          const SizedBox(height: 40),
          const Text("Tarikh Lahir (Masihi)", style: TextStyle(color: kPrimaryGold)),
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
  Widget _stepFinal() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Pilih Karakter", style: TextStyle(color: kPrimaryGold, fontSize: 20)),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _genderChoice("Lelaki", Icons.male),
            const SizedBox(width: 20),
            _genderChoice("Perempuan", Icons.female),
          ],
        ),
        const SizedBox(height: 50),
        // Sini kau boleh tambah CircleAvatar sebagai hiasan
        const CircleAvatar(radius: 50, backgroundColor: kCardDark, child: Icon(Icons.person, size: 50, color: kPrimaryGold)),
      ],
    );
  }

  // ================= HELPERS =================

  Widget _authButton(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          side: BorderSide(color: color.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () {
          _authMethod = label;
          _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.ease);
        },
        icon: Icon(icon, color: color),
        label: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: kPrimaryGold, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _genderChoice(String label, IconData icon) {
    bool isSel = _selectedGender == label;
    return InkWell(
      onTap: () => setState(() => _selectedGender = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          color: isSel ? kPrimaryGold : Colors.white10,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: isSel ? Colors.black : Colors.white),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 6, width: _currentStep == i ? 30 : 10,
        decoration: BoxDecoration(color: _currentStep == i ? kPrimaryGold : Colors.white24, borderRadius: BorderRadius.circular(3)),
      )),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0) 
            TextButton(
              onPressed: () => _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.ease),
              child: const Text("KEMBALI", style: TextStyle(color: Colors.white54)),
            ) else const SizedBox(),
          
          if (_currentStep > 0)
          ElevatedButton(
            onPressed: () {
              if (_currentStep == 2) {
                _finalise();
              } else {
                _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.ease);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
            child: Text(_currentStep == 2 ? "MULAKAN" : "SETERUSNYA"),
          ),
        ],
      ),
    );
  }

  void _finalise() async {
    final user = Provider.of<UserModel>(context, listen: false);
    user.name = _nameController.text;
    user.email = _emailController.text;
    user.birthdate = _selectedDate;
    user.gender = _selectedGender;
    await user.save();
    
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
  }
}
