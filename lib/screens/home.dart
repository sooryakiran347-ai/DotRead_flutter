import 'dart:async';
import 'package:braille/screens/screen2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// 🔹 GLOBAL CHARACTERISTIC (USED IN screen2.dart)
BluetoothCharacteristic? brailleCharacteristic;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool _isLoading = false;
  BluetoothDevice? connectedDevice;
  StreamSubscription? scanSubscription;

  // 🔹 UUIDs (MUST MATCH ESP32)
  final Guid serviceUuid =
      Guid("12345678-1234-1234-1234-123456789abc");
  final Guid characteristicUuid =
      Guid("abcdef01-1234-1234-1234-123456789abc");

  // ------------------ PERMISSIONS ------------------

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  // ------------------ BLE CONNECT ------------------

  Future<void> _connectToESP32() async {
    setState(() => _isLoading = true);

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
    );

    scanSubscription =
        FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult result in results) {
        if (result.device.name == "ESP32_DOT_READ") {
          await FlutterBluePlus.stopScan();
          await scanSubscription?.cancel();

          connectedDevice = result.device;

          try {
            await connectedDevice!.connect();

            await _discoverServices();

            if (!mounted) return;

            setState(() => _isLoading = false);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MainScreen(),
              ),
            );
          } catch (e) {
            setState(() => _isLoading = false);
          }
          break;
        }
      }
    });
  }

  // ------------------ DISCOVER SERVICES ------------------

  Future<void> _discoverServices() async {
    List<BluetoothService> services =
        await connectedDevice!.discoverServices();

    for (BluetoothService service in services) {
      if (service.uuid == serviceUuid) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid == characteristicUuid) {
            brailleCharacteristic = characteristic;
            debugPrint("Braille characteristic ready");
            return;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    connectedDevice?.disconnect();
    super.dispose();
  }

  // ------------------ UI (UNCHANGED) ------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 11, 61, 57),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

              SizedBox(
                width: 200,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          bool granted =
                              await _requestPermissions();
                          if (!granted) return;

                          await _connectToESP32();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor:
                        const Color.fromARGB(255, 11, 61, 57),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          "Connect",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
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