import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentwheels/add_vehicle.dart';
import 'package:rentwheels/go_back_to_user.dart';
import 'package:rentwheels/update_vehicle.dart'; // Ensure this imports your update vehicle page
import 'admin_profile.dart';  // Ensure this imports your profile page

// Define the primary color globally
const Color kPrimaryColor = Color(0xFF1A73E8); // Replace with your desired primary color
const Color kBackgroundColor = Color(0xFFF0F0F0); // New background color for the body

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isButtonsVisible = false; // State to control the visibility of the buttons
  String _registrationNumber = ''; // Placeholder for registration number

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor, // Set background color for the body
      appBar: AppBar(
        automaticallyImplyLeading: false, // Prevents the back button from being shown
        backgroundColor: kPrimaryColor, // Set AppBar background color
        elevation: 0,
        title: Text(
          "RentWheels Admin Dashboard",
          style: GoogleFonts.mulish(
            fontSize: 20, // Smaller font size for the title
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white), // Home icon
            onPressed: () {
              // Navigate to the GoBackToUser widget
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const GoBackToUser()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminProfile()),
              );
            },
          ),
        ],
      ),
      body: Stack( // Use a Stack to overlay buttons
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Main content area
                Expanded(
                  child: ListView(
                    children: [
                      // Section for displaying cars
                      buildSectionHeader("Your Cars"),
                      StreamBuilder<QuerySnapshot>(  // Stream to display cars
                        stream: _firestore.collection('Cars').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return const Text("Error loading cars");
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Text("No cars available");
                          }

                          return Column(
                            children: snapshot.data!.docs.map((doc) {
                              final carData = doc.data() as Map<String, dynamic>;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  title: Text(
                                    "${carData['brand'] ?? 'No Brand'} - ${carData['model'] ?? 'No Model'}",
                                    style: GoogleFonts.mulish(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Text("Price: \₹${carData['price'] ?? 'N/A'}"),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      await _firestore.collection('Cars').doc(doc.id).delete();
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Section for displaying orders
                      buildSectionHeader("Orders"),
                      StreamBuilder<QuerySnapshot>(  // Stream to display orders
                        stream: _firestore.collection('Orders').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return const Text("Error loading orders");
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Text("No orders found");
                          }

                          return Column(
                            children: snapshot.data!.docs.map((doc) {
                              final orderData = doc.data() as Map<String, dynamic>;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  title: Text("Order ID: ${doc.id}"),
                                  subtitle: Text("Customer: ${orderData['customer']}"),
                                  trailing: Text("Amount: \$${orderData['amount']}"),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Section for displaying total revenue
                      buildSectionHeader("Revenue Overview"),
                      StreamBuilder<QuerySnapshot>(  // Stream to calculate total revenue
                        stream: _firestore.collection('Orders').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return const Text("Error loading revenue data");
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Text("No revenue data available");
                          }

                          double totalRevenue = snapshot.data!.docs.fold(
                            0.0,
                            (sum, doc) => sum + (doc.data() as Map<String, dynamic>)['amount'],
                          );

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "Total Revenue: \$${totalRevenue.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating action button section (placed at the bottom-right corner)
          Positioned(
            bottom: 16,
            right: 16, // Placed at the bottom-right corner
            child: FloatingActionButton(
              onPressed: _toggleButtonsVisibility, // Toggle the visibility of the other buttons
              child: const Icon(Icons.add, size: 30),
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white, // Using the primary color
            ),
          ),

          // Animated button section (Add, Update)
          if (_isButtonsVisible) ...[
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: 80,
              right: 16, // Place them just above the FAB
              child: _buildPopupButtons(),
            ),
          ],
        ],
      ),
    );
  }

  // Helper function for section headers
  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          title,
          style: GoogleFonts.mulish(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Stack of buttons for Add and Update
  Widget _buildPopupButtons() {
    return Column(
      children: [
        _buildPopupButton("Add Vehicle", AddVehiclePage()),
        const SizedBox(height: 10),
        _buildPopupButton("Update Vehicle", UpdateVehicle(registrationNumber: _registrationNumber)),
      ],
    );
  }

  // Button popup
  Widget _buildPopupButton(String text, Widget? page) {
    return ElevatedButton(
      onPressed: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor, // Set the background color of the button
      ),
      child: Text(
        text,
        style: GoogleFonts.mulish(
          fontSize: 16, // Set the font size for the button text
          fontWeight: FontWeight.bold,
          color: Colors.white, // White text color for the button
        ),
      ),
    );
  }

  // Toggle the visibility of the buttons
  void _toggleButtonsVisibility() {
    setState(() {
      _isButtonsVisible = !_isButtonsVisible;
    });
  }
}
