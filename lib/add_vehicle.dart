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
  // Controllers for input fields
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _transmissionController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final TextEditingController _registrationNumberController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _carTypeController = TextEditingController();

  // Firebase references
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Image picker and storage
  final List<File> _selectedImages = [];
  bool _isLoading = false;

  Future<void> pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((e) => File(e.path)).toList());
      });
    }
  }

  Future<List<String>> uploadImages(List<File> images) async {
    List<String> imageUrls = [];
    for (var image in images) {
      String filePath = 'vehicle_images/${DateTime.now().millisecondsSinceEpoch}_${image.hashCode}.png';
      UploadTask uploadTask = _storage.ref().child(filePath).putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }
    return imageUrls;
  }

  Future<void> addVehicle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      String userEmail = currentUser.email ?? '';
      String brand = _brandController.text;
      String model = _modelController.text;
      String price = _priceController.text;
      String transmission = _transmissionController.text;
      String seats = _seatsController.text;
      String mileage = _mileageController.text;
      String fuelType = _fuelTypeController.text;
      String registrationNumber = _registrationNumberController.text;
      String year = _yearController.text;
      String carType = _carTypeController.text;

      // Validation
      if ([
        brand,
        model,
        price,
        transmission,
        seats,
        mileage,
        fuelType,
        registrationNumber,
        year,
        carType
      ].any((field) => field.isEmpty) ||
          _selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields and select images')),
        );
        return;
      }

      List<String> imageUrls = await uploadImages(_selectedImages);

      // Save vehicle details to Firestore
      await _firestore.collection('Cars').add({
        'brand': brand,
        'model': model,
        'price': price,
        'transmission': transmission,
        'seats': seats,
        'mileage': mileage,
        'fuelType': fuelType,
        'registrationNumber': registrationNumber,
        'year': year,
        'carType': carType,
        'owner': userEmail,
        'imageURLs': imageUrls,
        'bookedState': 'available',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle added successfully!')),
      );

      // Clear inputs
      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding vehicle: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _brandController.clear();
    _modelController.clear();
    _priceController.clear();
    _transmissionController.clear();
    _seatsController.clear();
    _mileageController.clear();
    _fuelTypeController.clear();
    _registrationNumberController.clear();
    _yearController.clear();
    _carTypeController.clear();
    setState(() {
      _selectedImages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Add Vehicle",
          style: GoogleFonts.mulish(fontWeight: FontWeight.bold,
          color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(_brandController, 'Vehicle Brand'),
                  const SizedBox(height: 10),
                  _buildTextField(_modelController, 'Vehicle Model'),
                  const SizedBox(height: 10),
                  _buildTextField(_priceController, 'Vehicle Price', TextInputType.number),
                  const SizedBox(height: 10),
                  _buildTextField(_transmissionController, 'Transmission Type'),
                  const SizedBox(height: 10),
                  _buildTextField(_seatsController, 'Number of Seats', TextInputType.number),
                  const SizedBox(height: 10),
                  _buildTextField(_mileageController, 'Mileage (km/l)', TextInputType.number),
                  const SizedBox(height: 10),
                  _buildTextField(_fuelTypeController, 'Fuel Type'),
                  const SizedBox(height: 10),
                  _buildTextField(_registrationNumberController, 'Registration Number'),
                  const SizedBox(height: 10),
                  _buildTextField(_yearController, 'Year', TextInputType.number),
                  const SizedBox(height: 10),
                  _buildTextField(_carTypeController, 'Car Type'),
                  const SizedBox(height: 10),
                  _selectedImages.isEmpty
                      ? const Text('No images selected', style: TextStyle(color: Colors.red))
                      : Wrap(
                          spacing: 8,
                          children: _selectedImages
                              .map((image) => Image.file(image, height: 100, width: 100, fit: BoxFit.cover))
                              .toList(),
                        ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: pickImages,
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                    child: Text('Upload Images',
                    style: GoogleFonts.mulish(color: Colors.white
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: addVehicle,
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                    child: Text('Add Vehicle',
                    style: GoogleFonts.mulish(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [TextInputType inputType = TextInputType.text]) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
