import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // YENİ EKLENDİ
import 'providers/parking_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

// YENİ EKLENDİ: async yapıldı
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // CİHAZ HAFIZASINI KONTROL ET
  final prefs = await SharedPreferences.getInstance();
  final savedPlate = prefs.getString('driver_plate');

  // Eğer plaka varsa giriş yapılmış kabul et
  final isLoggedIn = savedPlate != null && savedPlate.isNotEmpty;

  runApp(OtoparkApp(isLoggedIn: isLoggedIn));
}

class OtoparkApp extends StatelessWidget {
  final bool isLoggedIn; // YENİ EKLENDİ

  const OtoparkApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ParkingProvider(),
      child: MaterialApp(
        title: 'Akıllı Otopark',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(
            surface:   const Color(0xFF0D0F14),
            onSurface: const Color(0xFFE8EAF0),
            primary:   const Color(0xFF22C55E),
            secondary: const Color(0xFFEF4444),
            surfaceContainerHighest: const Color(0xFF1C2029),
          ),
          scaffoldBackgroundColor: const Color(0xFF0D0F14),
          cardTheme: CardThemeData(
            color:        const Color(0xFF1C2029),
            elevation:    0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.07)),
            ),
          ),
          fontFamily: 'Roboto',
        ),
        // YENİ EKLENDİ: GİRİŞ DURUMUNA GÖRE EKRAN YÖNLENDİRMESİ
        home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }
}