import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'l10n/messages_all.dart';

class DemoLocalizations {
  DemoLocalizations(this.localeName);

  static Future<DemoLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      return DemoLocalizations(localeName);
    });
  }

  static DemoLocalizations of(BuildContext context) {
    return Localizations.of<DemoLocalizations>(context, DemoLocalizations);
  }

  final String localeName;

  String get title {
    return Intl.message(
      'Hello World',
      name: 'title',
      desc: 'Title for the Demo application',
      locale: localeName,
    );
  }

  String get increaseButton {
    return Intl.message(
      'Increase Test',
      name: 'increaseButton',
      desc: 'Title for the button',
      locale: localeName,
    );
  }

  String get anotherButton {
    return Intl.message(
      'anotherButton',
      name: 'anotherButton',
      desc: 'Title for the another button',
      locale: localeName,
    );
  }

  String get starterAppGenericHeadline {
    return Intl.message(
      'Headline',
      name: 'starterAppGenericHeadline',
      desc: 'Generic placeholder for headline in drawer.',
      locale: localeName,
    );
  }

  String get starterAppGenericTitle {
    return Intl.message(
      'Title',
      name: 'starterAppGenericTitle',
      locale: localeName,
    );
  }

  String get starterAppGenericSubtitle {
    return Intl.message(
      'Subtitle',
      name: 'starterAppGenericSubtitle',
      locale: localeName,
    );
  }

  String get starterAppGenericBody {
    return Intl.message(
      'Body',
      name: 'starterAppGenericBody',
      locale: localeName,
    );
  }

  String get starterAppGenericButton {
    return Intl.message(
      'BUTTON',
      name: 'starterAppGenericButton',
      locale: localeName,
    );
  }

  String get starterAppTooltipAdd {
    return Intl.message(
      'Add',
      name: 'starterAppTooltipAdd',
      locale: localeName,
    );
  }

  String get starterAppTooltipFavorite {
    return Intl.message(
      'Favorite',
      name: 'starterAppTooltipFavorite',
      locale: localeName,
    );
  }

  String get starterAppTooltipShare {
    return Intl.message(
      'Share',
      name: 'starterAppTooltipShare',
      locale: localeName,
    );
  }

  String get starterAppTooltipSearch {
    return Intl.message(
      'starterAppTooltipSearch',
      name: 'starterAppTooltipSearch',
      locale: localeName,
    );
  }

  String get starterAppTitle {
    return Intl.message(
      'Starter app',
      name: 'starterAppTitle',
      locale: localeName,
    );
  }

  String starterAppDrawerItem(value) => Intl.message('Item $value',
      name: 'starterAppDrawerItem',
      args: [value],
      locale: localeName,
      examples: const {'value': 1});
}

class DemoLocalizationsDelegate
    extends LocalizationsDelegate<DemoLocalizations> {
  const DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<DemoLocalizations> load(Locale locale) =>
      DemoLocalizations.load(locale);

  @override
  bool shouldReload(DemoLocalizationsDelegate old) => false;
}
