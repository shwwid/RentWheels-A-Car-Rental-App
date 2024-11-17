import 'package:flutter/material.dart';
import 'showroom.dart';  // Ensure you import your showroom page
import 'package:google_fonts/google_fonts.dart';

// Define the primary color globally
const Color kPrimaryColor = Color(0xFF1A73E8); // Replace with your desired primary color

class GoBackToUser extends StatelessWidget {
  const GoBackToUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: Text(
          "Go Back to User",
          style: GoogleFonts.mulish(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Show Snackbar message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "You are now a user",
                  style: GoogleFonts.mulish(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.black, // Set Snackbar background color
                duration: const Duration(seconds: 2), // Duration for the Snackbar
              ),
            );
            
            // Navigate to the Showroom Page after showing the Snackbar
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Showroom()),
              );
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor, // Set the button background color
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 5, // Add shadow to the button
          ),
          child: Text(
            "Go Back to User Page",
            style: GoogleFonts.mulish(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}


