import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zenifytrip_guide/theme.dart';

enum Environment { dev, prod, sunshine, tunisie, zenify }

abstract class AppEnvironment {
  static late String baseApiUrl;
  static late String title;
  static late bool showconversation;
  static late String imagePath;
  static late String imagePathpdf;
  static late String AndroidLink;
  static late String IosLink;
  static late Color primarySwatch;
  static late Color primary;
  static late Color primarySwatchlite;
  static late Environment _environment;
  static late ElevatedButtonThemeData elevatedButtonTheme;
  static late CardTheme cardthemeDark;
  static late CardTheme cardthemelite;
  static late FloatingActionButtonThemeData floatingActionButtonTheme;
  static ThemeData get lightTheme => ThemeHelper.getLightTheme(environment);
  static Environment get environment => _environment;

  static setupEnv(Environment env) {
    _environment = env;

    // Debug: Print what dart-define values are available
    if (kDebugMode) {
      print('=== Environment Setup Debug ===');
      print('Environment: $env');
      print(
        'API_URL from dart-define: "${const String.fromEnvironment('API_URL', defaultValue: 'NOT_SET')}"',
      );
      print(
        'APIUrlTUNISIA from dart-define: "${const String.fromEnvironment('APIUrlTUNISIA', defaultValue: 'NOT_SET')}"',
      );
    }

    switch (env) {
      case Environment.prod:
        {
          showconversation = false;
          baseApiUrl = 'https://api.staging.zenifytrip.com';
          _setupCommonSunshineConfig();
          break;
        }
      case Environment.zenify:
        {
          showconversation = false;
          baseApiUrl = 'https://api.zenifytrip.com';
          //   baseApiUrl = 'https://api.staging.zenifytrip.com';

          //https://api.tunisiepromo.com/
          title = 'ZenifyTip';
          imagePath = "assets/icon/zenify.png"; // Sunshine URL';
          primarySwatch = const Color.fromARGB(255, 190, 137, 22);
          primarySwatchlite = Color.fromARGB(255, 235, 95, 82);
          primary = const Color.fromARGB(255, 1, 129, 67);
          floatingActionButtonTheme = FloatingActionButtonThemeData(
            backgroundColor: const Color.fromARGB(
              255,
              1,
              129,
              67,
            ), // Background color of the FAB
            foregroundColor: Colors.white, // Icon color
            elevation: 4.0, // Shadow elevation
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Custom shape
            ),
          );
          cardthemeDark = CardTheme(color: Color.fromARGB(255, 233, 181, 11));
          cardthemelite = CardTheme(color: Color.fromRGBO(243, 235, 240, 1));
          elevatedButtonTheme = ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 8.0,
              shadowColor: const Color.fromARGB(255, 2, 197, 80),
              backgroundColor: const Color.fromARGB(255, 203, 163, 110),
              disabledBackgroundColor: const Color.fromARGB(
                255,
                119,
                183,
                0,
              ).withOpacity(0.4),
              disabledForegroundColor: Colors.deepOrange,
            ),
          );
          break;

