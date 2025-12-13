// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Import Screens & Utils
import 'screens/splash_screen.dart'; // Pastikan path ini betul relative kepada main.dart
import 'utils/constants.dart';

// Import Models & Services for Provider
import 'models/user_model.dart';
import 'models/sidebar_state_model.dart';
import 'models/animation_controller_model.dart';
import 'utils/audio_service.dart';
import 'utils/prayer_service.dart';
import 'utils/sirah_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final userModel = await UserModel.load();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userModel),
        ChangeNotifierProvider(create: (_) => SidebarStateModel()),
        ChangeNotifierProvider(create: (_) => AnimationControllerModel()),
        Provider(create: (_) => AudioService()),
        ChangeNotifierProxyProvider<UserModel, PrayerService>(
            create: (context) => PrayerService(context.read<UserModel>()),
            update: (context, user, prayerService) => prayerService!..updateUser(user),
        ),
        Provider(create: (_) => SirahService()),
      ],
      child: MaterialApp(
        title: 'iHijrah Embun Jiwa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF17203A),
          primaryColor: kPrimaryGold,
          fontFamily: 'Roboto',
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
        // Bermula di Splash Screen
        home: const SplashScreen(),
      ),
    );
  }
}
