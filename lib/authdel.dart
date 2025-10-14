import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';

class AuthI18n {
  static final _delegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
      basePath: "packages/zenify_auth/assets/flutter_i18n",
      fallbackFile: "en",
      useCountryCode: false,
    ),
  );

  static String translate(BuildContext context, String key) {
    return FlutterI18n.translate(context, key);
  }
}
