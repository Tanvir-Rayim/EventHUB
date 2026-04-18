import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData
  darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor:
        const Color(0xFF0D0F1A),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF5C7A),
      secondary: Color(0xFF7C5CFF),
      surface: Color(0xFF171A2A),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor:
          Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFFB8B8C7),
        fontSize: 14,
      ),
    ),

    inputDecorationTheme:
        InputDecorationTheme(
          filled: true,
          fillColor: const Color(
            0xFF111425,
          ),
          contentPadding:
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
                  12,
                ),
            borderSide:
                const BorderSide(
                  color: Color(
                    0xFF2A2E43,
                  ),
                ),
          ),
          enabledBorder:
              OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                borderSide:
                    const BorderSide(
                      color: Color(
                        0xFF2A2E43,
                      ),
                    ),
              ),
          focusedBorder:
              OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                borderSide:
                    const BorderSide(
                      color: Color(
                        0xFFFF5C7A,
                      ),
                      width: 1.4,
                    ),
              ),
          hintStyle: const TextStyle(
            color: Color(0xFF7E839A),
          ),
        ),

    elevatedButtonTheme:
        ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFFFF5C7A),
            foregroundColor:
                Colors.white,
            minimumSize: const Size(
              double.infinity,
              52,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
            ),
          ),
        ),

    cardTheme: CardThemeData(
      color: const Color(0xFF171A2A),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20),
      ),
      margin: EdgeInsets.zero,
    ),
  );
}
