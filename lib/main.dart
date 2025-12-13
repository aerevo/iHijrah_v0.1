// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Import Screens & Utils
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

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

  // 2. Load User Data from SharedPreferences
  final userModel = await UserModel.load();

  // 3. Lock Orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 4. Set Status Bar Color
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(IHijrahApp(userModel: userModel));
}

class IHijrahApp extends StatelessWidget {
  final UserModel userModel;
  const IHijrahApp({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    // 5. Setup MultiProvider
    return MultiProvider(
      providers: [
        // Data Providers
        ChangeNotifierProvider.value(value: userModel),
        ChangeNotifierProvider(create: (_) => SidebarStateModel()),
        ChangeNotifierProvider(create: (_) => AnimationControllerModel()),

        // Service Providers (Logic)
        Provider(create: (_) => AudioService()),
        
        // PrayerService bergantung pada UserModel (Proxy)
        ChangeNotifierProxyProvider<UserModel, PrayerService>(
            create: (context) => PrayerService(context.read<UserModel>()),
            update: (context, user, prayerService) => prayerService!..updateUser(user),
        ),
        
        Provider(create: (_) => SirahService()),
      ],
      child: MaterialApp(
        title: 'iHijrah Embun Jiwa',
        debugShowCheckedModeBanner: false,

        // 6. Global Theme Definition
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF17203A), // Guna warna sidebar/umum
          primaryColor: kPrimaryGold,
          fontFamily: 'Roboto', // Atau font pilihan Kapten

          colorScheme: const ColorScheme.dark(
            primary: kPrimaryGold,
            secondary: kAccentOlive,
            surface: kCardDark,
            background: kBackgroundDark,
          ),

          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: kTextPrimary),
            bodySmall: TextStyle(color: kTextSecondary),
          ),

          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),

        // 7. Entry Point -> Bermula di Splash Screen
        home: const SplashScreen(),
      ),
    );
  }
}
