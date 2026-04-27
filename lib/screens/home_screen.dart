import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/parking_provider.dart';
import '../models/parking_spot.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ParkingProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              color: const Color(0xFF22C55E),
              backgroundColor: const Color(0xFF1C2029),
              onRefresh: provider.refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _AppBar(provider: provider),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 8),
                        _ConnectionBanner(provider: provider),
                        const SizedBox(height: 20),

                        // EĞER REZERVASYON VARSA GERİ SAYIM BANDINI GÖSTER
                        if (provider.activeReservationSpot != null)
                          ActiveReservationBanner(
                            spotName: 'P${provider.activeReservationSpot}',
                            timeLeft: provider.formattedTime,
                            onCancel: provider.cancelReservation,
                          ),

                        // YENİ EKLENEN: MODERN DASHBOARD EKRANI
                        _StatsRow(provider: provider),

                        const SizedBox(height: 32),
                        _SectionTitle(
                          title: 'Park Yerleri',
                          subtitle: provider.spots.isEmpty
                              ? ''
                              : '${provider.spots.length} yer',
                        ),
                        const SizedBox(height: 12),
                        _SpotGrid(spots: provider.spots),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── App Bar ──────────────────────────────────────────
class _AppBar extends StatelessWidget {
  final ParkingProvider provider;
  const _AppBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isConnected = provider.status == ConnectionStatus.connected;
    return SliverAppBar(
      floating: true,
      backgroundColor: const Color(0xFF0D0F14),
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 9, height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444),
              boxShadow: isConnected
                  ? [BoxShadow(color: const Color(0xFF22C55E).withOpacity(0.6), blurRadius: 6)]
                  : [],
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Akıllı Otopark',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }
}

// ── Bağlantı Durumu Bandı ─────────────────────────────
class _ConnectionBanner extends StatelessWidget {
  final ParkingProvider provider;
  const _ConnectionBanner({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.status == ConnectionStatus.connected) {
      final time = provider.lastUpdated != null
          ? DateFormat('HH:mm:ss').format(provider.lastUpdated!)
          : '—';
      return _Banner(
        color: const Color(0xFF22C55E),
        bgColor: const Color(0xFF22C55E).withOpacity(0.1),
        icon: Icons.wifi,
        text: 'Canlı — Son güncelleme: $time',
      );
    }
    if (provider.status == ConnectionStatus.error) {
      return _Banner(
        color: const Color(0xFFEF4444),
        bgColor: const Color(0xFFEF4444).withOpacity(0.1),
        icon: Icons.wifi_off,
        text: provider.errorMsg,
      );
    }
    return _Banner(
      color: const Color(0xFFF59E0B),
      bgColor: const Color(0xFFF59E0B).withOpacity(0.1),
      icon: Icons.sync,
      text: 'Bağlanılıyor...',
    );
  }
}

class _Banner extends StatelessWidget {
  final Color color, bgColor;
  final IconData icon;
  final String text;
  const _Banner({required this.color, required this.bgColor, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── YENİ: Modern İstatistik Dashboard (Yuvarlak Grafik) ───────────────────────────────
class _StatsRow extends StatelessWidget {
  final ParkingProvider provider;
  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final s = provider.summary;
    final pct = s != null ? s.occupancyRate : 0.0;
    final pctInt = (pct * 100).round();

    return Row(
      children: [
        // Sol Taraf: Modern Yuvarlak Doluluk Grafiği
        Container(
          width: 140,
          height: 140,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2029),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 8,
                  backgroundColor: Colors.white10,
                  // Doluluk %80'in üzerindeyse kırmızı, değilse turuncu renk
                  color: pct > 0.8 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('%$pctInt', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text('Doluluk', style: TextStyle(fontSize: 11, color: Colors.white54)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Sağ Taraf: Hızlı Özet Bilgiler (Boş ve Dolu Kartları)
        Expanded(
          child: Column(
            children: [
              _SmallStatCard(
                label: 'Boş Yer',
                value: '${s?.empty ?? "—"}',
                color: const Color(0xFF22C55E),
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(height: 12),
              _SmallStatCard(
                label: 'Dolu Yer',
                value: '${s?.occupied ?? "—"}',
                color: const Color(0xFFEF4444),
                icon: Icons.directions_car,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;

  const _SmallStatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2029),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Bölüm Başlığı ─────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title, subtitle;
  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        if (subtitle.isNotEmpty)
          Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.4))),
      ],
    );
  }
}

// ── Park Yeri Grid ─────────────────────────────────────
class _SpotGrid extends StatelessWidget {
  final List<ParkingSpot> spots;
  const _SpotGrid({required this.spots});

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_parking_outlined,
                  size: 48, color: Colors.white.withOpacity(0.2)),
              const SizedBox(height: 12),
              Text('Henüz veri yok',
                  style: TextStyle(color: Colors.white.withOpacity(0.4))),
              const SizedBox(height: 4),
              Text('Aşağı kaydırarak yenileyin',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.25))),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:    2,
        crossAxisSpacing:  12,
        mainAxisSpacing:   12,
        childAspectRatio:  1.1,
      ),
      itemCount: spots.length,
      itemBuilder: (_, i) => _SpotCard(spot: spots[i]),
    );
  }
}

