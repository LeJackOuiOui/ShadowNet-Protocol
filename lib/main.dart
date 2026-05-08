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

// ── PANTALLA DE LA TERMINAL ──────────────────────────────────────────────

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

  Widget _buildFooter() {
    return Text(
      "> POSICIÓN: ${_currentPosition?.latitude.toStringAsFixed(4)}, ${_currentPosition?.longitude.toStringAsFixed(4)}",
      style: const TextStyle(fontSize: 10, color: Colors.grey),
    );
  }
}
