// lib/main.dart (UPGRADED 8.0/10)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Import Screens & Utils
import 'screens/splash_screen.dart';
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

  // 2. Init Services
  final storageService = StorageService();
  await storageService.init();
  await SirahService.load();

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

  runApp(IHijrahApp(storageService: storageService));
}

class IHijrahApp extends StatelessWidget {
  final StorageService storageService;
  const IHijrahApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    // 5. Setup MultiProvider
    return MultiProvider(
      providers: [
        // State Management Providers
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => SidebarStateModel()),
        ChangeNotifierProvider(create: (_) => AnimationControllerModel()),
        
        // Service Providers (Logic)
        Provider<StorageService>.value(value: storageService),
        Provider(create: (_) => AudioService()),
        ChangeNotifierProvider(
          create: (context) => PrayerService(
            context.read<StorageService>(),
            context.read<AudioService>(),
          ),
        ),
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
