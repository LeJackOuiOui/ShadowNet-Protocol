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

Future<void> _authenticate() async {
  if (_isProcessing || _isLocked) return;
  setState(() => _isProcessing = true);

  bool success = false;

  final cancelTimer = Timer(const Duration(seconds: 8), () {
    auth.stopAuthentication();
  });

  try {
    success = await auth.authenticate(
      localizedReason: 'VALIDACIÓN DE ADN REQUERIDA — PROTOCOLO SHADOWNET',
      options: const AuthenticationOptions(
        stickyAuth: false,
        biometricOnly: true,
      ),
    );
  } on PlatformException catch (e) {
    success = false;

    // Android bloqueó biométricamente — no contar como fallo tuyo
    // ni permitir más intentos hasta que el sistema se desbloquee
    if (e.code == auth_error.lockedOut ||
        e.code == auth_error.permanentlyLockedOut) {
      cancelTimer.cancel();
      if (mounted) setState(() => _isProcessing = false);
      // Mostrar mensaje y salir — no tocar _failedAttempts
      _showSystemLockedMessage(e.code == auth_error.permanentlyLockedOut);
      return; // ← corta aquí, no llega al bloque else de abajo
    }
  } finally {
    cancelTimer.cancel();
    if (mounted) setState(() => _isProcessing = false);
  }

  if (!mounted) return;

  if (success) {
    setState(() {
      _isAuthenticated = true;
      _failedAttempts = 0;
    });
    _iniciarGeoRadar();
  } else {
    setState(() => _failedAttempts++);
    if (_failedAttempts >= 3) {
      await _triggerSelfDestruct();
    }
  }
}

// Mensaje cuando Android bloqueó — no es fallo de tu app
Future<void> _showSystemLockedMessage(bool isPermanent) async {
  if (!mounted) return;

  if (isPermanent) {
    // Bloqueo permanente — no hay countdown, solo mensaje fijo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.deepOrange,
        duration: Duration(seconds: 6),
        content: Text(
          "> SISTEMA ANDROID BLOQUEADO\n> DESBLOQUEA EL TELÉFONO PRIMERO",
          style: TextStyle(fontFamily: 'RobotoMono', fontSize: 12),
        ),
      ),
    );
    return;
  }

  // Bloqueo temporal — countdown visible en pantalla
  setState(() => _systemLockSeconds = 30);

  for (int i = 30; i > 0; i--) {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _systemLockSeconds = i - 1);
  }

  // Al llegar a 0, limpia el estado
  if (mounted) setState(() => _systemLockSeconds = 0);
}

// ── AUTODESTRUCCIÓN ──────────────────────────────────────────────────────

// ── GEOLOCALIZACIÓN ──────────────────────────────────────────────────────

void _iniciarGeoRadar() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) return;

  Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    ),
  ).listen((Position position) {
    if (mounted) setState(() => _currentPosition = position);
  });
}

// ── BUILD ────────────────────────────────────────────────────────────────

// ── PANTALLA PRINCIPAL ───────────────────────────────────────────────────

Widget _buildRadarList() {
  if (_currentPosition == null) {
    return const Text("> BUSCANDO SATÉLITES...");
  }

  final nodosDetectados = _nodos.map((nodo) {
    double distancia = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      nodo['lat'],
      nodo['lng'],
    );
    return {...nodo, 'distancia': distancia};
  }).toList();

  return ListView.builder(
    itemCount: nodosDetectados.length,
    itemBuilder: (context, index) {
      final nodo = nodosDetectados[index];
      final double dist = nodo['distancia'];

      final bool completada = dist <= 500;

      return GestureDetector(
        onTap: () async {
          if (completada) {
            // Vibrar si está completada
            if (await Vibration.hasVibrator() ?? false) {
              Vibration.vibrate(pattern: [0, 200, 200, 600, 200, 200]);
            }
            _completarMision();
          } else {
            // Mostrar mensaje si no está completada
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "MISIÓN NO COMPLETADA - FALTAN ${dist.toStringAsFixed(0)} METROS",
                  ),
                ),
              );
            }
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: completada ? Colors.green : const Color(0xFF00FF41),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "> NODO ${nodo['nombre']}",
                style: TextStyle(
                  color: completada ? Colors.green : Colors.orange,
                ),
              ),
              Text("  OBJETIVO: ${nodo['mision']}"),
              completada
                  ? const Text("  MISIÓN COMPLETADA ✅")
                  : Text("  FALTAN: ${dist.toStringAsFixed(0)} METROS"),
            ],
          ),
        ),
      );
    },
  );
}

void _completarMision() async {
  if (await Vibration.hasVibrator() ?? false) {
    Vibration.vibrate(pattern: [0, 200, 200, 600, 200, 200]);
  }
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("MISIÓN COMPLETADA - SEÑAL ENVIADA")),
    );
  }
}

  // ── PANTALLA DE BLOQUEO ──────────────────────────────────────────────────
  
  // ── PANTALLA DE AUTODESTRUCCIÓN ───────────────────────────────────────────
