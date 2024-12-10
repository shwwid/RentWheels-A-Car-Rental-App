import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rentwheels/showroom.dart';

class BookingConfirmationPage extends StatefulWidget {
  final String carId;
  final String customerName;
  final String phone_number;
  final String email;
  final String amount;
  final String carName;
  final String startDate;
  final String endDate;

  const BookingConfirmationPage({
    super.key,
    required this.carId,
    required this.customerName,
    required this.phone_number,
    required this.email,
    required this.amount,
    required this.carName,
    required this.startDate,
    required this.endDate,
  });

  @override
  _BookingConfirmationPageState createState() => _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  @override
  void initState() {
    super.initState();

    // Save the booking and order to Firestore
    _saveBookingToFirestore();
    _setBookState();

    // Generate the invoice and notify the user
    _generateAndNotifyInvoice();

    // Redirect to the homepage after 5 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Showroom()),
      );
    });
  }

  Future<void> _setBookState() async {
    try {
      final carDocRef = FirebaseFirestore.instance.collection('Cars').doc(
          widget.carId);
      await carDocRef.update({'bookedState': 'booked'});
      print("Car booking state updated successfully.");
    } catch (e) {
      print("Error updating bookedState: $e");
    }
  }

  Future<void> _saveBookingToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userEmail = user.email;
        if (userEmail != null) {
          // First, save the order in the 'orders' collection to get the orderId
          final orderData = {
            'carId': widget.carId,
            'carName': widget.carName,
            'customerName': widget.customerName,
            'phone_number': widget.phone_number,
            'customerEmail': widget.email,
            'amount': widget.amount,
            'startDate': widget.startDate,
            'endDate': widget.endDate,
            'timestamp': FieldValue.serverTimestamp(),
          };

          // Add the order to Firestore and get the generated orderId
          final orderDocRef = await FirebaseFirestore.instance
              .collection('orders')
              .add(orderData);

          // Get the generated orderId from the order document reference
          final orderId = orderDocRef.id;

          // Create the booking data first without bookingId
          final bookingData = {
            'orderId': orderId,
            'carId': widget.carId,
            'carName': widget.carName,
            'customerName': widget.customerName,
            'phone_number': widget.phone_number,
            'customerEmail': widget.email,
            'amount': widget.amount,
            'startDate': widget.startDate,
            'endDate': widget.endDate,
            'timestamp': FieldValue.serverTimestamp(),
          };

          // Save the booking data and retrieve the bookingId
          final bookingDocRef = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userEmail)
              .collection('bookings')
              .add(bookingData);

          final bookingId = bookingDocRef.id;

          // Update the order with the bookingId
          await orderDocRef.update({'bookingId': bookingId});

          // Update the booking with the orderId (this step is technically unnecessary as orderId is already in the data)
          await bookingDocRef.update({'orderId': orderId});

          print("Booking and Order saved successfully with IDs.");
        } else {
          print("Error: User email is null.");
        }
      } else {
        print("Error: No user is logged in.");
      }
    } catch (e) {
      print("Error saving booking: $e");
    }
  }


  Future<void> _generateAndNotifyInvoice() async {
    // Show a notification that the invoice is being downloaded
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Generating and downloading your invoice...")),
    );

    // Generate the invoice
    final pdfFile = await _generateInvoice();

    if (pdfFile != null) {
      // Show another notification that the download is complete
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invoice downloaded to ${pdfFile.path}")),
      );
    } else {
      // Notify user of failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to generate invoice.")),
      );
    }
  }

  Future<File?> _generateInvoice() async {
    final pdf = pw.Document();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userEmail = user.email;
      final dateOfBooking = DateTime.now().toString();

      // Generate the PDF content
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text('Booking Invoice', style: pw.TextStyle(
                    fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text('Customer: ${widget.customerName}'),
                pw.Text('Phone Number: ${widget.phone_number}'),
                pw.Text('Car: ${widget.carName}'),
                pw.Text('Amount: ₹${widget.amount}'),
                pw.Text('Start Date: ${widget.startDate}'),
                pw.Text('End Date: ${widget.endDate}'),
                pw.Text('Date of Booking: $dateOfBooking'),
              ],
            );
          },
        ),
      );

      // Save PDF to file
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final filePath = "${directory.path}/Invoice_${widget.carId}.pdf";
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());

        print("Invoice PDF saved at $filePath");

        // Return the generated file
        return file;
      }
    }

    return null; // Return null if file creation fails
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return false to prevent the back button from working
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),
              Text(
                "Your car is booked!",
                style: TextStyle(fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                "Redirecting to the homepage. Please Wait...",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
