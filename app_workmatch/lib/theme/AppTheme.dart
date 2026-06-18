import 'package:flutter/material.dart';

import 'AppColors.dart';

/// WorkMatch — Tema sincronizado com o CEL Design System v3.0
/// Usa navy como cor primária (igual ao frontend: navbar, headers, CTAs).
class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      primary:   AppColors.navy,
      secondary: AppColors.blue,
      tertiary:  AppColors.yellow,
      surface:   AppColors.surface,
      onPrimary:   Colors.white,
      onSecondary: Colors.white,
      onSurface:   AppColors.text,
      error: Color(0xFFDC2626),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: colorScheme,

      // ── Tipografia ──────────────────────────────────────────────────────
      textTheme: const TextTheme(
        // Títulos de página / seção
        titleLarge:  TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.navy),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.navy),
        titleSmall:  TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.navy),
        // Corpo
        bodyLarge:   TextStyle(fontSize: 16, color: AppColors.text),
        bodyMedium:  TextStyle(fontSize: 14, color: AppColors.text),
        bodySmall:   TextStyle(fontSize: 12, color: AppColors.textMid),
        // Labels (chips, badges, eyebrows)
        labelLarge:  TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navy),
        labelSmall:  TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.07, color: AppColors.blue),
      ),

      // ── AppBar — navy, igual ao wm-header do frontend ──────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),

      // ── Cards — surface branca com borda sutil (var(--clr-border)) ─────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      // ── Inputs — padrão CEL (wm-input, wm-input-wrapper) ───────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          // azul institucional ao focar — igual ao frontend
          borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),

      // ── ElevatedButton — navy primário / amarelo accent ────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      // ── OutlinedButton — borda navy, fundo transparente ────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.navy, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // ── TextButton — azul institucional (links do frontend) ────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.blue,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),

      // ── Chip — estilo dos wm-chip / filtros do HomeProfissional ────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.navy,
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.navy, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Divisor ────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),

      // ── BottomNavigationBar — navy ──────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.navy,
        unselectedItemColor: AppColors.textLight,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}