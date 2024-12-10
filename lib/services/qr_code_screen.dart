import 'dart:async';
import 'package:flutter/material.dart';
import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';
import 'package:rentwheels/showroom.dart'; // Replace with your actual import path for the ShowroomPage

class QrCodeScreen extends StatefulWidget {
  final String upiID, payeeName;
  final double amount;

  const QrCodeScreen({super.key, required this.upiID, required this.payeeName, required this.amount});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  late UPIDetails upiDetails;
  int remainingTime = 60; // Set the timer duration (in seconds)
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    upiDetails = UPIDetails(upiID: widget.upiID, payeeName: widget.payeeName, amount: widget.amount);

    // Start the timer
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime == 0) {
        _timer.cancel(); // Stop the timer
        _redirectToShowroom(); // Redirect to the ShowroomPage after expiration
      } else {
        setState(() {
          remainingTime--; // Decrease the time
        });
      }
    });
  }

  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Transaction'),
          content: const Text('Are you sure you want to cancel the transaction?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
                _showRedirectingDialog(); // Show redirecting dialog
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _showRedirectingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Redirecting...'),
          content: const Text('The transaction has been canceled. You will be redirected to the homepage.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Showroom()), // Replace with your actual ShowroomPage
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _redirectToShowroom() {
    // Display a message before redirecting
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Redirecting...'),
          content: const Text('The QR code has expired. You will be redirected to the homepage.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Showroom()), // Replace with your actual ShowroomPage
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable back button navigation
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),

                  // Logo
                  const Text(
                    'Please Scan the QR Code',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'below',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // QR Code or Expiry Message
                  remainingTime > 0
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            UPIPaymentQRCode(
                              upiDetails: upiDetails,
                              size: 200,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "QR Code will expire in $remainingTime seconds",
                              style: const TextStyle(fontSize: 18, color: Colors.red),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.timer_off,
                              size: 100,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "QR Code Expired",
                              style: TextStyle(fontSize: 22, color: Colors.red),
                            ),
                          ],
                        ),

                  const SizedBox(height: 30),

                  // Cancel Button
                  if (remainingTime > 0 && remainingTime < 50)
                    ElevatedButton(
                      onPressed: _showCancelConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
