import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingGatewayPage extends StatefulWidget {
  final String carId;

  const BookingGatewayPage({super.key, required this.carId});

  @override
  _BookingGatewayPageState createState() => _BookingGatewayPageState();
}

class _BookingGatewayPageState extends State<BookingGatewayPage> {
  bool _isDeliverySelected = false;
  double _deliveryCost = 500.0; // Example cost for delivery
  String _paymentMethod = 'UPI';

  late Future<DocumentSnapshot> _carDetailsFuture;

  @override
  void initState() {
    super.initState();
    _carDetailsFuture = _fetchCarDetails();
  }

  Future<DocumentSnapshot> _fetchCarDetails() {
    return FirebaseFirestore.instance.collection('Cars').doc(widget.carId).get();
  }

  double _calculateTotalPrice(double basePrice) {
    return basePrice + (_isDeliverySelected ? _deliveryCost : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text(
          'RentWheels Booking Gateway',
          style: GoogleFonts.mulish(color: Colors.black, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey[300],
      body: FutureBuilder<DocumentSnapshot>(
        future: _carDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading car details.'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Car not found.'));
          }

          var carData = snapshot.data!.data() as Map<String, dynamic>;
          double basePrice = double.tryParse(carData['price'].toString()) ?? 0.0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${carData['brand']} ${carData['model']}',
                  style: GoogleFonts.mulish(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),

                // Delivery Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Self-pickup or Car Delivery?',
                      style: GoogleFonts.mulish(fontSize: 18, color: Colors.black87),
                    ),
                    Switch(
                      value: _isDeliverySelected,
                      onChanged: (value) {
                        setState(() {
                          _isDeliverySelected = value;
                        });
                      },
                    ),
                  ],
                ),
                if (_isDeliverySelected)
                  Text(
                    'Delivery Cost: ₹$_deliveryCost',
                    style: GoogleFonts.mulish(fontSize: 16, color: Colors.black54),
                  ),

                const SizedBox(height: 16.0),

                // Total Price Display
                Text(
                  'Total Price: ₹${_calculateTotalPrice(basePrice).toStringAsFixed(2)}',
                  style: GoogleFonts.mulish(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 24.0),

                // Payment Options
                Text(
                  'Choose Payment Method',
                  style: GoogleFonts.mulish(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ListTile(
                  title: const Text('UPI'),
                  leading: Radio<String>(
                    value: 'UPI',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Card'),
                  leading: Radio<String>(
                    value: 'Card',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                  ),
                ),

                const Spacer(), // This pushes the button to the bottom of the screen

                // Confirm Booking Button (placed at the bottom)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement booking confirmation and payment handling logic here
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Booking Confirmed'),
                            content: Text('Your booking for ${carData['model']} has been confirmed.\nTotal Price: ₹${_calculateTotalPrice(basePrice).toStringAsFixed(2)}\nPayment Method: $_paymentMethod'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      elevation: 5,
                    ),
                    child: const Text("Confirm Booking", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
