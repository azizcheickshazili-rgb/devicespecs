# Intégration du module Dashboard — DeviceSpecs

Ce module reproduit fidèlement la maquette `tableau_de_bord_santé_système_mode_sombre`
(thème noir `#010101` / cartes `#1E1E1E`, typographies Geist + JetBrains Mono,
anneaux de progression, sparkline CPU en direct, carte réseau, contrôles
diagnostic, nav du bas).

**Important** : quelques libellés de la maquette étaient des exemples visuels
non réels ("Tensor G3", "UFS 4.0", "Wi-Fi 7", fréquences par cluster
détaillées, latence fixe "14 ms"…). Ces informations précises ne sont pas
exposées par l'API Android publique sans root : je les ai remplacées par des
libellés génériques (ex. "Stockage interne", "Fréquence CPU") backés par de
**vraies** valeurs mesurées (batterie, RAM, swap, charge CPU, fréquences
sysfs, débit Wi-Fi, latence TCP réelle vers la passerelle). Le principe
"jamais de valeur inventée" du README du groupe est respecté.

## 1. Dépendance à ajouter

Dans `pubspec.yaml` du projet, ajoute :

```yaml
dependencies:
  google_fonts: ^6.2.1
```

Puis `flutter pub get`.

## 2. Fichiers Dart à copier

```
lib/features/dashboard/presentation/theme/dashboard_colors.dart
lib/features/dashboard/presentation/pages/dashboard_page.dart
lib/features/dashboard/presentation/view_models/dashboard_view_model.dart
lib/features/dashboard/presentation/widgets/dashboard_ring.dart
lib/features/dashboard/presentation/widgets/dashboard_stat_row.dart
lib/features/dashboard/presentation/widgets/dashboard_bottom_nav.dart
lib/features/dashboard/presentation/widgets/diagnostic_controls.dart
lib/features/dashboard/presentation/widgets/theme_export.dart
lib/features/dashboard/presentation/widgets/device_summary_card.dart
lib/features/dashboard/presentation/widgets/battery_card.dart
lib/features/dashboard/presentation/widgets/memory_card.dart
lib/features/dashboard/presentation/widgets/storage_card.dart
lib/features/dashboard/presentation/widgets/cpu_card.dart
lib/features/dashboard/presentation/widgets/network_card.dart
lib/services/native/device_platform_service.dart
lib/services/native/battery_platform_service.dart
lib/services/native/storage_platform_service.dart
lib/services/native/system_platform_service.dart
```

## 3. Fichier Kotlin

Le fichier `android/app/src/main/kotlin/com/devicespecs/device_specs/MainActivity.kt`
**doit être adapté avant d'être copié** :

1. Ouvre `android/app/build.gradle` du dépôt du groupe et repère la ligne
   `applicationId "..."`.
2. Renomme le `package` en haut du fichier Kotlin pour qu'il corresponde
   exactement à cet `applicationId`.
3. Place le fichier dans le dossier
   `android/app/src/main/kotlin/<chemin_correspondant_au_package>/`.
4. Si un `MainActivity.kt` existe déjà (ex. pour Login/Profil), **fusionne**
   `configureFlutterEngine` et les méthodes privées dans le fichier existant
   plutôt que de l'écraser.

### Permissions à ajouter dans `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
```

Sans `INTERNET`, la mesure de latence réseau échouera silencieusement
(retournera "Indisponible", pas de crash).

Note : sur certaines versions d'Android, le SSID Wi-Fi n'est renvoyé que si
la permission de localisation est accordée — sans elle, `getNetworkInfo`
retombe proprement sur "Indisponible" plutôt que de planter.

## 4. Brancher la page dans le routeur

Dans `app/router/app_router.dart`, fais pointer la route `/dashboard` vers
`DashboardPage`, en lui passant `onViewSystemInfo` / `onOpenProfile` pour
la nav du bas, et éventuellement `profileImageUrl`.

## 5. Vérifications avant de pousser

```
flutter analyze
dart format .
flutter test
```

Commit conseillé (convention du groupe) :

```
feat: add dashboard page matching mockup with real native metrics
```
