import 'dart:async';
import 'package:braille/screens/screen2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool _isLoading = false;
  BluetoothDevice? connectedDevice;

  // ------------------ PERMISSIONS ------------------

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  // ------------------ BLE SCAN & CONNECT ------------------

  Future<void> _connectToESP32() async {
  bool deviceFound = false;

  FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

  Timer(const Duration(seconds: 11), () {
    if (!deviceFound && mounted) {
      FlutterBluePlus.stopScan();
      setState(() => _isLoading = false);
    }
  });

  FlutterBluePlus.scanResults.listen((results) async {
    for (ScanResult result in results) {
      if (result.device.name == "ESP32_DOT_READ") {
        deviceFound = true;
        FlutterBluePlus.stopScan();

        try {
          await result.device.connect();
          if (!mounted) return;

          setState(() => _isLoading = false);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
          );
        } catch (e) {
          if (mounted) setState(() => _isLoading = false);
        }
        break;
      }
    }
  });
}


  // ------------------ UI ------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 11, 61, 57),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                "Dot Read",
                style: GoogleFonts.ruthie(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // Connect Button
              SizedBox(
                width: 200,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);

                          bool granted = await _requestPermissions();
                          if (!granted) {
                            setState(() => _isLoading = false);
                            return;
                          }

                          await _connectToESP32();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color.fromARGB(255, 11, 61, 57),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const BrailleLoading()
                      : Text(
                          "Connect",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------ BRAILLE LOADING ------------------

class BrailleLoading extends StatefulWidget {
  const BrailleLoading({super.key});

  @override
  State<BrailleLoading> createState() => _BrailleLoadingState();
}

class _BrailleLoadingState extends State<BrailleLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _a1, _a2, _a3;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();

    _a1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.3)),
    );
    _a2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.6)),
    );
    _a3 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FadeTransition(opacity: _a1, child: const Dot()),
          FadeTransition(opacity: _a2, child: const Dot()),
          FadeTransition(opacity: _a3, child: const Dot()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ------------------ DOT ------------------

class Dot extends StatelessWidget {
  const Dot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 235, 238, 238),
        shape: BoxShape.circle,
      ),
    );
  }
}
//