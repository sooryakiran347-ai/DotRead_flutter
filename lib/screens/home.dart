import 'package:braille/screens/screen2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool _isLoading = false;

  // 🔹 ESP hostname (common host)
  static const String espHost = "192.168.4.1";

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  // 🔹 Location permission (required for Wi-Fi scanning)
  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();

    if (!status.isGranted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission required for Wi-Fi")),
      );
    }
  }

  // 🔹 Connect to ESP Wi-Fi + send HTTP request
  Future<void> connectToESP() async {
    // Step 1: Connect to ESP access point
    final connected = await WiFiForIoTPlugin.connect(
      "Gopu",
      password: "12345678",
      security: NetworkSecurity.WPA,
      joinOnce: true,
    );

    if (!connected) {
      throw Exception("Wi-Fi connection failed");
    }

    // Step 2: Allow time for network switch
    await Future.delayed(const Duration(seconds: 2));

    // Step 3: Call ESP using common hostname
    final response = await http
        .get(Uri.parse("http://$espHost/connect"))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception("ESP not responding");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 11, 61, 57),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Title
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

              // 🔹 Connect Button
              SizedBox(
                width: 200,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);

                          try {
                            await connectToESP();

                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MainScreen(),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }

                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
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

// ================= Braille Loading Animation =================

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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

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

// ================= Dot =================

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
