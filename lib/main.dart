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

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  bool _isAuthenticated = false;
  bool _isLocked = false; // true = pantalla roja activa
  bool _isProcessing = false; // true = diálogo biométrico abierto
  int _failedAttempts = 0; // conteo real de veces que el usuario falló
  int _lockSecondsRemaining = 5;
  int _systemLockSeconds = 0; // 0 = no hay bloqueo del sistema activo

  Position? _currentPosition;

  final List<Map<String, dynamic>> _nodos = [
    {
      'nombre': 'SENA Mosquera',
      'mision': 'Hackear el servidor de notas',
      'lat': 4.6953,
      'lng': -74.2166,
    },
    {
      'nombre': 'Parque Principal',
      'mision': 'Interceptar señal de radio',
      'lat': 4.7059,
      'lng': -74.2302,
    },
    {
      'nombre': 'Zona Industrial',
      'mision': 'Sabotaje de drones',
      'lat': 4.7200,
      'lng': -74.2000,
    },
  ];

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  // ── AUTENTICACIÓN ────────────────────────────────────────────────────────
  
  // ── AUTODESTRUCCIÓN ──────────────────────────────────────────────────────
 
  // ── GEOLOCALIZACIÓN ──────────────────────────────────────────────────────
  
  // ── BUILD ────────────────────────────────────────────────────────────────
  
    @override
  Widget build(BuildContext context) {
    if (_isLocked) return _buildAutodestruccionScreen();
    if (!_isAuthenticated) return _buildLockScreen();
    return _buildMainTerminal();
  }

  // ── PANTALLA PRINCIPAL ───────────────────────────────────────────────────
  
  Widget _buildMainTerminal() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              const Text(
                ">>> ESCANEANDO NODOS CERCANOS...",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(child: _buildRadarList()),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("SHADOWNET OS v4.0.2 [STATUS: INFILTRATED]"),
        Text("OPERADOR: RESISTENCIA_UNIT_01"),
        Text("-------------------------------------------"),
      ],
    );
  }

  // ── PANTALLA DE BLOQUEO ──────────────────────────────────────────────────
  
  Widget _buildLockScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "SISTEMA BLOQUEADO",
              style: TextStyle(fontSize: 24, color: Colors.red),
            ),
            // Muestra intentos restantes al usuario
            if (_failedAttempts > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  "INTENTOS FALLIDOS: $_failedAttempts / 3",
                  style: const TextStyle(color: Colors.orange, fontSize: 13),
                ),
              ),
            // Countdown de bloqueo del sistema Android
            if (_systemLockSeconds > 0)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    const Text(
                      "SISTEMA ANDROID BLOQUEADO",
                      style: TextStyle(color: Colors.orange, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${_systemLockSeconds}s",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'RobotoMono',
                      ),
                    ),
                    const Text(
                      "ESPERA PARA REINTENTAR",
                      style: TextStyle(color: Colors.orange, fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    // Barra de progreso visual
                    SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(
                        value: _systemLockSeconds / 30,
                        color: Colors.orange,
                        backgroundColor: Colors.orange.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),

            // Botón deshabilitado durante el countdown
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[900],
              ),
              onPressed: (_isProcessing || _systemLockSeconds > 0)
                  ? null
                  : _authenticate,
              child: Text(
                _isProcessing
                    ? "ESCANEANDO..."
                    : _systemLockSeconds > 0
                    ? "BLOQUEADO..."
                    : "VALIDAR ADN",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PANTALLA DE AUTODESTRUCCIÓN ───────────────────────────────────────────
    Widget _buildFooter() {
    return Text(
      "> POSICIÓN: ${_currentPosition?.latitude.toStringAsFixed(4)}, ${_currentPosition?.longitude.toStringAsFixed(4)}",
      style: const TextStyle(fontSize: 10, color: Colors.grey),
    );
  }
}