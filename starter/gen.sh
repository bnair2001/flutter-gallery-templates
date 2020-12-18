# flutter pub get
flutter pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/demo_localizations.dart
flutter pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/demo_localizations.dart lib/l10n/intl_*.arb
