import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
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
              SizedBox(height: 30,),
              SizedBox(
  width: 200,
  height: 55,
  child: ElevatedButton(
    onPressed: () {
      
      debugPrint("Connect pressed");
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: const Color.fromARGB(255, 11, 61, 57),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 4,
    ),
    child: Text(
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
