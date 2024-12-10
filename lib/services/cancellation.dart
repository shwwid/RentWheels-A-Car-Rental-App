import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Cancellation extends StatefulWidget {
  final String orderId;
  final String carName;

  const Cancellation({
      super.key,
      required this.orderId,
      required this.carName,
    }
  );

  @override
  State<Cancellation> createState() => _CancellationState();
}

class _CancellationState extends State<Cancellation> {
  final TextEditingController _descriptionController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSubmitEnabled = false;

  @override
  void initState() {
    super.initState();
    // Add listener to track the text field's word count
    _descriptionController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // Function to validate word count
  void _validateInput() {
    final words = _descriptionController.text.trim().split(RegExp(r'\s+'));
    setState(() {
      _isSubmitEnabled = words.length >= 5; // Enable button only if 15 or more words
    });
  }

  // Function to store cancellation request in Firestore
  Future<void> _storeCancellationRequest() async {
    if (!_isSubmitEnabled) return;

    // Get current user email
    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    String userEmail = user.email ?? '';
    String orderId = widget.orderId;
    String carName = widget.carName;

    // Store data in Firestore
    try {
      await FirebaseFirestore.instance.collection('cancellation').add({
        'description': _descriptionController.text.trim(),
        'email': userEmail,
        'orderId': orderId,
        'carName': carName,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Show confirmation dialog and clear the text field
      _showConfirmationDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error storing the cancellation request.")),
      );
    }
  }

  // Function to show a success dialog and clear the text field
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Request Sent"),
          content: const Text("Your cancellation request has been sent successfully."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _descriptionController.clear(); // Clear the text field
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Cancellation Request",
          style: GoogleFonts.mulish(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reason for Cancellation",
              style: GoogleFonts.mulish(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Reason for cancellation (minimum 5 words)...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isSubmitEnabled
                    ? () async {
                  await _storeCancellationRequest();
                }
                    : null, // Disable button when not enabled
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Submit Request",
                  style: GoogleFonts.mulish(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
