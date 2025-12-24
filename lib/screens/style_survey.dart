import 'package:flutter/material.dart';
import 'dart:ui'; // Untuk Glassmorphism (Blur)

class StyleSurvey extends StatelessWidget {
  const StyleSurvey({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kita guna latar belakang Gradient Emas-Hitam supaya nampak efek kaca/transparent
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF000000), Color(0xFF434343)], // Latar Gelap
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "PILIH GAYA SIDEBAR TUAN",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Latar belakang gelap ini adalah simulasi 'Wallpaper' App.",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 50),

                // --- GAYA A: GLASSMORPHISM (iOS / Windows 11) ---
                const Text("GAYA A: THE FLOATING GLASS (Moden)", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Efek Kabur
                    child: Container(
                      width: 80,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1), // Putih Lutsinar
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Icon(Icons.person, color: Colors.white),
                          Icon(Icons.home, color: Colors.white),
                          Icon(Icons.settings, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),

                // --- GAYA B: OLED MIDNIGHT (Mewah Mutlak) ---
                const Text("GAYA B: OLED MIDNIGHT (Solid & Kontra)", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                Container(
                  width: 80,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.black, // Hitam Pekat
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Color(0xFFD4AF37), blurRadius: 10, spreadRadius: -5) // Glow Emas
                    ],
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1), // Border Emas Halus
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Icon(Icons.person, color: Color(0xFFD4AF37)), // Ikon Emas
                      Icon(Icons.home, color: Color(0xFFD4AF37)),
                      Icon(Icons.settings, color: Color(0xFFD4AF37)),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // --- GAYA C: MINIMALIST WHITE (Butik) ---
                const Text("GAYA C: WHITE GOLD (Suci & Bersih)", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 10),
                Container(
                  width: 80,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white, // Putih Suci
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Icon(Icons.person, color: Colors.black87),
                      Icon(Icons.home, color: Color(0xFFD4AF37)), // Highlight Emas
                      Icon(Icons.settings, color: Colors.black87),
                    ],
                  ),
                ),
                
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}