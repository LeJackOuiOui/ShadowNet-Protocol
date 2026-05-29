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

enum Faction { hacker, enforcer, ghost }

class ShadowNetApp extends StatefulWidget {
  const ShadowNetApp({super.key});

  @override
  State<ShadowNetApp> createState() => _ShadowNetAppState();
}

class _ShadowNetAppState extends State<ShadowNetApp> {
  Faction _currentFaction = Faction.hacker;

  Color _getFactionColor(Faction faction) {
    switch (faction) {
      case Faction.hacker:
        return const Color(0xFF00FF41);
      case Faction.enforcer:
        return const Color(0xFFFF3B30);
      case Faction.ghost:
        return const Color(0xFF00C6FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color seedColor = _getFactionColor(_currentFaction);

    return MaterialApp(
      title: 'ShadowNet Protocol',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
          background: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.jetBrainsMonoTextTheme(
          ThemeData.dark().textTheme,
        ).apply(bodyColor: seedColor, displayColor: seedColor),
      ),
      home: TerminalScreen(
        currentFaction: _currentFaction,
        onFactionChanged: (Faction newFaction) {
          setState(() => _currentFaction = newFaction);
        },
      ),
    );
  }
}

class TerminalScreen extends StatefulWidget {
  final Faction currentFaction;
  final ValueChanged<Faction> onFactionChanged;

  const TerminalScreen({
    super.key,
    required this.currentFaction,
    required this.onFactionChanged,
  });

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  bool _isAuthenticated = false;
  bool _isLocked = false;
  bool _isProcessing = false;
  int _failedAttempts = 0;
  int _lockSecondsRemaining = 5;
  int _systemLockSeconds = 0;

  Position? _currentPosition;

  final List<Map<String, dynamic>> _nodes = [
    {
      'name': 'SENA Mosquera',
      'mission': 'Hack student grade server',
      'lat': 4.6953,
      'lng': -74.2166,
    },
    {
      'name': 'Central Park',
      'mission': 'Intercept radio frequencies',
      'lat': 4.7059,
      'lng': -74.2302,
    },
    {
      'name': 'Industrial Zone',
      'mission': 'Drone system sabotage',
      'lat': 4.7200,
      'lng': -74.2000,
    },
  ];

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    if (_isProcessing || _isLocked) return;
    setState(() => _isProcessing = true);

    bool success = false;
    final cancelTimer = Timer(
      const Duration(seconds: 8),
      () => auth.stopAuthentication(),
    );

    try {
      success = await auth.authenticate(
        localizedReason: 'DNA VALIDATION REQUIRED — SHADOWNET PROTOCOL',
        options: const AuthenticationOptions(
          stickyAuth: false,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      success = false;
      if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        cancelTimer.cancel();
        if (mounted) setState(() => _isProcessing = false);
        _handleSystemLock(e.code == auth_error.permanentlyLockedOut);
        return;
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
      _initGeoRadar();
    } else {
      setState(() => _failedAttempts++);
      if (_failedAttempts >= 3) await _triggerSelfDestruct();
    }
  }

  Future<void> _handleSystemLock(bool isPermanent) async {
    if (!mounted) return;
    if (isPermanent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "HARDWARE CRITICAL LOCKOUT - CLEAR PHONE PASSCODE FIRST",
          ),
        ),
      );
      return;
    }

    setState(() => _systemLockSeconds = 30);
    for (int i = 30; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _systemLockSeconds = i - 1);
    }
  }

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

    if (mounted) {
      setState(() {
        _isLocked = false;
        _failedAttempts = 0;
        _isProcessing = false;
      });
    }
  }

  void _initGeoRadar() async {
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

  @override
  Widget build(BuildContext context) {
    if (_isLocked) return _buildSelfDestructScreen();
    if (!_isAuthenticated) return _buildLockScreen();
    return _buildMainTerminal();
  }

  Widget _buildMainTerminal() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SHADOWNET TERMINAL v5.0"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: () => setState(() => _isAuthenticated = false),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFactionSelector(),
              const SizedBox(height: 20),
              _buildCentralFactionLogo(),
              const SizedBox(height: 20),
              const Text(
                ">>> SCANNING OPERATIONS RADAR...",
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

  Widget _buildFactionSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: Faction.values.map((faction) {
        final bool isSelected = widget.currentFaction == faction;
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
            backgroundColor: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Colors.transparent,
          ),
          onPressed: () => widget.onFactionChanged(faction),
          child: Text(faction.name.toUpperCase()),
        );
      }).toList(),
    );
  }

  Widget _buildCentralFactionLogo() {
    IconData factionIcon;
    switch (widget.currentFaction) {
      case Faction.hacker:
        factionIcon = Icons.terminal;
        break;
      case Faction.enforcer:
        factionIcon = Icons.shield;
        break;
      case Faction.ghost:
        factionIcon = Icons.visibility_off;
        break;
    }
    return Center(
      child: Icon(
        factionIcon,
        size: 100,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildRadarList() {
    if (_currentPosition == null)
      return const Text("> ACQUIRING SATELLITE LINK...");

    return ListView.builder(
      itemCount: _nodes.length,
      itemBuilder: (context, index) {
        final node = _nodes[index];
        final double distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          node['lat'],
          node['lng'],
        );
        final bool isAvailable = distance <= 500;

        return GestureDetector(
          onTap: () async {
            if (isAvailable) {
              if (await Vibration.hasVibrator() ?? false) {
                Vibration.vibrate(pattern: [0, 200, 200, 600, 200, 200]);
              }
              _completarMision();
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "MISIÓN NO COMPLETADA - FALTAN ${distance.toStringAsFixed(0)} METROS",
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
              border: Border.all(color: Theme.of(context).colorScheme.primary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "> NODE: ${node['name']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("  OBJECTIVE: ${node['mission']}"),
                Text(
                  isAvailable
                      ? "  STATUS: UNLOCKED ✅"
                      : "  RANGE OUT: FALTAN ${distance.toStringAsFixed(0)}m",
                ),
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

  Widget _buildLockScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, color: Colors.red, size: 50),
            const SizedBox(height: 20),
            const Text(
              "SHADOWNET SECURE ACCESS",
              style: TextStyle(fontSize: 20),
            ),
            if (_failedAttempts > 0)
              Text(
                "ATTEMPTS: $_failedAttempts / 3",
                style: const TextStyle(color: Colors.orange),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (_isProcessing || _systemLockSeconds > 0)
                  ? null
                  : _authenticate,
              child: Text(
                _isProcessing ? "SCANNING..." : "VALIDATE BIOMETRICS",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelfDestructScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF300000),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.gavel, color: Colors.white, size: 60),
            Text(
              "SELF-DESTRUCT SEQUENCE: $_lockSecondsRemaining",
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      "> GPS: ${_currentPosition?.latitude.toStringAsFixed(4)}, ${_currentPosition?.longitude.toStringAsFixed(4)}",
      style: const TextStyle(fontSize: 10, color: Colors.grey),
    );
  }
}
