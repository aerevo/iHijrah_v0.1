// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'utils/constants.dart';
import 'models/user_model.dart';
import 'models/sidebar_state_model.dart';
import 'models/animation_controller_model.dart';
import 'providers/daily_content_provider.dart';
import 'utils/audio_service.dart';
import 'utils/prayer_service.dart';
import 'utils/sirah_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientasi potret
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar transparent, ikon terang
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:           Colors.transparent,
    statusBarIconBrightness:  Brightness.light,
    systemNavigationBarColor: Colors.black,
  ));

  final userModel = await UserModel.load();
  runApp(IHijrahApp(userModel: userModel));
}

class IHijrahApp extends StatelessWidget {
  final UserModel userModel;
  const IHijrahApp({super.key, required this.userModel});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Model ────────────────────────────────────────────
        ChangeNotifierProvider.value(value: userModel),
        ChangeNotifierProvider(create: (_) => SidebarStateModel()),
        ChangeNotifierProvider(create: (_) => AnimationControllerModel()),
        
        // ✅ [PENYELAMAT] OTAK DATA HARIAN DIHIDUPKAN DI SINI:
        ChangeNotifierProvider(create: (_) => DailyContentProvider()), 

        // ── Kandungan Harian ─────────────────────────────────
        ChangeNotifierProvider(create: (_) => DailyContentProvider()),

        // ── Servis ───────────────────────────────────────────
        Provider(create: (_) => AudioService()),
        Provider(create: (_) => SirahService()),
        ChangeNotifierProxyProvider<UserModel, PrayerService>(
          create: (ctx) => PrayerService(ctx.read<UserModel>()),
          update: (ctx, user, prev) => prev!..updateUser(user),
        ),
      ],
      child: MaterialApp(
        title:                    'iHijrah Embun Jiwa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness:              Brightness.dark,
          scaffoldBackgroundColor: kBackgroundDark,
          primaryColor:            kPrimaryGold,
          fontFamily:              'Poppins',
          colorScheme: const ColorScheme.dark(
            primary:    kPrimaryGold,
            secondary:  kAccentOlive,
            surface:    kCardDark,
            background: kBackgroundDark,
          ),
          // Override text supaya Poppins dipakai seluruh app
          textTheme: const TextTheme(
            bodyLarge:   TextStyle(fontFamily: 'Poppins', color: kTextPrimary),
            bodyMedium:  TextStyle(fontFamily: 'Poppins', color: kTextPrimary),
            bodySmall:   TextStyle(fontFamily: 'Poppins', color: kTextSecondary),
            titleLarge:  TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, color: kTextPrimary),
            titleMedium: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: kTextPrimary),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
