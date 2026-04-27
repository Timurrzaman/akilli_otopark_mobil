# 📱 Akıllı Otopark Mobil Uygulaması

Bu uygulama, IoT tabanlı Akıllı Otopark Sistemi'nin kullanıcı arayüzüdür. **Flutter** ve **Dart** kullanılarak geliştirilen bu uygulama, sürücülerin otopark doluluk durumunu gerçek zamanlı olarak izlemelerini, boş yer bulmalarını ve park süreçlerini yönetmelerini sağlar.



## ✨ Öne Çıkan Özellikler

* **Anlık Doluluk Haritası:** Django sunucusundan gelen verileri (örn: `10110`) saniyeler içinde görsel bir haritaya dönüştürür.
* **Modern Tasarım:** Karanlık tema (Dark Mode) desteği ve kullanıcı dostu yuvarlak hatlı (rounded) grafik arayüzü.
* **Kullanıcı Kaydı:** Plaka ve isim bilgilerini `SharedPreferences` ile yerel hafızada tutarak hızlı giriş imkanı sunar.
* **Gerçek Zamanlı Senkronizasyon:** Sunucudaki her veri değişikliğini anında arayüze yansıtır.

## 🛠️ Teknik Altyapı

* **Framework:** Flutter SDK
* **Dil:** Dart
* **Veri Yönetimi:** `Provider` (State Management)
* **Ağ İletişimi:** `http` paketi üzerinden REST API entegrasyonu
* **Yerel Depolama:** `shared_preferences`

## 📂 Klasör Yapısı

```text
├── assets/             # Uygulama logoları ve görseller
├── lib/                # Uygulama kaynak kodları
│   ├── models/         # Park yeri ve Kullanıcı veri modelleri
│   ├── screens/        # Giriş, Harita ve Profil ekranları
│   ├── services/       # API bağlantı ve veri çekme servisleri
│   └── main.dart       # Uygulama başlangıç dosyası
└── pubspec.yaml        # Paket bağımlılıkları ve ayarlar
