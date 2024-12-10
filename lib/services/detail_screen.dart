import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentwheels/services/PhonePePayment.dart';

//import 'package:rentwheels/services/qr_code_screen.dart';

class DetailScreen extends StatefulWidget {
  final String carId;
  final double totalPrice;
  final String phone_number;// To hold total price
  final String email;
  final String customerName;   // To hold payee name
  final String carName;     // To hold the car name
  final String carType;     // To hold the car type
  final String registrationNumber; // To hold the car's registration number
  final String startDate;   // To hold the start date
  final String endDate;     // To hold the end date

  const DetailScreen({
    super.key,
    required this.carId,
    required this.totalPrice,
    required this.phone_number,
    required this.email,
    required this.customerName,
    required this.carName,
    required this.carType,
    required this.registrationNumber,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController upiIdController;
  late TextEditingController payeeController;
  late TextEditingController amountController;

  @override
  void initState() {
    super.initState();
    upiIdController = TextEditingController(text: "kashyapnishant144@oksbi"); // Set UPI ID
    payeeController = TextEditingController(text: widget.customerName);  // Set payee name
    amountController = TextEditingController(text: widget.totalPrice.toString());  // Set amount to total price
  }

  @override
  void dispose() {
    upiIdController.dispose();
    payeeController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        centerTitle: true,
        title: Text(
          "PAYMENT DETAILS",
          style: GoogleFonts.mulish(fontSize: 14, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
        ),
      ),
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display car name, type, and registration number
            Text(
              "Car: ${widget.carName}",
              style: GoogleFonts.mulish(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Type: ${widget.carType}",
              style: GoogleFonts.mulish(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              "Registration No: ${widget.registrationNumber}",
              style: GoogleFonts.mulish(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Divider(
              thickness: 1.5,
              color: Colors.grey,
            ),
            // Display booking dates
            Text(
              "From: ${widget.startDate}",
              style: GoogleFonts.mulish(fontSize: 20, decoration: TextDecoration.underline),
            ),
            const SizedBox(height: 10),
            Text(
              "To: ${widget.endDate}",
              style: GoogleFonts.mulish(fontSize: 20, decoration: TextDecoration.underline),
            ),        
            Divider(
              thickness: 1.5,
              color: Colors.grey[400],
            ),
            // Display only the total price as text
            Text(
              "Total Price: ₹${widget.totalPrice.toStringAsFixed(2)}",
              style: GoogleFonts.mulish(fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
            ),
            const SizedBox(height: 30), // Add space before the button

            // Spacer to push the button to the bottom
            Spacer(),

            // "Scan QR Code" button placed at the bottom of the screen
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Blue background for the button
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners for the button
                  ),
                ),
                onPressed: () {
                  double amount = widget.totalPrice;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Phonepepayment(
                        customerName: widget.customerName,
                        phone_number: widget.phone_number,
                        email: widget.email,
                        carId: widget.carId,
                        carName: widget.carName,
                        startDate: widget.startDate,
                        endDate: widget.endDate,
                        //upiID: upiIdController.text,
                        //payeeName: payeeController.text,
                        amount: amount,
                      ),
                    ),
                  );
                },
                child: Text(
                  "PAY NOW",
                  style: GoogleFonts.mulish(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
