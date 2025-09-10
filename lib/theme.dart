// Define consistent color constants at the top of your file
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:zenifytrip_guide/env.dart';

// Base color palettes for different environments
class BaseColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
}

// Zenify Environment Colors
class ZenifyColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryOrange = Color.fromARGB(255, 255, 105, 18);
  static const Color primaryYellow = Color.fromARGB(255, 190, 137, 22);
  static const Color primaryCoral = Color.fromARGB(255, 235, 95, 82);
  static const Color accentGreen = Color.fromARGB(255, 1, 129, 67);
  static const Color shadowGreen = Color.fromARGB(255, 2, 197, 80);
  static const Color buttonBrown = Color.fromARGB(255, 203, 163, 110);
  static const Color cardYellow = Color.fromARGB(255, 233, 181, 11);
  static const Color cardLight = Color.fromRGBO(243, 235, 240, 1);
  static const Color lightGray = Color(0xFFFAF7F5);
  static const Color mediumGray = Color(0xFFE8E0DC);
  static const Color darkGray = Color(0xFF8D6E63);
  static const Color textDark = Color(0xFF3E2723);
}

// Add your other environment colors here
class TunisiePromoColors {
  // Example colors - replace with your actual values
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color accent = Color(0xFF2196F3);
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color mediumGray = Color(0xFFE5E7EB);
  static const Color darkGray = Color(0xFF6B7280);
  static const Color textDark = Color(0xFF1F2937);
  static const Color cardLight = Color(0xFFFAFBFC);
}

class DefaultColors {
  // Your default/fallback colors
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color accent = Color(0xFF00796B);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFE0E0E0);
  static const Color darkGray = Color(0xFF757575);
  static const Color textDark = Color(0xFF212121);
  static const Color cardLight = Color(0xFFFFFFFF);
}

class ThemeHelper {
  // Generate light theme based on environment
  static ThemeData getLightTheme(Environment environment) {
    switch (environment) {
      case Environment.zenify:
        return _buildZenifyLightTheme();
      case Environment.tunisie: // Add your other environments
        return _buildTunisiePromoLightTheme();
      // Add more cases for your other environments
      default:
        return _buildDefaultLightTheme();
    }
  }

 // Zenify Light Theme - Polished
static ThemeData _buildZenifyLightTheme() {
  return ThemeData(
    useMaterial3: true, // Modern Material Design
    scaffoldBackgroundColor: ZenifyColors.lightGray,

    // Primary Branding Colors
    primaryColor: ZenifyColors.primaryOrange,
    colorScheme: ColorScheme.light(
      primary: ZenifyColors.primaryOrange,
      primaryContainer: ZenifyColors.primaryCoral,
      secondary: ZenifyColors.accentGreen,
      secondaryContainer: ZenifyColors.shadowGreen,
      surface: BaseColors.white,
      background: ZenifyColors.lightGray,
      error: BaseColors.error,
      onPrimary: BaseColors.white,
      onSecondary: BaseColors.white,
      onSurface: ZenifyColors.textDark,
      onBackground: ZenifyColors.textDark,
      onError: BaseColors.white,
    ),

    // Card Styling
    cardTheme: CardTheme(
      color: BaseColors.white,
      elevation: 2,
      shadowColor: ZenifyColors.primaryOrange.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.all(8.0),
    ),

    // Bottom App Bar
    bottomAppBarTheme: BottomAppBarTheme(
      color: ZenifyColors.primaryOrange,
      elevation: 6.0,
      shape: const CircularNotchedRectangle(),
    ),

    // Elevated Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 3,
        shadowColor: ZenifyColors.primaryOrange.withOpacity(0.3),
        backgroundColor: ZenifyColors.accentGreen,
        disabledBackgroundColor: ZenifyColors.mediumGray,
        disabledForegroundColor: Colors.white70,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    ),

    // Navigation Bar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ZenifyColors.primaryOrange,
      indicatorColor: ZenifyColors.accentGreen.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.all(
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: Colors.white,
        ),
      ),
      iconTheme: MaterialStateProperty.all(
        const IconThemeData(color: Colors.white, size: 24),
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ZenifyColors.primaryOrange,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // App Bar
    appBarTheme: AppBarTheme(
      backgroundColor: ZenifyColors.primaryOrange,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'PlayFair',
      ),
      iconTheme: const IconThemeData(color: Colors.white, size: 24),
      actionsIconTheme: const IconThemeData(color: Colors.white, size: 24),
    ),

    // Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BaseColors.white,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: TextStyle(
        color: ZenifyColors.primaryOrange,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: ZenifyColors.mediumGray,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ZenifyColors.primaryOrange, width: 1.2),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ZenifyColors.primaryOrange, width: 2.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: BaseColors.error, width: 1.5),
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),

    // Typography
    fontFamily: 'Poppins',
    textTheme: _buildTextTheme(
      ZenifyColors.textDark,
      ZenifyColors.primaryOrange,
    ),

    // Dividers
    dividerColor: ZenifyColors.mediumGray.withOpacity(0.3),
    splashColor: ZenifyColors.primaryOrange.withOpacity(0.2),
  );
}

  // TunisiePromo Light Theme (example)
  static ThemeData _buildTunisiePromoLightTheme() {
    return ThemeData(
      cardTheme: CardTheme(
        color: TunisiePromoColors.cardLight,
        elevation: 2,
        shadowColor: TunisiePromoColors.primary.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      
      scaffoldBackgroundColor: TunisiePromoColors.lightGray,
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4.0,
          backgroundColor: TunisiePromoColors.primary,
          foregroundColor: BaseColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      
      splashColor: TunisiePromoColors.accent.withOpacity(0.3),
      primaryColor: TunisiePromoColors.primary,
      
      colorScheme: ColorScheme.light(
        primary: TunisiePromoColors.primary,
        primaryContainer: TunisiePromoColors.primaryLight,
        secondary: TunisiePromoColors.accent,
        surface: BaseColors.white,
        background: TunisiePromoColors.lightGray,
        error: BaseColors.error,
        onPrimary: BaseColors.white,
        onSecondary: BaseColors.white,
        onSurface: TunisiePromoColors.textDark,
        onBackground: TunisiePromoColors.textDark,
        onError: BaseColors.white,
      ),
      
      dividerColor: TunisiePromoColors.mediumGray,
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: TunisiePromoColors.primary,
        foregroundColor: BaseColors.white,
        elevation: 6.0,
        shape: CircleBorder(),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: TextStyle(
          color: TunisiePromoColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: TunisiePromoColors.darkGray,
          fontSize: 14,
        ),
        fillColor: BaseColors.white,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: TunisiePromoColors.primary, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: TunisiePromoColors.mediumGray, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: TunisiePromoColors.mediumGray, width: 1.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: TunisiePromoColors.primary,
        foregroundColor: BaseColors.white,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: BaseColors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'PlayFair',
        ),
        iconTheme: IconThemeData(color: BaseColors.white, size: 24),
      ),
      
      fontFamily: 'PlayFair',
      textTheme: _buildTextTheme(TunisiePromoColors.textDark, TunisiePromoColors.primary),
    );
  }

  // Default Light Theme
  static ThemeData _buildDefaultLightTheme() {
    return ThemeData(
      cardTheme: CardTheme(
        color: DefaultColors.cardLight,
        elevation: 2,
        shadowColor: DefaultColors.mediumGray.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      
      scaffoldBackgroundColor: DefaultColors.lightGray,
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DefaultColors.primary,
          foregroundColor: BaseColors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      
      splashColor: DefaultColors.accent.withOpacity(0.3),
      primaryColor: DefaultColors.primary,
      
      colorScheme: ColorScheme.light(
        primary: DefaultColors.primary,
        primaryContainer: DefaultColors.primaryLight,
        secondary: DefaultColors.accent,
        surface: BaseColors.white,
        background: DefaultColors.lightGray,
        error: BaseColors.error,
        onPrimary: BaseColors.white,
        onSecondary: BaseColors.white,
        onSurface: DefaultColors.textDark,
        onBackground: DefaultColors.textDark,
        onError: BaseColors.white,
      ),
      
      dividerColor: DefaultColors.mediumGray,
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DefaultColors.primary,
        foregroundColor: BaseColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: TextStyle(
          color: DefaultColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        fillColor: BaseColors.white,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: DefaultColors.primary, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: DefaultColors.mediumGray, width: 1.5),
          borderRadius: BorderRadius.circular(10.0),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: DefaultColors.mediumGray, width: 1.5),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: DefaultColors.primary,
        foregroundColor: BaseColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: BaseColors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'PlayFair',
        ),
        iconTheme: IconThemeData(color: BaseColors.white, size: 24),
      ),
      
      fontFamily: 'PlayFair',
      textTheme: _buildTextTheme(DefaultColors.textDark, DefaultColors.primary),
    );
  }

  // Helper method to build consistent text themes
  static TextTheme _buildTextTheme(Color textColor, Color accentColor) {
    return TextTheme(
      headlineLarge: TextStyle(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'PlayFair',
      ),
      headlineMedium: TextStyle(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: 'PlayFair',
      ),
      headlineSmall: TextStyle(
        color: accentColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'PlayFair',
      ),
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        fontFamily: 'PlayFair',
      ),
      titleMedium: TextStyle(
        color: accentColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: 'PlayFair',
      ),
      bodyLarge: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        fontFamily: 'PlayFair',
      ),
      bodyMedium: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.normal,
        fontFamily: 'PlayFair',
      ),
    );
  }
}

// Usage Example:
// In your main app or theme configuration:
/*
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppEnvironment.title,
      theme: ThemeHelper.getLightTheme(AppEnvironment.currentEnvironment),
      home: MyHomePage(),
    );
  }
}
*/
  // Card theme
  