// lib/main.dart (LINE 1-20)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Import Screens & Utils
import 'screens/splash_screen.dart';  // screens/ ada '../' sebab dalam subfolder
import 'utils/constants.dart';
import 'utils/storage_service.dart';

// Import Models & Services for Provider
import 'models/user_model.dart';
import 'models/sidebar_state_model.dart';
import 'models/animation_controller_model.dart';
import 'utils/audio_service.dart';
import 'utils/prayer_service.dart';
import 'utils/sirah_service.dart';

void main() async {
  // 1. Ensure Bindings
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Init Storage (Hive / SharedPreferences) ✅ FIXED
  await StorageService.init();

  // 3. Lock Orientation (Optional, untuk design stabil)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 4. Set Status Bar Color
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const IHijrahApp());
}

class IHijrahApp extends StatelessWidget {
  const IHijrahApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 5. Setup MultiProvider
    return MultiProvider(
      providers: [
        // Data Providers
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => SidebarStateModel()),
        ChangeNotifierProvider(create: (_) => AnimationControllerModel()),

        // Service Providers (Logic) ✅ FIXED: Provide dependencies
        Provider(create: (_) => AudioService()),
        ProxyProvider2<AudioService, UserModel, PrayerService>(
          update: (_, audio, user, prev) => PrayerService(StorageService(), audio),
        ),
        Provider(create: (_) => SirahService()),
      ],
      child: MaterialApp(
        title: 'iHijrah Embun Jiwa',
        debugShowCheckedModeBanner: false,

        // 6. Global Theme Definition
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: kBackgroundDark,
          primaryColor: kPrimaryGold,
          fontFamily: 'Roboto', // Default font body

          // Color Scheme
          colorScheme: const ColorScheme.dark(
            primary: kPrimaryGold,
            secondary: kAccentOlive,
            surface: kCardDark,
            background: kBackgroundDark,
          ),

          // Text Theme
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: kTextPrimary),
            bodySmall: TextStyle(color: kTextSecondary),
          ),

          // App Bar Theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),

        // 7. Entry Point
        home: const SplashScreen(),
      ),
    );
  }
}