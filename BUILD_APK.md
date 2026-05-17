# Cara Build APK & Install di HP Android

## Opsi A: APK Debug (paling cepat, untuk uji di HP sendiri)

Tidak perlu keystore. Cocok untuk testing pribadi.

```powershell
cd "C:\Users\sjatm\OneDrive\Documents\Project\Alpha v0.0.001\xbox_region_store_browser"
flutter pub get
flutter build apk --debug
```

File hasil:

`build\app\outputs\flutter-apk\app-debug.apk`

### Install ke HP via USB

1. Aktifkan **Developer options** + **USB debugging** di HP
2. Colokkan USB, izinkan debugging
3. Jalankan:

```powershell
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

### Install tanpa USB

1. Copy `app-debug.apk` ke HP (Google Drive, WhatsApp, kabel, dll.)
2. Di HP: **Settings → Security** → izinkan **Install unknown apps** untuk File Manager / Chrome
3. Buka file APK → Install

---

## Opsi B: APK Release (lebih ringan, untuk dipakai sehari-hari)

### 1. Buat keystore (sekali saja)

```powershell
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Simpan file `upload-keystore.jks` di folder project (jangan di-commit ke Git).

### 2. Konfigurasi signing

```powershell
copy android\key.properties.example android\key.properties
```

Edit `android\key.properties`:

```properties
storePassword=PASSWORD_KEYSTORE_ANDA
keyPassword=PASSWORD_KEY_ANDA
keyAlias=upload
storeFile=../upload-keystore.jks
```

### 3. Build release

```powershell
flutter build apk --release
```

File hasil:

`build\app\outputs\flutter-apk\app-release.apk`

Atau **App Bundle** untuk Play Store:

```powershell
flutter build appbundle --release
```

---

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| `adb` tidak dikenali | Install [Android SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools) atau gunakan path dari Android Studio |
| Install gagal "App not installed" | Uninstall versi lama dulu, atau pastikan arsitektur HP didukung (build `flutter build apk --split-per-abi` untuk APK lebih kecil per CPU) |
| Build gagal Gradle | `flutter clean` lalu `flutter pub get` lalu build lagi |
| HP tidak terdeteksi | `adb devices` — harus status `device` |

### APK per arsitektur (ukuran lebih kecil)

```powershell
flutter build apk --split-per-abi --release
```

Hasil di `build\app\outputs\flutter-apk\`:

- `app-armeabi-v7a-release.apk` — HP lama 32-bit
- `app-arm64-v8a-release.apk` — kebanyakan HP modern (pakai ini)
- `app-x86_64-release.apk` — emulator

---

## Sebelum rilis publik

- Ganti AdMob ID produksi di `.env` dan `AndroidManifest.xml`
- Tambahkan `google-services.json` untuk Firebase
- Buat produk IAP `remove_ads` di Google Play Console
- Ganti URL privacy policy di app
