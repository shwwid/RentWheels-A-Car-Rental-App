import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kPrimaryColor = Color(0xFF1A73E8);
const Color kBackgroundColor = Color(0xFFF0F0F0);

class UpdateVehicle extends StatefulWidget {
  final String carDocId; // Pass the carDocId to the widget

  const UpdateVehicle({super.key, required this.carDocId});

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
  final TextEditingController _carTypeController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    if (widget.carDocId.isNotEmpty) {
      _loadVehicleData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid car document ID')),
      );
    }
  }

  Future<void> _loadVehicleData() async {
    try {
      if (currentUser != null) {
        // Fetch the vehicle using the carDocId directly
        DocumentSnapshot vehicleDoc = await _firestore
            .collection('users')
            .doc(currentUser!.email) // or use UID: currentUser!.uid
            .collection('Cars') // Cars collection under user
            .doc(widget.carDocId) // Use carDocId directly
            .get();

        if (vehicleDoc.exists) {
          var vehicleData = vehicleDoc.data() as Map<String, dynamic>;
          setState(() {
            _brandController.text = vehicleData['brand'] ?? '';
            _modelController.text = vehicleData['model'] ?? '';
            _priceController.text = vehicleData['price'] ?? '';
            _transmissionController.text = vehicleData['transmission'] ?? '';
            _seatsController.text = vehicleData['seats'] ?? '';
            _mileageController.text = vehicleData['mileage'] ?? '';
            _fuelTypeController.text = vehicleData['fuelType'] ?? '';
            _registrationNumberController.text = vehicleData['registrationNumber'] ?? '';
            _carTypeController.text = vehicleData['carType'] ?? ''; // Load carType
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle not found')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load vehicle data: $e')),
      );
    }
  }

  Future<void> _updateVehicle() async {
    String brand = _brandController.text.trim();
    String model = _modelController.text.trim();
    String price = _priceController.text.trim();
    String transmission = _transmissionController.text.trim();
    String seats = _seatsController.text.trim();
    String mileage = _mileageController.text.trim();
    String fuelType = _fuelTypeController.text.trim();
    String registrationNumber = _registrationNumberController.text.trim();
    String carType = _carTypeController.text.trim(); // Get the carType value

    if (brand.isEmpty || model.isEmpty || price.isEmpty || transmission.isEmpty || seats.isEmpty || mileage.isEmpty || fuelType.isEmpty || registrationNumber.isEmpty || carType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      if (currentUser != null) {
        DocumentReference vehicleRef = _firestore
            .collection('users')
            .doc(currentUser!.email) // or use UID: currentUser!.uid
            .collection('Cars')
            .doc(widget.carDocId)  // Use carDocId directly
            .collection('vehicleDetails')  // Subcollection for car details
            .doc(registrationNumber);  // Using registration number as the document ID for clarity

        // Update the vehicle data
        await vehicleRef.update({
          'brand': brand,
          'model': model,
          'price': price,
          'transmission': transmission,
          'seats': seats,
          'mileage': mileage,
          'fuelType': fuelType,
          'registrationNumber': registrationNumber,
          'carType': carType,  // Add carType to the update
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update vehicle: $e')),
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
            const SizedBox(height: 16),
            _buildTextField(_carTypeController, 'Car Type'),
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

