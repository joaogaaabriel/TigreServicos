import 'package:flutter/material.dart';

/// WorkMatch — Paleta de cores sincronizada com o CEL Design System v3.0
class AppColors {
  AppColors._();

  // ── Navy ──────────────────────────────────────────────────────────────────
  static const navy        = Color(0xFF0F2942);
  static const navyDeep   = Color(0xFF081A2B);

  // ── Azul institucional ────────────────────────────────────────────────────
  static const blue        = Color(0xFF1E5FAF);
  static const bluePale   = Color(0xFFEEF4FF);

  // ── Amarelo / Accent ──────────────────────────────────────────────────────
  static const yellow      = Color(0xFFF2C94C);
  static const yellowSoft = Color(0xFFFDF8E7);

  // ── Superfícies & Fundo ───────────────────────────────────────────────────
  static const background  = Color(0xFFF7F9FC);
  static const surface     = Color(0xFFFFFFFF);

  // ── Texto ─────────────────────────────────────────────────────────────────
  static const text        = Color(0xFF111827);
  static const textMid    = Color(0xFF6B7280);
  static const textLight  = Color(0xFF9CA3AF);

  // ── Borda ─────────────────────────────────────────────────────────────────
  static const border      = Color(0xFFE5E7EB);

  // ── Semânticas ────────────────────────────────────────────────────────────
  static const success     = Color(0xFF2DBE60);
  static const warning     = Color(0xFFF1A326);
  static const info        = blue;
  static const inactive    = Color(0xFF9CA3AF);

  // ── Compatibilidade (deprecated) ──────────────────────────────────────────
  static const primary     = Color(0xFFFF7A1A);
  static const primaryDark = Color(0xFFE56407);
  static const primarySoft = Color(0xFFFFE1C7);
  static const card        = surface;
}