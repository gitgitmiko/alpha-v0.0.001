# Xbox Region Store Browser

Aplikasi Flutter Android production-ready untuk menjelajahi Xbox Store lintas region, Game Pass, perbandingan harga, wishlist, pelacakan harga, dan backend opsional.

> **Disclaimer:** Aplikasi ini tidak berafiliasi dengan Microsoft atau Xbox.

## Stack

| Layer | Teknologi |
|-------|-----------|
| Mobile | Flutter (stable), Riverpod, Dio, Material 3 |
| Lokal | Hive, SharedPreferences |
| Iklan | Google Mobile Ads (interstitial) |
| Billing | Google Play (non-consumable `remove_ads`) |
| Push | Firebase Cloud Messaging + local notifications |
| Backend (opsional) | Node.js, Express, TypeScript, PostgreSQL, Redis, Docker |

## Struktur proyek

```
lib/
├── core/           # constants, network, theme, storage, routing
├── domain/         # entities, repository interfaces
├── data/           # models, datasources, mappers, repository impl
├── features/       # home, game_pass, settings, wishlist, compare
├── services/       # ads, billing, notifications, currency, price tracker
└── presentation/   # shared widgets & shell

backend/            # REST API cache + cron
docker-compose.yml
```

## API Microsoft (riset)

| Tujuan | Endpoint |
|--------|----------|
| Detail produk / harga | `GET https://displaycatalog.mp.microsoft.com/v7.0/products?bigIds={ids}&market={market}&languages={locale},neutral` |
| Daftar ID (Deal, dll.) | `GET https://reco-public.rec.mp.microsoft.com/channels/Reco/V8.0/Lists/api/list/Computed/Deal?market={market}&language={locale}&itemType=Game&deviceFamily=Windows.Xbox` |
| Game Pass SIGL | `GET https://catalog.gamepass.com/sigls/v2?id=9ea872a6-2f94-4ea6-b2e3-ff9530b8f35f` |
| Kurs | `GET https://api.exchangerate.host/latest` |

Parameter umum: `market=ID`, `locale=id-ID`, `language=id-ID`

Backend REST (jika `USE_BACKEND=true`):

- `GET /games/deals`
- `GET /games/search?q=`
- `GET /games/:id`
- `GET /compare/:id` → `/games/compare/:id`
- `GET /gamepass`
- `GET /gamepass/prices`
- `GET /regions`
- `POST /wishlist`, `POST /favorites`

## Setup cepat

### Prasyarat

- Flutter SDK stable terbaru
- Android Studio / JDK 17
- Node.js 20+ (backend opsional)

### 1. Inisialisasi Flutter (wajib sekali)

```bash
cd xbox_region_store_browser
flutter create . --org com.xboxregion --project-name xbox_region_store_browser
flutter pub get
```

Perintah `flutter create .` melengkapi file Gradle/wrapper yang belum ada.

### 2. Konfigurasi environment

```bash
cp .env.example .env
```

| Variabel | Deskripsi |
|----------|-----------|
| `USE_BACKEND` | `true` untuk proxy via backend |
| `BACKEND_BASE_URL` | `http://10.0.2.2:3000` (emulator) |
| `ADMOB_*` | Ganti ID produksi AdMob |

### 3. Firebase (opsional, untuk FCM)

1. Buat proyek di [Firebase Console](https://console.firebase.google.com)
2. Tambahkan app Android `com.xboxregion.storebrowser`
3. Unduh `google-services.json` → `android/app/`
4. Jalankan `flutterfire configure` atau tambahkan plugin Gradle

### 4. Google Play Billing

- Buat produk in-app **non-consumable** dengan ID: `remove_ads`
- Harga: Rp20.000 (sesuaikan di Play Console)

### 5. Jalankan aplikasi

```bash
flutter run
```

### 6. Backend (opsional)

```bash
cd backend
cp .env.example .env
npm install
npm run dev
```

Docker:

```bash
docker compose up --build
```

## Build release Android

### Signing

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
cp android/key.properties.example android/key.properties
# Edit key.properties dengan path keystore Anda
```

### APK / App Bundle

```bash
flutter build appbundle --release
# atau
flutter build apk --release
```

Output: `build/app/outputs/`

## Fitur utama

- **Home:** katalog deal, search (debounce + pagination), filter harga/diskon, iklan interstitial (3 search / 1 filter gratis)
- **Game Pass:** katalog region-aware
- **Harga Game Pass:** PC / Core / Standard / Ultimate
- **Settings:** region, tema (light/dark/system), hapus iklan, about
- **Wishlist & Favorit:** Hive lokal, siap sync backend
- **Price tracker + notifikasi** penurunan harga
- **Riwayat harga** lokal
- **Perbandingan region** (ID, TR, AR, US, BR)
- **Konverter mata uang** dengan cache offline

## Package & Play Store

- **Package:** `com.xboxregion.storebrowser`
- **Min SDK:** 24
- **ProGuard:** `android/app/proguard-rules.pro`
- **Privacy policy:** `docs/PRIVACY_POLICY.md` (ganti URL sebelum rilis)
- **Icon:** ganti placeholder di `android/app/src/main/res/mipmap-*`

## Lisensi

Proyek contoh/edukasi. Pastikan kepatuhan ToS Microsoft Store saat produksi.
