import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // YENİ EKLENDİ
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();

  // YENİ EKLENDİ: KAYIT VE KONTROL FONKSİYONU
  Future<void> _login() async {
    final name = _nameCtrl.text.trim();
    final plate = _plateCtrl.text.trim();

    // Kutular boşsa uyarı ver
    if (name.isEmpty || plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen isim ve plaka giriniz!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Bilgileri cihaz hafızasına kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('driver_name', name);
    await prefs.setString('driver_plate', plate);

    if (!mounted) return;

    // Başarılı girişte ana ekrana yönlendir
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D0F14), Color(0xFF1A1D26)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "AKILLI OTOPARK",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
            ),
            const Text(
              "Dijital Park Asistanı",
              style: TextStyle(fontSize: 14, color: Colors.white54, letterSpacing: 1),
            ),
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: "İsim Soyisim",
                            labelStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF22C55E))),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _plateCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: "Araç Plakası",
                            labelStyle: TextStyle(color: Colors.white54),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF22C55E))),
                          ),
                        ),
                        const SizedBox(height: 35),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF22C55E),
                              shadowColor: const Color(0xFF22C55E).withOpacity(0.5),
                              elevation: 15,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _login,
                            child: const Text("GİRİŞ YAP", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}