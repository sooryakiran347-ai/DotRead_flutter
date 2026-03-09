import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart'; // for brailleCharacteristic

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _brailleOutput = "";

  // Braille display (UNICODE – UI only)
  final Map<String, String> _brailleMap = {
    "a": "\u2801", "b": "\u2803", "c": "\u2809", "d": "\u2819",
    "e": "\u2811", "f": "\u280B", "g": "\u281B", "h": "\u2813",
    "i": "\u280A", "j": "\u281A", "k": "\u2805", "l": "\u2807",
    "m": "\u280D", "n": "\u281D", "o": "\u2815", "p": "\u280F",
    "q": "\u281F", "r": "\u2817", "s": "\u280E", "t": "\u281E",
    "u": "\u2825", "v": "\u2827", "w": "\u283A", "x": "\u282D",
    "y": "\u283D", "z": "\u2835", " ": " ",
  };

  String _convertToBraille(String text) {
    String result = "";
    for (var c in text.toLowerCase().split('')) {
      result += _brailleMap[c] ?? "?";
    }
    return result;
  }

  // SEND RAW CHARACTERS TO ESP32
  void _onEnterPressed() async {
    final text = _inputController.text;

    setState(() {
      _brailleOutput = _convertToBraille(text);
    });

    if (brailleCharacteristic != null) {
      await brailleCharacteristic!
          .write(text.codeUnits, withoutResponse: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 11, 61, 57),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 30),

                TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    labelText: "Enter Text",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: 200,
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 230, 230, 230),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _brailleOutput,
                    style: GoogleFonts.robotoMono(
                      fontSize: 30,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onEnterPressed,
                    child: const Text("Enter"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
}