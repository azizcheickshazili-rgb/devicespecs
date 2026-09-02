# DeviceSpecs — Groupe 20

Inspecteur d'informations système en Flutter, avec récupération des données via **platform channels natifs (Kotlin)**.

## Structure du projet

```
devicespecs/
├── lib/
│   └── main.dart              # UI Flutter (appelle le MethodChannel)
├── android/
│   └── app/src/main/kotlin/com/groupe20/devicespecs/
│       └── MainActivity.kt    # Code natif Kotlin (récupère les vraies infos système)
├── test/
│   └── widget_test.dart
└── .github/workflows/
    └── flutter-ci.yml         # Build automatique via GitHub Actions
```

## Comment ça marche (Native Integrations)

1. `lib/main.dart` définit un `MethodChannel` nommé `com.groupe20.devicespecs/system`
2. Quand l'app démarre, Dart appelle `platform.invokeMethod('getDeviceInfo')`
3. Côté Android, `MainActivity.kt` intercepte cet appel et va chercher les vraies infos via les API Android : `Build`, `ActivityManager`, `StatFs`, `BatteryManager`
4. Les résultats reviennent côté Dart sous forme de `Map`, affichés avec des cartes animées (fondu + barres de progression animées)

## Mise en route (workflow phone-only : Termux + ACode + GitHub Actions)

1. Crée un nouveau dépôt Git (ou utilise le dépôt du Groupe 20)
2. Copie tous ces fichiers dedans en conservant l'arborescence exacte
3. Dans Termux :
   ```
   git add .
   git commit -m "Init DeviceSpecs avec platform channels natifs"
   git push
   ```
4. Le workflow GitHub Actions (`.github/workflows/flutter-ci.yml`) se déclenche automatiquement et :
   - installe Flutter
   - analyse le code (`flutter analyze`)
   - exécute les tests
   - build un APK debug (disponible dans l'onglet "Actions" > "Artifacts")

## Prochaines étapes possibles

- Ajouter d'autres infos natives (adresse IP, infos CPU, résolution d'écran)
- Ajouter un thème clair/sombre avec animation de transition
- Ajouter un export des specs en PDF ou en partage texte
