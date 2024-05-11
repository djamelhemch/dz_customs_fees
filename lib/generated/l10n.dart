// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `DZ Customs Calculator`
  String get title {
    return Intl.message(
      'DZ Customs Calculator',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Enter Goods Value`
  String get enterGoodsValue {
    return Intl.message(
      'Enter Goods Value',
      name: 'enterGoodsValue',
      desc: '',
      args: [],
    );
  }

  /// `Calculate`
  String get calculate {
    return Intl.message(
      'Calculate',
      name: 'calculate',
      desc: '',
      args: [],
    );
  }

  /// `Currency`
  String get currency {
    return Intl.message(
      'Currency',
      name: 'currency',
      desc: '',
      args: [],
    );
  }

  /// `Customs Duty`
  String get customsDuty {
    return Intl.message(
      'Customs Duty',
      name: 'customsDuty',
      desc: '',
      args: [],
    );
  }

  /// `VAT`
  String get vat {
    return Intl.message(
      'VAT',
      name: 'vat',
      desc: '',
      args: [],
    );
  }

  /// `Total Fees`
  String get totalFees {
    return Intl.message(
      'Total Fees',
      name: 'totalFees',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred`
  String get errorOccurred {
    return Intl.message(
      'Error occurred',
      name: 'errorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load exchange rate`
  String get failedToLoadExchangeRate {
    return Intl.message(
      'Failed to load exchange rate',
      name: 'failedToLoadExchangeRate',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
