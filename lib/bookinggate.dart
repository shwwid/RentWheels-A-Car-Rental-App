import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:rentwheels/constants.dart';
import 'package:rentwheels/data.dart';
//import 'package:rentwheels/services/upi.txt';

class BookingGateway extends StatefulWidget {
  final Car car;
  final int basePrice; // Base price for the car

  const BookingGateway({
    super.key,
    required this.car,
    required this.basePrice,
  });

  @override
  State<BookingGateway> createState() => _BookingGatewayState();
}

class _BookingGatewayState extends State<BookingGateway> {
  bool isDelivery = false; // Toggle for self-pick-up or delivery
  double deliveryFee = 150.0; // Example delivery fee

  // Payment mode selection variable
  String selectedPaymentMode = 'UPI';

  double get totalPrice {
    // Calculate total price based on selection
    return widget.basePrice + (isDelivery ? deliveryFee : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text(
          'Booking Confirmation',
          style: GoogleFonts.mulish(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Car Model: ${widget.car.brand} ${widget.car.model}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Base Price: ₹${widget.basePrice.toStringAsFixed(1)}',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Pick-up Option:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            RadioListTile(
              title: Text('Self Pick-up'),
              value: false,
              groupValue: isDelivery,
              onChanged: (bool? value) {
                setState(() {
                  isDelivery = value ?? false;
                });
              },
              activeColor: CupertinoColors.activeBlue,
            ),
            RadioListTile(
              title: Text('Delivery (Additional ₹${deliveryFee.toStringAsFixed(2)})'),
              value: true,
              groupValue: isDelivery,
              onChanged: (bool? value) {
                setState(() {
                  isDelivery = value ?? false;
                });
              },
              activeColor: CupertinoColors.activeBlue,
            ),
            const SizedBox(height: 20),
            Divider(),
            Text(
              'Select Payment Mode:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            RadioListTile(
              title: Text('UPI'),
              value: 'UPI',
              groupValue: selectedPaymentMode,
              onChanged: (String? value) {
                setState(() {
                  selectedPaymentMode = value ?? 'UPI';
                });
              },
              activeColor: CupertinoColors.activeBlue,
            ),
            RadioListTile(
              title: Text('Card'),
              value: 'Card',
              groupValue: selectedPaymentMode,
              onChanged: (String? value) {
                setState(() {
                  selectedPaymentMode = value ?? 'UPI';
                });
              },
              activeColor: CupertinoColors.activeBlue,
            ),
            const SizedBox(height: 20),
            Divider(),
            Text(
              'Total Price: ₹${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            /*Center(
              child: ElevatedButton(
                onPressed: () {
                  if (selectedPaymentMode == 'UPI') {
                    // Navigate to the UPI page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UPI(
                          car: widget.car,
                          totalAmount: totalPrice,
                        ),
                      ),
                    );
                  } else {
                    // Show confirmation for other payment methods
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Booking Confirmed'),
                        content: Text(
                            'Your booking for ${widget.car.brand} ${widget.car.model} has been confirmed.\nTotal: ₹${totalPrice.toStringAsFixed(2)}\nPayment Mode: $selectedPaymentMode'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text(
                  'Confirm Booking',
                  style: GoogleFonts.mulish(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
