import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _brailleOutput = "";

  // Basic English to Braille mapping (Unicode Braille patterns)
  final Map<String, String> _brailleMap = {
    "a": "\u2801",
    "b": "\u2803",
    "c": "\u2809",
    "d": "\u2819",
    "e": "\u2811",
    "f": "\u280B",
    "g": "\u281B",
    "h": "\u2813",
    "i": "\u280A",
    "j": "\u281A",
    "k": "\u2805",
    "l": "\u2807",
    "m": "\u280D",
    "n": "\u281D",
    "o": "\u2815",
    "p": "\u280F",
    "q": "\u281F",
    "r": "\u2817",
    "s": "\u280E",
    "t": "\u281E",
    "u": "\u2825",
    "v": "\u2827",
    "w": "\u283A",
    "x": "\u282D",
    "y": "\u283D",
    "z": "\u2835",
    " ": " ", // space
  };

  @override
  void initState() {
    super.initState();

    // Listen to changes in input field
    _inputController.addListener(() {
      setState(() {
        _brailleOutput = _convertToBraille(_inputController.text);
      });
    });
  }

  // Convert input text to Braille
  String _convertToBraille(String text) {
    String result = "";
    for (var char in text.toLowerCase().split('')) {
      result += _brailleMap[char] ?? "?"; // Unknown characters -> ?
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromARGB(255, 11, 61, 57),
       
      body: SafeArea(
  child: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 30),

          // Input box
         TextField(
  controller: _inputController,
  decoration: InputDecoration(
    labelText: "Enter Text",
    filled: true,                  // enables background color
    fillColor: Colors.white,       // sets background to white
    labelStyle: TextStyle(color: Colors.grey.shade700),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade400),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color.fromARGB(255, 11, 61, 57), width: 2),
    ),
  ),
  style: const TextStyle(color: Colors.black), // text color inside the field
),

          const SizedBox(height: 20),

          // Output box
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 200, // minimum height for output box
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 230, 230, 230),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: SingleChildScrollView(
              child: Text(
                _brailleOutput,
                style: GoogleFonts.robotoMono(
                  fontSize: 30,
                  letterSpacing: 2,
                  height: 1.5,
                ),
              ),
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
