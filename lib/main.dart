import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:vibration/vibration.dart';
import 'package:geolocator/geolocator.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'dart:async';

void main() {
  runApp(const ShadowNetApp());
}

class ShadowNetApp extends StatelessWidget {
  const ShadowNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShadowNet Protocol',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.robotoMonoTextTheme(ThemeData.dark().textTheme)
            .apply(
              bodyColor: const Color(0xFF00FF41),
              displayColor: const Color(0xFF00FF41),
            ),
      ),
      home: const TerminalScreen(),
    );
  }
}

  // ── PANTALLA DE LA TERMINAL ────────────────────────────────────────────────

  // ── AUTENTICACIÓN ────────────────────────────────────────────────────────
  
  // ── AUTODESTRUCCIÓN ──────────────────────────────────────────────────────
 
  // ── GEOLOCALIZACIÓN ──────────────────────────────────────────────────────
  
  // ── BUILD ────────────────────────────────────────────────────────────────
  
  // ── PANTALLA PRINCIPAL ───────────────────────────────────────────────────
  
  // ── PANTALLA DE BLOQUEO ──────────────────────────────────────────────────
  
  // ── PANTALLA DE AUTODESTRUCCIÓN ───────────────────────────────────────────
