import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rentwheels/phonepe.dart'; // Make sure to import your PhonePePayment page

class BookingGatewayPage extends StatefulWidget {
  final String carId;

  const BookingGatewayPage({super.key, required this.carId});

  @override
  _BookingGatewayPageState createState() => _BookingGatewayPageState();
}

class _BookingGatewayPageState extends State<BookingGatewayPage> {
  bool _isDeliverySelected = false;
  final double _deliveryCost = 500.0; // Example cost for delivery
  String _paymentMethod = 'UPI';
  late Future<DocumentSnapshot> _carDetailsFuture;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _carDetailsFuture = _fetchCarDetails();
  }

  Future<DocumentSnapshot> _fetchCarDetails() {
    return FirebaseFirestore.instance.collection('Cars').doc(widget.carId).get();
  }

  double _calculateTotalPrice(double basePrice) {
    int numberOfDays = _startDate != null && _endDate != null
        ? _endDate!.difference(_startDate!).inDays + 1
        : 0;
    double totalPrice = basePrice * numberOfDays;
    if (_isDeliverySelected) {
      totalPrice += _deliveryCost;
    }
    return totalPrice;
  }

  Future<void> _selectDate({required bool isStartDate}) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime.now();
    DateTime lastDate = DateTime.now().add(const Duration(days: 365));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // Ensure start date is before end date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text(
          'RentWheels Booking Gateway',
          style: GoogleFonts.mulish(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
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

                // Displaying Car Rental Price Per Day
                Text(
                  'Rental Price Per Day: ₹${basePrice.toStringAsFixed(2)}',
                  style: GoogleFonts.mulish(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),

                // Date and Time Selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Start Date:',
                      style: GoogleFonts.mulish(fontSize: 18, color: Colors.black87),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(isStartDate: true),
                      child: Text(
                        _startDate != null
                            ? DateFormat('dd/MM/yyyy').format(_startDate!)
                            : 'Select Start Date',
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'End Date:',
                      style: GoogleFonts.mulish(fontSize: 18, color: Colors.black87),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(isStartDate: false),
                      child: Text(
                        _endDate != null
                            ? DateFormat('dd/MM/yyyy').format(_endDate!)
                            : 'Select End Date',
                      ),
                    ),
                  ],
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

                const Spacer(), // Push the button to the bottom

                // Confirm Booking Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_startDate == null || _endDate == null) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Incomplete Booking Details'),
                              content: Text('Please select both start and end dates.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }

                      if (_paymentMethod == 'UPI') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PhonePePayment(),
                          ),
                        );
                      } else {
                        // Handle other payment methods or show a confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Booking Confirmed'),
                              content: Text(
                                'Your booking for ${carData['model']} has been confirmed.\n'
                                'Total Price: ₹${_calculateTotalPrice(basePrice).toStringAsFixed(2)}\n'
                                'Payment Method: $_paymentMethod',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
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
