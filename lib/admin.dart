import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentwheels/add_vehicle.dart';
import 'package:rentwheels/services/Orders.dart';
import 'package:rentwheels/services/adminNotif.dart';
import 'package:rentwheels/update_vehicle.dart'; // Ensure this imports your update vehicle page
import 'admin_profile.dart'; // Ensure this imports your profile page
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

// Define the primary color globally
const Color kPrimaryColor = Color(0xFF1A73E8); // Replace with your desired primary color
const Color kBackgroundColor = Color(0xFFF0F0F0); // New background color for the body

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

void signUserOut() {
  FirebaseAuth.instance.signOut();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Placeholder for registration number

  User? get currentUser => _auth.currentUser; // Retrieve the current authenticated user

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        // The main body of the Scaffold
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          elevation: 0,
          title: Text(
            "Admin Dashboard",
            style: GoogleFonts.mulish(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.directions_car, color: Colors.white), text: "Cars"),
              Tab(icon: Icon(Icons.check, color: Colors.white), text: "Booked Cars"),
              Tab(icon: Icon(Icons.receipt, color: Colors.white), text: "Orders"),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminNotif()),
                );
              },
              icon: const Icon(Icons.notifications, color: Colors.white,),
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
            IconButton(
              onPressed: () {
                // Show a confirmation dialog for logout
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text(
                        'Confirm Logout',
                        style: GoogleFonts.mulish(fontWeight: FontWeight.bold),
                      ),
                      content: Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog without logging out
                          },
                          child: const Text('No', style: TextStyle(color: Colors.black)),
                        ),
                        TextButton(
                          onPressed: () {
                            signUserOut(); // Proceed with signing out
                            Navigator.of(context).pop();
                          },
                          child: const Text('Yes', style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.logout_outlined, color: Colors.white60),
            ),
          ],
        ),
        body: Stack(
          children: [
            // TabBarView for the content of the tabs
            TabBarView(
              children: [
                CarsTab(),
                BookedCarsTab(),
                OrdersTab(),
              ],
            ),
            // FloatingActionButton positioned at the bottom-right corner
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  // Navigate to Add Vehicle page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddVehiclePage()),
                  );
                },
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add, size: 30), // Icon for the FAB
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class CarsTab extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('Cars').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading cars"));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No cars available"));
              }

              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  final carData = doc.data() as Map<String, dynamic>;
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(
                        "${carData['brand'] ?? 'No Brand'} - ${carData['model'] ?? 'No Model'}",
                        style: GoogleFonts.mulish(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text("Price: ₹${carData['price'] ?? 'N/A'}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateVehiclePage(vehicleId: doc.id),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              bool? confirmDeletion = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Delete Vehicle',
                                      style: GoogleFonts.mulish(fontWeight: FontWeight.bold),
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete this vehicle?',
                                      style: GoogleFonts.mulish(),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () => Navigator.of(context).pop(false),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 207, 66, 56),
                                        ),
                                        child: const Text('Delete'),
                                        onPressed: () => Navigator.of(context).pop(true),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmDeletion == true) {
                                try {
                                  await _firestore.collection('Cars').doc(doc.id).delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Vehicle deleted successfully')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to delete vehicle: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),

      ],
    );
  }
}

class BookedCarsTab extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Section header for "Booked Cars
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Cars')
                  .where('bookedState', isEqualTo: 'booked')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text("Error loading booked vehicles"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No booked cars found"));
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    final carData = doc.data() as Map<String, dynamic>;
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(
                          "${carData['brand'] ??
                              'No Brand'} - ${carData['model'] ?? 'No Model'}",
                          style: GoogleFonts.mulish(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text("Status: ${carData['bookedState']}"),
                        trailing: IconButton(
                          icon: const Icon(
                              Icons.check_circle_outline, color: Colors.green),
                          onPressed: () async {
                            // Show confirmation dialog before updating bookedState
                            bool? confirmAvailability = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: Text(
                                    'Change Status',
                                    style: GoogleFonts.mulish(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  content: const Text(
                                      'Are you sure you want to mark this vehicle as available?'),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        'Cancel',
                                        style: GoogleFonts.mulish(
                                            color: Colors.black),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(
                                            false); // Do not update
                                      },
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 34, 131, 230),
                                      ),
                                      child: Text(
                                        'Confirm',
                                        style: GoogleFonts.mulish(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(
                                            true); // Confirm update
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirmAvailability == true) {
                              try {
                                // Update the 'bookedState' field in Firestore
                                await _firestore
                                    .collection('Cars')
                                    .doc(doc.id)
                                    .update({'bookedState': 'available'});

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text(
                                      'Vehicle status updated to available')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(
                                      'Failed to update vehicle: $e')),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class OrdersTab extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Orders Section
            buildOrderSectionHeader(context, "Orders"),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('orders')
                  .orderBy('timestamp', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading orders"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No orders found"));
                }

                return SingleChildScrollView(
                  child: Column(
                  //shrinkWrap: true,
                  children: snapshot.data!.docs.map((doc) {
                    final orderData = doc.data() as Map<String, dynamic>;

                    return Card(
                      color: Colors.white,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: const Icon(Icons.receipt, color: Colors.blue),
                        title: Text(
                          "Order ID: ${doc.id}",
                          style: GoogleFonts.mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Customer: ${orderData['customerName'] ?? 'N/A'}"),
                            Text("Phone Number: ${orderData['phone_number'] ?? 'N/A'}"),
                            Text("Car: ${orderData['carName'] ?? 'N/A'}"),
                            Text("Start Date: ${orderData['startDate'] ?? 'N/A'}"),
                            Text("End Date: ${orderData['endDate'] ?? 'N/A'}"),
                            Text("Date of Booking: ${orderData['timestamp'] != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format((orderData['timestamp'] as Timestamp).toDate()) : 'N/A'}"),
                          ],
                        ),
                        trailing: Text(
                          "₹${orderData['amount'] ?? '0.00'}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  )
                );
              },
            ),

            const SizedBox(height: 20),
            const Divider(
              thickness: 1.5,
              color: Colors.grey,
            ),

            // Total Revenue Section
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('orders').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading revenue data"));
                }

                // If no data or documents are empty, set total revenue to 0.0
                double totalRevenue = 0.0;
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  totalRevenue = snapshot.data!.docs.fold(
                    0.0,
                        (sum, doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final amount = double.tryParse(data['amount'].toString()) ?? 0.0; // Safely parse to double
                      return sum + amount;
                    },
                  );
                }

                return Card(
                  color: Colors.white,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Total Revenue: ₹${totalRevenue.toStringAsFixed(2)}",
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
          ],
        ),
      ),
    );
  }

  Widget buildOrderSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.mulish(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrdersPage()),
                );
              },
              child: Text(
                "View All",
                style: GoogleFonts.mulish(
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
}


