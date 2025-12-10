// lib/main.dart (INSTANT LAUNCH - NO WAITING)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Screens & Utils
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

// Models & Services
import 'models/user_model.dart';
import 'models/sidebar_state_model.dart';
import 'utils/audio_service.dart';
import 'utils/prayer_service.dart';
import 'utils/sirah_service.dart';

void main() {
  // 1. Setup Asas Pantas
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Kunci Orientasi Portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 3. UI System Lutsinar (Status Bar)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // 4. TERUS RUN APP (Jangan tunggu database load di sini!)
  runApp(const IHijrahApp());
}

class IHijrahApp extends StatelessWidget {
  const IHijrahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Create Instance Kosong Dulu (Isi data kemudian di Splash Screen)
        ChangeNotifierProvider(create: (_) => UserModel()), 
        ChangeNotifierProvider(create: (_) => SidebarStateModel()),
        ChangeNotifierProvider(create: (_) => AudioService()),
        ChangeNotifierProxyProvider<UserModel, PrayerService>(
          create: (context) => PrayerService(context.read<UserModel>()),
          update: (_, user, prayerService) => prayerService!..updateUser(user),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'iHijrah',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: kPrimaryGold,
          scaffoldBackgroundColor: Colors.black,
          fontFamily: 'Poppins', 
          useMaterial3: true,
        ),
        // PINTU MASUK UTAMA
        home: const SplashScreen(),
      ),
    );
  }
}