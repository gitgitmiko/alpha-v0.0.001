# Panduan Setup — Xbox Region Store Browser

## Langkah 1: Flutter

```powershell
cd "xbox_region_store_browser"
flutter create . --org com.xboxregion --project-name xbox_region_store_browser
flutter pub get
```

## Langkah 2: Environment

Salin `.env.example` ke `.env`. Untuk emulator Android dengan backend lokal:

```
USE_BACKEND=true
BACKEND_BASE_URL=http://10.0.2.2:3000
```

## Langkah 3: Firebase (notifikasi)

1. Tambahkan `google-services.json` di `android/app/`
2. Ikuti [FlutterFire](https://firebase.flutter.dev/docs/overview)

Tanpa Firebase, aplikasi tetap berjalan; notifikasi push dinonaktifkan.

## Langkah 4: Play Console

| Item | Nilai |
|------|-------|
| Package | `com.xboxregion.storebrowser` |
| In-app product | `remove_ads` (non-consumable) |
| AdMob App ID | ganti di `AndroidManifest.xml` |

## Langkah 5: Release signing

```powershell
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
copy android\key.properties.example android\key.properties
flutter build appbundle --release
```

## Backend Docker

```powershell
docker compose up --build
```

API health: http://localhost:3000/health

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| API kosong | Coba region US; endpoint Microsoft bisa rate-limit |
| Gradle error | Jalankan `flutter create .` ulang |
| Iklan tidak muncul | Gunakan test Ad Unit ID di `.env` |
