import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _ctrl = TextEditingController();
  bool _testing = false;
  String? _testResult;
  bool? _testSuccess;

  @override
  void initState() {
    super.initState();
    ApiService.getBaseUrl().then((url) => _ctrl.text = url);
  }

  Future<void> _save() async {
    final url = _ctrl.text.trim();
    if (url.isEmpty) return;
    await ApiService.saveBaseUrl(url);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Kaydedildi'),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _test() async {
    await _save();
    setState(() { _testing = true; _testResult = null; });
    final ok = await ApiService.healthCheck();
    setState(() {
      _testing    = false;
      _testSuccess = ok;
      _testResult  = ok
          ? 'Bağlantı başarılı! Sunucu çalışıyor.'
          : 'Bağlantı kurulamadı. IP ve port\'u kontrol edin.\n'
          'Emülatör kullanıyorsanız: 10.0.2.2\n'
          'Gerçek cihaz kullanıyorsanız: bilgisayarınızın yerel IP adresi';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: const Color(0xFF0D0F14),
        surfaceTintColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sunucu Adresi ──
            const Text('Sunucu Adresi',
                style: TextStyle(fontSize: 13, color: Colors.white60, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              keyboardType: TextInputType.url,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'http://192.168.1.x:8000',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: const Color(0xFF1C2029),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.07)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.07)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF22C55E)),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Hızlı seçenekler ──
            Wrap(
              spacing: 8,
              children: [
                _QuickChip(label: 'Emülatör',  url: 'http://10.0.2.2:8000',    ctrl: _ctrl),
                _QuickChip(label: 'Localhost',  url: 'http://127.0.0.1:8000',   ctrl: _ctrl),
              ],
            ),
            const SizedBox(height: 20),

            // ── Butonlar ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _testing ? null : _test,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: Color(0xFF22C55E)),
                    ),
                    child: _testing
                        ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2,
                            color: Color(0xFF22C55E)))
                        : const Text('Bağlantıyı Test Et',
                        style: TextStyle(color: Color(0xFF22C55E))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Kaydet',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),

            // ── Test sonucu ──
            if (_testResult != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (_testSuccess! ? const Color(0xFF22C55E) : const Color(0xFFEF4444))
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_testSuccess! ? const Color(0xFF22C55E) : const Color(0xFFEF4444))
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _testSuccess! ? Icons.check_circle_outline : Icons.error_outline,
                      color: _testSuccess! ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _testResult!,
                        style: TextStyle(
                          fontSize: 13,
                          color: _testSuccess! ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
            // ── Bilgi kutusu ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('IP Adresi Nasıl Bulunur?',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  _InfoLine(icon: Icons.computer,     text: 'Windows: cmd → ipconfig → IPv4 Address'),
                  _InfoLine(icon: Icons.terminal,     text: 'Mac/Linux: terminal → ifconfig'),
                  _InfoLine(icon: Icons.phone_android, text: 'Telefon & bilgisayar aynı Wi-Fi\'de olmalı'),
                  _InfoLine(icon: Icons.sports_esports, text: 'Emülatör → 10.0.2.2 kullanın'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label, url;
  final TextEditingController ctrl;
  const _QuickChip({required this.label, required this.url, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () => ctrl.text = url,
      backgroundColor: const Color(0xFF1C2029),
      side: BorderSide(color: Colors.white.withOpacity(0.1)),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white38),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white54))),
        ],
      ),
    );
  }
}