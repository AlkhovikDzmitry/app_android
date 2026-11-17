# beltech

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Карта (Google Maps)

Карта станций показывает Google Maps, если задан ключ, иначе — OpenStreetMap
(flutter_map) без ключа. Чтобы карта отображалась одинаково на Android и iOS,
нужен один и тот же ключ в двух местах сборки:

- Android (нативный ключ для `GoogleMap`): переменная окружения
  `GOOGLE_MAPS_API_KEY` или `android/gradle.properties` — подставляется в
  манифест через `manifestPlaceholders`.
- Dart (выбор Google/OSM): `--dart-define=GOOGLE_MAPS_API_KEY=...`.
- iOS (нативный ключ): `ios/Flutter/GoogleMaps.xcconfig` (в `.gitignore`,
  шаблон — `GoogleMaps.xcconfig.example`) → `Info.plist` (`GMSApiKey`) →
  `GMSServices.provideAPIKey` в `AppDelegate.swift`.

Пример сборки:

```
flutter build apk --release --dart-define=GOOGLE_MAPS_API_KEY=<ключ-Android>
flutter build ios --release --dart-define=GOOGLE_MAPS_API_KEY=<ключ-iOS>
```

Для iOS нужен отдельный ключ, ограниченный по bundle id `by.gto.beltech`, а
минимальная версия iOS поднята до 14.0 (требование Google Maps SDK).
