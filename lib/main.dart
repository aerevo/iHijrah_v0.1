// lib/main.dart (WAYAR DISAMBUNG)
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
import 'providers/daily_content_provider.dart'; // ✅ IMPORT INI PENTING
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
        // Data Providers
        ChangeNotifierProvider.value(value: userModel),
        ChangeNotifierProvider(create: (_) => SidebarStateModel()),
        ChangeNotifierProvider(create: (_) => AnimationControllerModel()),
        
        // ✅ [PENYELAMAT] OTAK DATA HARIAN DIHIDUPKAN DI SINI:
        ChangeNotifierProvider(create: (_) => DailyContentProvider()), 

        // Service Providers
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
          scaffoldBackgroundColor: Colors.black,
          primaryColor: kPrimaryGold,
          fontFamily: 'Roboto',
          colorScheme: const ColorScheme.dark(
            primary: kPrimaryGold,
            secondary: kAccentOlive,
            surface: kCardDark,
            background: kBackgroundDark,
          ),
        ),
        home: const SplashScreen(), 
      ),
    );
  }
}
