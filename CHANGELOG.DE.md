# Changelog

English: [CHANGELOG.md](CHANGELOG.md)

Alle wichtigen Änderungen an der PrüfungsPilot-App werden in dieser Datei dokumentiert.

### 1.0.12 (2026-03-18)

- CodeQL in einen manuellen Hinweis-Workflow umgestellt, da dieses Repository derzeit aus Flutter-/Dart-Code besteht, den GitHub CodeQL nicht direkt analysiert.
- Den Release-Workflow zu einer manuellen Release-Pipeline umgebaut, damit normale Pushes keine fehlschlagenden Release-Versuche mehr auslösen.
- Versionskonsistenz zwischen `package.json`, `pubspec.yaml` und `VERSION` vor Release-Builds abgesichert.
