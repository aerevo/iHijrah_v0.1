// WIDGET KAD ALA CAPCUT (UPGRADED)
  Widget _buildMagazineCard({
    required String title,
    required String subtitle,
    required double height,
    required String imagePath,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // Kurangkan radius sikit biar tajam
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. GAMBAR PENUH (Full Brightness)
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (c, o, s) => Container(color: Colors.grey.shade900),
            ),

            // 2. GRADIENT LANTAI (Rahsia Teks Jelas tapi Gambar Terang)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 0.8, 1.0], // Mula gelap di bawah saja
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),

            // 3. TAG KATEGORI (Kecil di atas kiri - Macam 'Autocut' badge)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), // Glass effect
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white30, width: 0.5),
                ),
                child: Text(
                  subtitle.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8, // Halus je
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),

            // 4. TEXT CONTENT (Tanam di Bawah Kiri)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // Kunci: Letak bawah
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22, // Besar!
                      fontFamily: 'Poppins', // Pastikan font moden
                      fontWeight: FontWeight.w900, // Paling Tebal
                      height: 1.0, // Rapatkan baris
                      shadows: [
                        Shadow(offset: Offset(0, 1), blurRadius: 5, color: Colors.black54),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),

                  // User Info (Kecil di bawah tajuk)
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, size: 10, color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "iHijrah Official", // Boleh ganti dynamic
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
