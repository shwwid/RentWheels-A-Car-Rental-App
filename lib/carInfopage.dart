import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentwheels/booking_gateway.dart';

class CarInfoPage extends StatefulWidget {
  final String CarId;

  const CarInfoPage({super.key, required this.CarId});

  @override
  _CarInfoPageState createState() => _CarInfoPageState();
}

class _CarInfoPageState extends State<CarInfoPage> {
  // Fetch car details from Firestore
  Future<DocumentSnapshot> _fetchCarDetails() {
    return FirebaseFirestore.instance.collection('Cars').doc(widget.CarId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<DocumentSnapshot>(
        future: _fetchCarDetails(),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car Model and Brand
                SizedBox(height: 16),
                Center(
                  child: Text(
                    carData['model'] ?? 'Unknown Model',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    carData['brand'] ?? 'Unknown Brand',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Car Image with a nice border
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(carData['imageURL'] ?? '', height: 250, fit: BoxFit.cover),
                ),
                const SizedBox(height: 16.0),

                // Specifications Bar
                _buildSpecificationBar(carData),
                const SizedBox(height: 24.0),

                // Price and Book Now Button
                _buildPriceAndButton(double.tryParse(carData['price'].toString()) ?? 0.0),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget to build specifications bar
  Widget _buildSpecificationBar(Map<String, dynamic> carData) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Specifications", style: GoogleFonts.mulish(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8.0),
            _buildSpecRow("Brand", carData['brand'] ?? 'N/A'),
            _buildSpecRow("Model", carData['model'] ?? 'N/A'),
            _buildSpecRow("Fuel Type", carData['fuelType'] ?? 'N/A'),
            _buildSpecRow("Transmission", carData['transmission'] ?? 'N/A'),
            _buildSpecRow("Seats", carData['seats']?.toString() ?? 'N/A'),
            _buildSpecRow("Mileage(km/l)", carData['mileage']?.toString() ?? 'N/A'),
            _buildSpecRow("Car Type", carData['carType'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  // Helper function to display a row of specification
  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.mulish(fontSize: 16, color: Colors.black54)),
          Text(value, style: GoogleFonts.mulish(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Widget for Price and Book Now Button
  Widget _buildPriceAndButton(double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Displaying the price on the left
        Text(
          "Price: ₹${price.toStringAsFixed(2)} per day",
          style: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        // The "Book Now" button on the right
        ElevatedButton(
          onPressed: () {
            // Navigate to the BookingGatewayPage
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingGatewayPage(carId: widget.CarId),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 8,
          ),
          child: const Text("Book Now", style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
