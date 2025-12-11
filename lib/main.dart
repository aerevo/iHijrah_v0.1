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
  // ✅ Catch semua errors
  FlutterError.onError = (details) {
    print('❌ Flutter Error: ${details.exception}');
    print('Stack: ${details.stack}');
  };

  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserModel()),
        ChangeNotifierProvider(create: (_) => SidebarStateModel()),
        ChangeNotifierProvider(create: (_) => AudioService()),

        // ✅ PENTING: PrayerService perlu UserModel dulu
        ChangeNotifierProxyProvider<UserModel, PrayerService>(
          create: (context) => PrayerService(
            Provider.of<UserModel>(context, listen: false),
          ),
          update: (context, user, prayerService) =>
              prayerService!..updateUser(user),
        ),

        ChangeNotifierProvider(create: (_) => SirahService()),
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