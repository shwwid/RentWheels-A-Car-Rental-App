import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rentwheels/auth.dart';
import 'package:rentwheels/carInfopage.dart';
import 'package:rentwheels/showroom.dart';

class BookingCancelledPage extends StatefulWidget {
  @override
  _BookingCancelledPageState createState() => _BookingCancelledPageState();
}

class _BookingCancelledPageState extends State<BookingCancelledPage> {
  @override
  void initState() {
    super.initState();
    // Redirect to homepage after 5 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Showroom()), // Replace with your homepage widget
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cross mark icon
              Icon(
                Icons.cancel,
                color: Colors.red,
                size: 100,
              ),
              const SizedBox(height: 20),
              // Failure message
              Text(
                "Transaction Failed!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Subtext with redirection info
              Text(
                "Redirecting to the homepage...",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
