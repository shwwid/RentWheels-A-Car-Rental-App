import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

const Color kPrimaryColor = Color(0xFF1A73E8);
const Color kBackgroundColor = Color(0xFFF0F0F0);

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _selectedImage;

  User? get currentUser => _auth.currentUser;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadImage(File image) async {
    try {
      String filePath = 'vehicle_images/${DateTime.now().millisecondsSinceEpoch}.png';
      UploadTask uploadTask = _storage.ref().child(filePath).putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
      return null;
    }
  }

  Future<void> addVehicle() async {
  String brand = _brandController.text;
  String model = _modelController.text;
  String price = _priceController.text;
  String transmission = _transmissionController.text;
  String seats = _seatsController.text;
  String mileage = _mileageController.text;
  String fuelType = _fuelTypeController.text;
  String registrationNumber = _registrationNumberController.text;
  String carType = _carTypeController.text;

  if (currentUser == null || currentUser?.email == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not authenticated or missing email')),
    );
    return;
  }

  if (brand.isEmpty || model.isEmpty || price.isEmpty || transmission.isEmpty || seats.isEmpty || mileage.isEmpty || fuelType.isEmpty || registrationNumber.isEmpty || carType.isEmpty || _selectedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all fields and select an image')),
    );
    return;
  }

  try {
    String userEmail = currentUser!.email!;
    String? imageUrl = await uploadImage(_selectedImage!);

    if (imageUrl != null) {
      // Adding vehicle to the user's specific collection first
      DocumentReference userCarRef = await _firestore.collection('Users').doc(userEmail).collection('Cars').add({
        'brand': brand,
        'model': model,
        'price': price,
        'transmission': transmission,
        'seats': seats,
        'mileage': mileage,
        'fuelType': fuelType,
        'registrationNumber': registrationNumber,
        'carType': carType,
        'imageURL': imageUrl, // Save the image URL
      });

      // After the vehicle is added to the user's collection, retrieve its document ID
      String userCarId = userCarRef.id;

      // Now add the vehicle to the global 'Cars' collection and set 'userCarId' to the user's car document ID
      await _firestore.collection('Cars').add({
        'brand': brand,
        'model': model,
        'price': price,
        'transmission': transmission,
        'seats': seats,
        'mileage': mileage,
        'fuelType': fuelType,
        'registrationNumber': registrationNumber,
        'carType': carType,
        'owner': userEmail,
        'imageURL': imageUrl, // Save the image URL
        'userCarId': userCarId, // Set the document ID of the user's specific car entry
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle added successfully')),
      );

      // Clear all input fields after adding the vehicle
      _brandController.clear();
      _modelController.clear();
      _priceController.clear();
      _transmissionController.clear();
      _seatsController.clear();
      _mileageController.clear();
      _fuelTypeController.clear();
      _registrationNumberController.clear();
      _carTypeController.clear();
      setState(() {
        _selectedImage = null;
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to add vehicle')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Add Vehicle",
          style: GoogleFonts.mulish(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.white),
      ),
      resizeToAvoidBottomInset: true,
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
            const SizedBox(height: 16),
            _selectedImage == null
                ? const Text('No image selected', style: TextStyle(color: Colors.red))
                : Image.file(_selectedImage!, height: 150),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Pick Image', style: GoogleFonts.mulish()),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: addVehicle,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Add Vehicle',
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
