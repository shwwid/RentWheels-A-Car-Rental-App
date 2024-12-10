import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kPrimaryColor = Color(0xFF1A73E8);
const Color kBackgroundColor = Color(0xFFF0F0F0);

class UpdateVehiclePage extends StatefulWidget {
  final String vehicleId; // ID of the vehicle to be updated

  const UpdateVehiclePage({Key? key, required this.vehicleId}) : super(key: key);

  @override
  State<UpdateVehiclePage> createState() => _UpdateVehiclePageState();
}

class _UpdateVehiclePageState extends State<UpdateVehiclePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for text fields
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  //final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVehicleData();
  }

  // Fetch vehicle data from Firestore
  Future<void> _fetchVehicleData() async {
    try {
      DocumentSnapshot doc = await _firestore.collection('Cars').doc(widget.vehicleId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          _brandController.text = data['brand'] ?? '';
          _modelController.text = data['model'] ?? '';
          _priceController.text = data['price'].toString() ?? '';
          //_descriptionController.text = data['description'] ?? '';
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle not found.')),
        );
        Navigator.pop(context); // Close the page if the vehicle doesn't exist
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load vehicle data: $e')),
      );
      Navigator.pop(context); // Close the page on error
    }
  }

  // Save updated vehicle data to Firestore
  Future<void> _saveVehicleData() async {
    try {
      await _firestore.collection('Cars').doc(widget.vehicleId).update({
        'brand': _brandController.text,
        'model': _modelController.text,
        'price': _priceController.text,
        //'description': _descriptionController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle updated successfully.')),
      );
      Navigator.pop(context); // Close the page after saving
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update vehicle: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text(
          'Update Vehicle',
          style: GoogleFonts.mulish(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand Field
                    TextField(
                      controller: _brandController,
                      decoration: InputDecoration(
                        labelText: 'Brand',
                        labelStyle: GoogleFonts.mulish(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Model Field
                    TextField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        labelText: 'Model',
                        labelStyle: GoogleFonts.mulish(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price Field
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price (₹)',
                        labelStyle: GoogleFonts.mulish(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description Field
                    /*TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: GoogleFonts.mulish(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),*/

                    // Save Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveVehicleData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 32,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: GoogleFonts.mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    //_descriptionController.dispose();
    super.dispose();
  }
}
