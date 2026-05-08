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

Future<void> _triggerSelfDestruct() async {
  if (_isLocked) return;

  setState(() {
    _isLocked = true;
    _lockSecondsRemaining = 5;
  });

  if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate(duration: 5000);
  }

  for (int i = 5; i > 0; i--) {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _lockSecondsRemaining = i - 1);
  }

  // Al terminar: desbloquea y resetea todo para poder reintentar
  if (mounted) {
    setState(() {
      _isLocked = false;
      _failedAttempts = 0;
      _isProcessing = false;
    });
  }
}

// ── GEOLOCALIZACIÓN ──────────────────────────────────────────────────────

// ── BUILD ────────────────────────────────────────────────────────────────

// ── PANTALLA PRINCIPAL ───────────────────────────────────────────────────

// ── PANTALLA DE BLOQUEO ──────────────────────────────────────────────────

// ── PANTALLA DE AUTODESTRUCCIÓN ───────────────────────────────────────────
Widget _buildAutodestruccionScreen() {
  return Scaffold(
    backgroundColor: Colors.red[900],
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 60,
          ),
          const SizedBox(height: 24),
          const Text(
            "⚠ PROTOCOLO DE\nAUTODESTRUCCIÓN INICIADO",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
              fontFamily: 'RobotoMono',
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "$_lockSecondsRemaining",
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'RobotoMono',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "SISTEMA SE REINICIA EN...",
            style: TextStyle(color: Colors.white70, letterSpacing: 1.5),
          ),
        ],
      ),
    ),
  );
}
