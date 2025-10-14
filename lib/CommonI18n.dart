import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';

class CommonI18n {
  static final _delegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
      basePath: "packages/zt_common_i18n/assets/flutter_i18n",
      fallbackFile: "en",
      useCountryCode: false,
    ),
  );

  static String translate(BuildContext context, String key) {
    // This is problematic because FlutterI18n uses a global key
    // You'd need to implement your own translation loading
    return FlutterI18n.translate(context, key);
  }
}
