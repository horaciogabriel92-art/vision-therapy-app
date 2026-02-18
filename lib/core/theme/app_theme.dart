import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores Clínicos (Anaglifo Puro - NO TOCAR NI ATENUAR)
  static const Color redLeft = Color(0xFFFF0000);   // Filtro Rojo Puro
  static const Color cyanRight = Color(0xFF00FFFF); // Filtro Cian Puro
  
  // Colores UI "Neuro-Tech"
  static const Color background = Color(0xFF050510);     // Void Black (Profundidad)
  static const Color surface = Color(0xFF13132B);        // Deep Space Blue
  static const Color surfaceGlass = Color(0x9913132B);   // Semi-transparente
  
  static const Color primary = Color(0xFF00F3FF);        // Cyber Cyan (Principal)
  static const Color secondary = Color(0xFF7000FF);      // Neural Purple
  static const Color accent = Color(0xFF00FF9D);         // Bio-Green (Éxito)
  static const Color energy = Color(0xFFFFB800);         // Plasma Gold
  static const Color danger = Color(0xFFFF0055);         // System Alert

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      
      // Esquema de Color
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: surface,
        background: background,
        error: danger,
      ),
      
      // Tipografía Sci-Fi
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2
        ),
        titleLarge: GoogleFonts.rajdhani(
          fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, color: const Color(0xFFE2E8F0)
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, color: const Color(0xFF94A3B8)
        ),
      ),
      
      // Componentes
      cardTheme: CardTheme(
        color: surface,
        elevation: 8,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black, // Texto oscuro sobre neón
          textStyle: GoogleFonts.rajdhani(
            fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0, // Flat cyber look
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 2),
          textStyle: GoogleFonts.rajdhani(
            fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
    );
  }
}
