# CMS2026 Mobile Template

Data-driven Flutter mobile application template for the CMS2026 Mobile App Builder platform.

## How It Works

This app is a **shell** that reads its configuration from `assets/config/app_config.json` and dynamically:
- Builds the navigation menu from CMS API (`GET /mobile/menu`)
- Loads content from CMS API (news, pages, blog, gallery, FAQ, events, contact)
- Applies branding (colors, logo, fonts) from configuration
- Supports RTL languages (Arabic) and LTR (English)
- Integrates AI semantic search and content recommendations

## Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS
flutter build ipa --release
```

## Configuration

Edit `assets/config/app_config.json` — or let the CMS Mobile App Builder inject it at build time.

## Tech Stack

- Flutter 3+ / Dart 3
- GoRouter (navigation)
- Dio (API client)
- Hive (offline cache)
- Firebase Cloud Messaging (push notifications)
- CachedNetworkImage, flutter_html
