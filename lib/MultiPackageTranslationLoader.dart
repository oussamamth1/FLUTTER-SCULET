import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// A custom translation loader that merges translations from multiple sources
class MultiPackageTranslationLoader extends FileTranslationLoader {
  final List<String> basePaths;

  MultiPackageTranslationLoader({
    required this.basePaths,
    String? fallbackFile,
    bool useCountryCode = false,
  }) : super(
         basePath: basePaths.first, // Required by parent, but we'll override
         fallbackFile: fallbackFile,
         useCountryCode: useCountryCode,
       );

  @override
  Future<Map> load() async {
    final Map<String, dynamic> mergedTranslations = {};

    // Load translations from each package
    for (final basePath in basePaths) {
      try {
        final locale = this.locale;
        final localeName = composeFileName();
        final path = '$basePath/$localeName.json';

        print('📦 Loading translations from: $path');

        final String content = await rootBundle.loadString(path);
        final Map<String, dynamic> translations = jsonDecode(content);

        // Merge translations (later packages override earlier ones if there are conflicts)
        mergedTranslations.addAll(translations);

        print('✅ Loaded ${translations.length} keys from $basePath');
      } catch (e) {
        print('⚠️ Could not load translations from $basePath: $e');
      }
    }

    print('🎉 Total merged translations: ${mergedTranslations.length} keys');
    return mergedTranslations;
  }
}
