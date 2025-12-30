// ... imports sedia ada
import 'birthday_view.dart'; 
import 'sirah_view.dart'; // ✅ 1. TAMBAH IMPORT INI

// ... dalam class FlyoutPanel ...

  Widget _buildContent(String menuId) {
    switch (menuId) {
      case 'profil': return const ProfileDetailView();
      case 'kalendar': return const CalendarView();
      case 'peristiwa': return const EventView();
      case 'notifikasi': return const SettingsView();
      case 'info': return const AboutView();
      case 'tree_progress': return const HijrahTree(); // Kalau nak tree shj
      case 'birthday': return const BirthdayView();

      // ✅ 2. UPDATE CASE SIRAH JADI MACAM NI:
      case 'sirah': return const SirahView(); 
      
      case 'infaq': 
        return const Center(child: Text("Infaq - Coming Soon", style: TextStyle(color: kTextSecondary)));
      default: return const SizedBox.shrink();
    }
  }
