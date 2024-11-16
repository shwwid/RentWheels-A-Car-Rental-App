import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

// Define the primary color globally
const Color kPrimaryColor = Color(0xFF1A73E8);
const Color kBackgroundColor = Color(0xFFF0F0F0);

class UpdateVehicle extends StatefulWidget {
  final String registrationNumber;

  // Constructor to accept the vehicle document ID
  const UpdateVehicle({super.key, required this.registrationNumber});

  @override
  State<UpdateVehicle> createState() => _UpdateVehicleState();
}

class _UpdateVehicleState extends State<UpdateVehicle> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _transmissionController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final TextEditingController _registrationNumberController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
void initState() {
  super.initState();
  if (widget.registrationNumber.isNotEmpty) {
    _loadVehicleData();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid registration number')),
    );
  }
}


  // Load the current vehicle data from Firestore
  Future<void> _loadVehicleData() async {
    try {
      DocumentSnapshot vehicleDoc = await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('user_vehicles')
          .doc(widget.registrationNumber)
          .get();

      if (vehicleDoc.exists) {
        // Fill the text controllers with existing data
        var vehicleData = vehicleDoc.data() as Map<String, dynamic>;
        _brandController.text = vehicleData['brand'] ?? '';
        _modelController.text = vehicleData['model'] ?? '';
        _priceController.text = vehicleData['price'] ?? '';
        _transmissionController.text = vehicleData['transmission'] ?? '';
        _seatsController.text = vehicleData['seats'] ?? '';
        _mileageController.text = vehicleData['mileage'] ?? '';
        _fuelTypeController.text = vehicleData['fuelType'] ?? '';
        _registrationNumberController.text = vehicleData['registrationNumber'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load vehicle data')),
      );
    }
  }

  // Update the vehicle data in Firestore
  Future<void> _updateVehicle() async {
  String brand = _brandController.text;
  String model = _modelController.text;
  String price = _priceController.text;
  String transmission = _transmissionController.text;
  String seats = _seatsController.text;
  String mileage = _mileageController.text;
  String fuelType = _fuelTypeController.text;
  String registrationNumber = _registrationNumberController.text;

  if (brand.isEmpty || model.isEmpty || price.isEmpty || transmission.isEmpty || seats.isEmpty || mileage.isEmpty || fuelType.isEmpty || registrationNumber.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all fields')),
    );
    return;
  }

  if (widget.registrationNumber.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid registration number')),
    );
    return;
  }

  try {
    // Reference to the current vehicle document
    DocumentReference vehicleRef = _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('user_vehicles')
        .doc(widget.registrationNumber);

    // Update the vehicle data in Firestore
    await vehicleRef.update({
      'brand': brand,
      'model': model,
      'price': price,
      'transmission': transmission,
      'seats': seats,
      'mileage': mileage,
      'fuelType': fuelType,
      'registrationNumber': registrationNumber,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vehicle updated successfully')),
    );

    // Optionally, you could navigate back after the update
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to update vehicle')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Update Vehicle",
          style: GoogleFonts.mulish(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(_brandController, 'Vehicle Brand'),
            const SizedBox(height: 16),
            _buildTextField(_modelController, 'Vehicle Model'),
            const SizedBox(height: 16),
            _buildTextField(_priceController, 'Vehicle Price', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(_transmissionController, 'Transmission Type'),
            const SizedBox(height: 16),
            _buildTextField(_seatsController, 'Number of Seats', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(_mileageController, 'Mileage (km/l)', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(_fuelTypeController, 'Fuel Type'),
            const SizedBox(height: 16),
            _buildTextField(_registrationNumberController, 'Registration Number'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _updateVehicle,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Update Vehicle',
                style: GoogleFonts.mulish(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.mulish(
            fontSize: 16,
            color: Colors.grey,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