          // _setupCommonSunshineConfig();
          // break;
        }
      case Environment.dev:
        {
          // baseApiUrl = '';
          showconversation = false;
          const apiUrlFromDefine = String.fromEnvironment(
            'API_URL',
            defaultValue: '',
          );

          if (kDebugMode) {
            print('Raw API_URL value: "$apiUrlFromDefine"');
            print('API_URL isEmpty: ${apiUrlFromDefine.isEmpty}');
            print('API_URL length: ${apiUrlFromDefine.length}');
          }

          if (apiUrlFromDefine.isEmpty) {
            // Use default if not provided via dart-define
            baseApiUrl = 'https://api.staging.zenifytrip.com';
            if (kDebugMode) {
              print(
                'WARNING: API_URL not provided via --dart-define, using default: $baseApiUrl',
              );
            }
          } else {
            baseApiUrl = apiUrlFromDefine;
            if (kDebugMode) {
              print('Using API_URL from dart-define: $baseApiUrl');
            }
          }

          // Ensure the URL doesn't end with a slash
          if (baseApiUrl.endsWith('/')) {
            baseApiUrl = baseApiUrl.substring(0, baseApiUrl.length - 1);
            if (kDebugMode) {
              print('Removed trailing slash from baseApiUrl: $baseApiUrl');
            }
          }

          if (kDebugMode) {
            print('Final baseApiUrl for sunshine: "$baseApiUrl"');
          }
          _setupCommonSunshineConfig();
          break;
        }
      case Environment.sunshine:
        {
          showconversation = false;

          // Get API URL from dart-define with fallback
          const apiUrlFromDefine = String.fromEnvironment(
            'API_URL',
            defaultValue: '',
          );

          if (kDebugMode) {
            print('Raw API_URL value: "$apiUrlFromDefine"');
            print('API_URL isEmpty: ${apiUrlFromDefine.isEmpty}');
            print('API_URL length: ${apiUrlFromDefine.length}');
          }

          if (apiUrlFromDefine.isEmpty) {
            // Use default if not provided via dart-define
            //  baseApiUrl = 'http://192.168.213.213:3000';
            baseApiUrl = 'https://api.sunshinevacances.net';
            if (kDebugMode) {
              print(
                'WARNING: API_URL not provided via --dart-define, using default: $baseApiUrl',
              );
            }
          } else {
            baseApiUrl = apiUrlFromDefine;
            if (kDebugMode) {
              print('Using API_URL from dart-define: $baseApiUrl');
            }
          }

          // Ensure the URL doesn't end with a slash
          if (baseApiUrl.endsWith('/')) {
            baseApiUrl = baseApiUrl.substring(0, baseApiUrl.length - 1);
            if (kDebugMode) {
              print('Removed trailing slash from baseApiUrl: $baseApiUrl');
            }
          }

          if (kDebugMode) {
            print('Final baseApiUrl for sunshine: "$baseApiUrl"');
          }

          _setupCommonSunshineConfig();
          break;
        }
      case Environment.tunisie:
        {
          const apiUrlFromDefine = String.fromEnvironment('API_URL');

          if (apiUrlFromDefine.isEmpty) {
            baseApiUrl = 'https://api.staging.zenifytrip.com';
            if (kDebugMode) {
              print(
                'WARNING: APIUrlTUNISIA not provided via --dart-define, using default: $baseApiUrl',
              );
            }
          } else {
            baseApiUrl = apiUrlFromDefine;
            if (kDebugMode) {
              print('Using APIUrlTUNISIA from dart-define: $baseApiUrl');
            }
          }

          AndroidLink = const String.fromEnvironment(
            'ANDROID_LINK',
            defaultValue:
                'https://play.google.com/store/apps/details?id=com.zenify_app.tunisie',
          );

          IosLink = const String.fromEnvironment(
            'IOS_LINK',
            defaultValue:
                'https://apps.apple.com/us/app/shg-guide/id6736649921',
          );

          title = const String.fromEnvironment(
            'APP_TITLE',
            defaultValue: 'T U N I S I E P R O M O',
          );

          imagePath = const String.fromEnvironment(
            'IMAGE_PATH',
            defaultValue: 'assets/icon/tunisie/TG.jpeg',
          );

          // Parse boolean from string
          showconversation =
              const String.fromEnvironment(
                'SHOW_CONVERSATION',
                defaultValue: 'false',
              ).toLowerCase() ==
              'true';

          // Parse colors from hex strings (format: 0xFFRRGGBB or RRGGBB)
          primarySwatchlite = _parseColor(
            const String.fromEnvironment(
              'PRIMARY_SWATCH_LITE',
              defaultValue: '0xFF0E8BFF',
            ),
            const Color.fromARGB(255, 14, 139, 255),
          );

          primarySwatch = _parseColor(
            const String.fromEnvironment(
              'PRIMARY_SWATCH',
              defaultValue: '0xFFFF8800',
            ),
            const Color.fromARGB(255, 255, 136, 0),
          );

          primary = _parseColor(
            const String.fromEnvironment(
              'PRIMARY_COLOR',
              defaultValue: '0xFF1E03EB',
            ),
            const Color.fromARGB(255, 30, 3, 235),
          );

          // FloatingActionButton colors
          Color fabBackgroundColor = _parseColor(
            const String.fromEnvironment(
              'FAB_BACKGROUND_COLOR',
              defaultValue: '0xFF185FFA',
            ),
            const Color.fromARGB(255, 24, 95, 250),
          );

          Color fabForegroundColor = _parseColor(
            const String.fromEnvironment(
              'FAB_FOREGROUND_COLOR',
              defaultValue: '0xFFFFFFFF',
            ),
            Colors.white,
          );

          floatingActionButtonTheme = FloatingActionButtonThemeData(
            backgroundColor: fabBackgroundColor,
            foregroundColor: fabForegroundColor,
            elevation:
                double.tryParse(
                  const String.fromEnvironment(
                    'FAB_ELEVATION',
                    defaultValue: '4.0',
                  ),
                ) ??
                4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                double.tryParse(
                      const String.fromEnvironment(
                        'FAB_BORDER_RADIUS',
                        defaultValue: '12.0',
                      ),
                    ) ??
                    12.0,
              ),
            ),
          );

          // Card theme colors
          Color cardDarkColor = _parseColor(
            const String.fromEnvironment(
              'CARD_DARK_COLOR',
              defaultValue: '0xFFE9B50B',
            ),
            const Color.fromARGB(255, 233, 181, 11),
          );

          Color cardLiteColor = _parseColor(
            const String.fromEnvironment(
              'CARD_LITE_COLOR',
              defaultValue: '0xFFF3EBF0',
            ),
            const Color.fromRGBO(243, 235, 240, 1),
          );

          cardthemeDark = CardTheme(color: cardDarkColor);
          cardthemelite = CardTheme(color: cardLiteColor);

          // ElevatedButton colors
          Color buttonBackgroundColor = _parseColor(
            const String.fromEnvironment(
              'BUTTON_BACKGROUND_COLOR',
              defaultValue: '0xFF2568FA',
            ),
            const Color.fromARGB(255, 37, 104, 250),
          );

          Color buttonShadowColor = _parseColor(
            const String.fromEnvironment(
              'BUTTON_SHADOW_COLOR',
              defaultValue: '0xFFEB6B03',
            ),
            const Color.fromARGB(255, 235, 107, 3),
          );

          elevatedButtonTheme = ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation:
                  double.tryParse(
                    const String.fromEnvironment(
                      'BUTTON_ELEVATION',
                      defaultValue: '8.0',
                    ),
                  ) ??
                  8.0,
              shadowColor: buttonShadowColor,
              backgroundColor: buttonBackgroundColor,
              disabledBackgroundColor: Colors.deepOrange.withOpacity(0.4),
              disabledForegroundColor: Colors.deepOrange,
            ),
          );

          if (kDebugMode) {
            print('=== Tunisie Environment Configuration ===');
            print('API_URL: $baseApiUrl');
            print('ANDROID_LINK: $AndroidLink');
            print('IOS_LINK: $IosLink');
            print('APP_TITLE: $title');
            print('IMAGE_PATH: $imagePath');
            print('SHOW_CONVERSATION: $showconversation');
            print('==========================================');
          }

          // AndroidLink = "https://play.google.com/store/apps/details?id=com.zenify_app.tunisie";
          // IosLink = "https://apps.apple.com/us/app/shg-guide/id6736649921";
          // title = 'T U N I S I E P R O M O';
          // showconversation = false;
          // imagePath = "assets/icon/tunisie/TG.jpeg";
          // primarySwatchlite = const Color.fromARGB(255, 14, 139, 255);
          // primarySwatch = const Color.fromARGB(255, 255, 136, 0);
          // primary = const Color.fromARGB(255, 30, 3, 235);

          // floatingActionButtonTheme = FloatingActionButtonThemeData(
          //   backgroundColor: const Color.fromARGB(255, 24, 95, 250),
          //   foregroundColor: Colors.white,
          //   elevation: 4.0,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          // );
          // cardthemeDark = CardTheme(
          //   color: Color.fromARGB(255, 233, 181, 11),
          // );
          // cardthemelite = CardTheme(color: Color.fromRGBO(243, 235, 240, 1));
          // elevatedButtonTheme = ElevatedButtonThemeData(
          //   style: ElevatedButton.styleFrom(
          //       elevation: 8.0,
          //       shadowColor: const Color.fromARGB(255, 235, 107, 3),
          //       backgroundColor: const Color.fromARGB(255, 37, 104, 250),
          //       disabledBackgroundColor: Colors.deepOrange.withOpacity(0.4),
          //       disabledForegroundColor: Colors.deepOrange),
          // );
          break;
        }
    }

    // Final debug output
    if (kDebugMode) {
      print('Final baseApiUrl: "$baseApiUrl"');
      print('baseApiUrl isEmpty: ${baseApiUrl.isEmpty}');
      print('baseApiUrl length: ${baseApiUrl.length}');
      print('=== End Environment Setup Debug ===');
    }

    // Validate the URL
    _validateApiUrl();
  }

  static Color _parseColor(String colorString, Color fallback) {
    try {
      // Remove any whitespace
      colorString = colorString.trim();

      // Handle hex format with 0x prefix
      if (colorString.startsWith('0x') || colorString.startsWith('0X')) {
        int colorValue = int.parse(colorString, radix: 16);
        return Color(colorValue);
      }

      // Handle hex format without 0x prefix (assume RRGGBB and add alpha)
      if (colorString.length == 6) {
        int colorValue = int.parse('FF$colorString', radix: 16);
        return Color(colorValue);
      }

      // Handle hex format without 0x prefix (assume AARRGGBB)
      if (colorString.length == 8) {
        int colorValue = int.parse(colorString, radix: 16);
        return Color(colorValue);
      }

      if (kDebugMode) {
        print('Warning: Could not parse color "$colorString", using fallback');
      }
      return fallback;
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing color "$colorString": $e, using fallback');
      }
      return fallback;
    }
  }

  static void _setupCommonTunisieConfig() {
    // API URL
    // const apiUrlFromDefine = String.fromEnvironment('API_URL');
    // if (apiUrlFromDefine.isEmpty) {
    //   baseApiUrl = 'https://api.tunisiepromo.com';
    //   if (kDebugMode) {
    //     print(
    //         'WARNING: APIUrlTUNISIA not provided via --dart-define, using default: $baseApiUrl');
    //   }
    // } else {
    //   baseApiUrl = apiUrlFromDefine;
    //   if (kDebugMode) {
    //     print('Using APIUrlTUNISIA from dart-define: $baseApiUrl');
    //   }
    // }

    // Store links
    AndroidLink = const String.fromEnvironment(
      'ANDROID_LINK',
      defaultValue:
          'https://play.google.com/store/apps/details?id=com.zenify_app.tunisie',
    );

    IosLink = const String.fromEnvironment(
      'IOS_LINK',
      defaultValue: 'https://apps.apple.com/us/app/shg-guide/id6736649921',
    );

    // App title & branding
    title = const String.fromEnvironment(
      'APP_TITLE',
      defaultValue: 'T U N I S I E P R O M O',
    );

    imagePath = const String.fromEnvironment(
      'IMAGE_PATH',
      defaultValue: 'assets/icon/tunisie/TG.jpeg',
    );

    // Conversation toggle
    showconversation =
        const String.fromEnvironment(
          'SHOW_CONVERSATION',
          defaultValue: 'false',
        ).toLowerCase() ==
        'true';

    // Colors
    primarySwatchlite = _parseColor(
      const String.fromEnvironment(
        'PRIMARY_SWATCH_LITE',
        defaultValue: '0xFF0E8BFF',
      ),
      const Color.fromARGB(255, 14, 139, 255),
    );

    primarySwatch = _parseColor(
      const String.fromEnvironment(
        'PRIMARY_SWATCH',
        defaultValue: '0xFFFF8800',
      ),
      const Color.fromARGB(255, 255, 136, 0),
    );

    primary = _parseColor(
      const String.fromEnvironment('PRIMARY_COLOR', defaultValue: '0xFF1E03EB'),
      const Color.fromARGB(255, 30, 3, 235),
    );

    // FloatingActionButton colors
    Color fabBackgroundColor = _parseColor(
      const String.fromEnvironment(
        'FAB_BACKGROUND_COLOR',
        defaultValue: '0xFF185FFA',
      ),
      const Color.fromARGB(255, 24, 95, 250),
    );

    Color fabForegroundColor = _parseColor(
      const String.fromEnvironment(
        'FAB_FOREGROUND_COLOR',
        defaultValue: '0xFFFFFFFF',
      ),
      Colors.white,
    );

    floatingActionButtonTheme = FloatingActionButtonThemeData(
      backgroundColor: fabBackgroundColor,
      foregroundColor: fabForegroundColor,
      elevation:
          double.tryParse(
            const String.fromEnvironment('FAB_ELEVATION', defaultValue: '4.0'),
          ) ??
          4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          double.tryParse(
                const String.fromEnvironment(
                  'FAB_BORDER_RADIUS',
                  defaultValue: '12.0',
                ),
              ) ??
              12.0,
        ),
      ),
    );

    // Card theme colors
    Color cardDarkColor = _parseColor(
      const String.fromEnvironment(
        'CARD_DARK_COLOR',
        defaultValue: '0xFFE9B50B',
      ),
      const Color.fromARGB(255, 233, 181, 11),
    );

    Color cardLiteColor = _parseColor(
      const String.fromEnvironment(
        'CARD_LITE_COLOR',
        defaultValue: '0xFFF3EBF0',
      ),
      const Color.fromRGBO(243, 235, 240, 1),
    );

    cardthemeDark = CardTheme(color: cardDarkColor);
    cardthemelite = CardTheme(color: cardLiteColor);

    // ElevatedButton colors
    Color buttonBackgroundColor = _parseColor(
      const String.fromEnvironment(
        'BUTTON_BACKGROUND_COLOR',
        defaultValue: '0xFF2568FA',
      ),
      const Color.fromARGB(255, 37, 104, 250),
    );

    Color buttonShadowColor = _parseColor(
      const String.fromEnvironment(
        'BUTTON_SHADOW_COLOR',
        defaultValue: '0xFFEB6B03',
      ),
      const Color.fromARGB(255, 235, 107, 3),
    );

    elevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation:
            double.tryParse(
              const String.fromEnvironment(
                'BUTTON_ELEVATION',
                defaultValue: '8.0',
              ),
            ) ??
            8.0,
        shadowColor: buttonShadowColor,
        backgroundColor: buttonBackgroundColor,
        disabledBackgroundColor: Colors.deepOrange.withOpacity(0.4),
        disabledForegroundColor: Colors.deepOrange,
      ),
    );

    // Debug log
    if (kDebugMode) {
      print('=== Tunisie Environment Configuration ===');
      print('API_URL: $baseApiUrl');
      print('ANDROID_LINK: $AndroidLink');
      print('IOS_LINK: $IosLink');
      print('APP_TITLE: $title');
      print('IMAGE_PATH: $imagePath');
      print('SHOW_CONVERSATION: $showconversation');
      print('==========================================');
    }
  }

  static void _setupCommonZenifyConfig() {
    showconversation = false;

    // API URL
    baseApiUrl = const String.fromEnvironment(
      'API_URL',
      defaultValue: 'https://api.zenifytrip.com',
    );
    // baseApiUrl = 'https://api.staging.zenifytrip.com'; // Uncomment for staging

    // App title & branding
    title = const String.fromEnvironment(
      'APP_TITLE',
      defaultValue: 'S T A G I N G',
    );

    imagePath = const String.fromEnvironment(
      'IMAGE_PATH',
      defaultValue: 'assets/icon/zenify.png',
    );

    // Colors
    primarySwatch = _parseColor(
      const String.fromEnvironment(
        'PRIMARY_SWATCH',
        defaultValue: '0xFFBE8916',
      ),
      const Color.fromARGB(255, 190, 137, 22),
    );

    primarySwatchlite = _parseColor(
      const String.fromEnvironment(
        'PRIMARY_SWATCH_LITE',
        defaultValue: '0xFFEB5F52',
      ),
      const Color.fromARGB(255, 235, 95, 82),
    );

    primary = _parseColor(
      const String.fromEnvironment('PRIMARY_COLOR', defaultValue: '0xFFFF6912'),
      const Color.fromARGB(255, 255, 105, 18),
    );

    // FloatingActionButton
    floatingActionButtonTheme = FloatingActionButtonThemeData(
      backgroundColor: _parseColor(
        const String.fromEnvironment(
          'FAB_BACKGROUND_COLOR',
          defaultValue: '0xFFA502C5',
        ),
        const Color.fromARGB(255, 165, 2, 197),
      ),
      foregroundColor: _parseColor(
        const String.fromEnvironment(
          'FAB_FOREGROUND_COLOR',
          defaultValue: '0xFFFFFFFF',
        ),
        Colors.white,
      ),
      elevation:
          double.tryParse(
            const String.fromEnvironment('FAB_ELEVATION', defaultValue: '4.0'),
          ) ??
          4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          double.tryParse(
                const String.fromEnvironment(
                  'FAB_BORDER_RADIUS',
                  defaultValue: '12.0',
                ),
              ) ??
              12.0,
        ),
      ),
    );

    // Card Themes
    Color cardDarkColor = _parseColor(
      const String.fromEnvironment(
        'CARD_DARK_COLOR',
        defaultValue: '0xFFE9B50B',
      ),
      const Color.fromARGB(255, 233, 181, 11),
    );

    Color cardLiteColor = _parseColor(
      const String.fromEnvironment(
        'CARD_LITE_COLOR',
        defaultValue: '0xFFF3EBF0',
      ),
      const Color.fromRGBO(243, 235, 240, 1),
    );

    cardthemeDark = CardTheme(color: cardDarkColor);
    cardthemelite = CardTheme(color: cardLiteColor);

    // ElevatedButton Theme
    Color buttonBackgroundColor = _parseColor(
      const String.fromEnvironment(
        'BUTTON_BACKGROUND_COLOR',
        defaultValue: '0xFFCB9F6E',
      ),
      const Color.fromARGB(255, 203, 163, 110),
    );

    Color buttonShadowColor = _parseColor(
      const String.fromEnvironment(
        'BUTTON_SHADOW_COLOR',
        defaultValue: '0xFF01226B',
      ),
      const Color.fromARGB(255, 1, 34, 107),
    );

    elevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation:
            double.tryParse(
              const String.fromEnvironment(
                'BUTTON_ELEVATION',
                defaultValue: '8.0',
              ),
            ) ??
            8.0,
        shadowColor: buttonShadowColor,
        backgroundColor: buttonBackgroundColor,
        disabledBackgroundColor: Colors.deepOrange.withOpacity(0.4),
        disabledForegroundColor: Colors.deepOrange,
      ),
    );

    // Debug log
    if (kDebugMode) {
      print('=== Zenify Environment Configuration ===');
      print('API_URL: $baseApiUrl');
      print('APP_TITLE: $title');
      print('IMAGE_PATH: $imagePath');
      print('SHOW_CONVERSATION: $showconversation');
      print('========================================');
    }
  }

  static void _setupCommonSunshineConfig() {
    imagePath = const String.fromEnvironment(
      'IMAGE_PATH',
      defaultValue: 'assets/sunshineLogo.png',
    );

    imagePathpdf = const String.fromEnvironment(
      'IMAGE_PATH_PDF',
      defaultValue: 'assets/va.png',
    );

    AndroidLink = const String.fromEnvironment(
      'ANDROID_LINK',
      defaultValue:
          'https://play.google.com/store/apps/details?id=com.zenify_app',
    );

    IosLink = const String.fromEnvironment(
      'IOS_LINK',
      defaultValue: 'https://apps.apple.com/us/app/shg-guide/id6736649921',
    );

    title = const String.fromEnvironment(
      'APP_TITLE',
      defaultValue: 'S u n S h i n e ',
    );

    // Parse boolean from string
    showconversation =
        const String.fromEnvironment(
          'SHOW_CONVERSATION',
          defaultValue: 'false',
        ).toLowerCase() ==
        'true';

    // Parse colors from hex strings
    primarySwatch = _parseColor(
      const String.fromEnvironment(
        'PRIMARY_SWATCH',
        defaultValue: '0xFFEEA804',
      ),
      const Color.fromARGB(255, 238, 168, 4),
    );

    primarySwatchlite = _parseColor(
      const String.fromEnvironment(
        'PRIMARY_SWATCH_LITE',
        defaultValue: '0xFFEB5F52',
      ),
      const Color(0xFFEB5F52),
    );

    primary = _parseColor(
      const String.fromEnvironment('PRIMARY_COLOR', defaultValue: '0xFFFF6912'),
      const Color.fromARGB(255, 255, 105, 18),
    );

    // FloatingActionButton colors
    Color fabBackgroundColor = _parseColor(
      const String.fromEnvironment(
        'FAB_BACKGROUND_COLOR',
        defaultValue: '0xFFF34A08',
      ),
      const Color.fromARGB(255, 243, 74, 8),
    );

    Color fabForegroundColor = _parseColor(
      const String.fromEnvironment(
        'FAB_FOREGROUND_COLOR',
        defaultValue: '0xFFFFFFFF',
      ),
      Colors.white,
    );

    // Card theme colors
    Color cardDarkColor = _parseColor(
      const String.fromEnvironment(
        'CARD_DARK_COLOR',
        defaultValue: '0xFFE9B50B',
      ),
      const Color.fromARGB(255, 233, 181, 11),
    );

    Color cardLiteColor = _parseColor(
      const String.fromEnvironment(
        'CARD_LITE_COLOR',
        defaultValue: '0xFFF3EBF0',
      ),
      const Color.fromRGBO(243, 235, 240, 1),
    );

    cardthemeDark = CardTheme(color: cardDarkColor);
    cardthemelite = CardTheme(color: cardLiteColor);

    floatingActionButtonTheme = FloatingActionButtonThemeData(
      backgroundColor: fabBackgroundColor,
      foregroundColor: fabForegroundColor,
      elevation:
          double.tryParse(
            const String.fromEnvironment('FAB_ELEVATION', defaultValue: '4.0'),
          ) ??
          4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          double.tryParse(
                const String.fromEnvironment(
                  'FAB_BORDER_RADIUS',
                  defaultValue: '12.0',
                ),
              ) ??
              12.0,
        ),
      ),
    );

    // ElevatedButton colors
    Color buttonBackgroundColor = _parseColor(
      const String.fromEnvironment(
        'BUTTON_BACKGROUND_COLOR',
        defaultValue: '0xFFFF4500',
      ),
      Colors.deepOrange,
    );

    Color buttonShadowColor = _parseColor(
      const String.fromEnvironment(
        'BUTTON_SHADOW_COLOR',
        defaultValue: '0xFFFF4500',
      ),
      Colors.deepOrange,
    );

    elevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation:
            double.tryParse(
              const String.fromEnvironment(
                'BUTTON_ELEVATION',
                defaultValue: '8.0',
              ),
            ) ??
            8.0,
        shadowColor: buttonShadowColor,
        backgroundColor: buttonBackgroundColor,
        disabledBackgroundColor: Colors.deepOrange.withOpacity(0.4),
        disabledForegroundColor: Colors.deepOrange,
      ),
    );

    if (kDebugMode) {
      print('=== Sunshine Environment Configuration ===');
      print('IMAGE_PATH: $imagePath');
      print('IMAGE_PATH_PDF: $imagePathpdf');
      print('ANDROID_LINK: $AndroidLink');
      print('IOS_LINK: $IosLink');
      print('APP_TITLE: $title');
      print('SHOW_CONVERSATION: $showconversation');
      print('==========================================');
    }
  }

  static void _validateApiUrl() {
    if (baseApiUrl.isEmpty) {
      throw Exception(
        'baseApiUrl is empty! Make sure to provide API_URL via --dart-define',
      );
    }

    try {
      final uri = Uri.parse(baseApiUrl);
      if (uri.host.isEmpty) {
        throw Exception(
          'Invalid baseApiUrl: "$baseApiUrl" - no host specified',
        );
      }
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        throw Exception(
          'Invalid baseApiUrl: "$baseApiUrl" - must start with http:// or https://',
        );
      }
    } catch (e) {
      throw Exception('Invalid baseApiUrl: "$baseApiUrl" - ${e.toString()}');
    }
  }
}