// ── Aktif Rezervasyon Geri Sayım Bandı ──────────────────
class ActiveReservationBanner extends StatelessWidget {
  final String spotName;
  final String timeLeft;
  final VoidCallback onCancel;

  const ActiveReservationBanner({
    super.key,
    required this.spotName,
    required this.timeLeft,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: const Color(0xFFF59E0B).withOpacity(0.4), blurRadius: 15, spreadRadius: 2)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AKTİF REZERVASYON', style: TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
              Text('$spotName Ayrıldı', style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.black, size: 24),
              const SizedBox(width: 8),
              Text(
                timeLeft,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onCancel,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.black, size: 18),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

// ── Tek Park Yeri Kartı ve Rezervasyon Penceresi ───────────────────────────────
class _SpotCard extends StatelessWidget {
  final ParkingSpot spot;
  const _SpotCard({required this.spot});

  void _showReservationDialog(BuildContext context, int spotNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2029),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_clock, size: 50, color: Color(0xFFF59E0B)),
            const SizedBox(height: 15),
            Text('P$spotNumber Numaralı Yeri Rezerve Et', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            const Text(
              'Bu park yerini adınıza ayırıyoruz. Yere ulaşıp park etmeniz için 15 dakika süreniz olacak. Gitmezseniz ceza puanı alırsınız. Onaylıyor musunuz?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('İPTAL', style: TextStyle(color: Colors.white54)),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                      Provider.of<ParkingProvider>(context, listen: false).reserveSpot(spotNumber);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('P$spotNumber numaralı yer başarıyla rezerve edildi!'),
                          backgroundColor: const Color(0xFF22C55E),
                        ),
                      );
                    },
                    child: const Text('REZERVE ET', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParkingProvider>(context);
    final isOccupied = spot.isOccupied;
    final isReserved = spot.isReserved || (provider.activeReservationSpot == spot.spotNumber);

    Color color;
    String statusText;
    IconData icon;

    if (isOccupied) {
      color = const Color(0xFFEF4444);
      statusText = 'DOLU';
      icon = Icons.directions_car;
    } else if (isReserved) {
      color = const Color(0xFFF59E0B);
      statusText = 'REZERVE';
      icon = Icons.lock_clock;
    } else {
      color = const Color(0xFF22C55E);
      statusText = 'BOŞ';
      icon = Icons.check_circle_outline;
    }

    final bgColor    = color.withOpacity(0.08);
    final borderClr  = color.withOpacity(0.35);
    final timeStr    = spot.lastUpdated != null
        ? DateFormat('HH:mm').format(spot.lastUpdated!)
        : '';

    return GestureDetector(
      onTap: () {
        final currentProvider = Provider.of<ParkingProvider>(context, listen: false);

        // KURAL: Zaten aktif rezervasyon varsa uyar.
        if (currentProvider.activeReservationSpot != null && currentProvider.activeReservationSpot != spot.spotNumber) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Zaten aktif bir rezervasyonunuz var! Önce onu iptal etmelisiniz.'),
              backgroundColor: Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }

        if (!isOccupied && !isReserved) {
          _showReservationDialog(context, spot.spotNumber);
        } else if (currentProvider.activeReservationSpot != spot.spotNumber) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu yer şu anda uygun değil.'),
              backgroundColor: Color(0xFFEF4444),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
          border: Border.all(color: borderClr, width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'P${spot.spotNumber}',
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const Spacer(),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700,
                color: color, letterSpacing: 0.5,
              ),
            ),
            if (timeStr.isNotEmpty)
              Text(
                timeStr,
                style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4)),
              ),
          ],
        ),
      ),
    );
  }
}