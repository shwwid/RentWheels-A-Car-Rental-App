import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentwheels/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatefulWidget {
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Set<String> _selectedOrders = {}; // Tracks selected orders

  // Function to delete selected orders
  Future<void> _deleteSelectedOrders() async {
    try {
      for (var orderId in _selectedOrders) {
        // Retrieve the order document
        final orderDoc = await _firestore.collection('orders').doc(orderId).get();
        if (orderDoc.exists) {
          final orderData = orderDoc.data() as Map<String, dynamic>;

          // Extract customer email (if stored in the order document)
          final customerEmail = orderData['customerEmail']; // Assuming 'customerEmail' is saved in 'orders'

          // Delete from the 'orders' collection
          await _firestore.collection('orders').doc(orderId).delete();

          // Delete the associated booking document from user's 'bookings' subcollection
          if (customerEmail != null) {
            final bookingsQuery = await _firestore
                .collection('Users')
                .doc(customerEmail)
                .collection('bookings')
                .where('orderId', isEqualTo: orderId)
                .get();

            for (var bookingDoc in bookingsQuery.docs) {
              await bookingDoc.reference.delete();
            }
          }
        }
      }

      setState(() {
        _selectedOrders.clear(); // Clear the selection after deletion
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selected orders and bookings deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting orders: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          _selectedOrders.isEmpty
              ? "All Orders"
              : "${_selectedOrders.length} Selected",
          style: GoogleFonts.mulish(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        actions: _selectedOrders.isNotEmpty
            ? [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red,),
            onPressed: () {
              // Confirm deletion
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text("Delete Orders",
                    style: GoogleFonts.mulish(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: const Text("Are you sure you want to delete the selected orders?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                      },
                      child: Text("Cancel",
                        style: GoogleFonts.mulish(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 207, 66, 56),
                      ),
                      onPressed: () async {
                        Navigator.pop(context); // Close dialog
                        await _deleteSelectedOrders();
                      },
                      child: Text("Delete",
                        style: GoogleFonts.mulish(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ]
            : null,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('orders').orderBy('timestamp', descending: true).snapshots(),
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

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final orderData = doc.data() as Map<String, dynamic>;
              final isSelected = _selectedOrders.contains(doc.id);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedOrders.remove(doc.id);
                    } else {
                      _selectedOrders.add(doc.id);
                    }
                  });
                },
                child: Card(
                  color: isSelected ? Colors.blue[50] : Colors.white,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                  child: ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.receipt,
                      color: isSelected ? Colors.blue : kPrimaryColor,
                    ),
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
                        Text(
                          "Date of Booking: ${orderData['timestamp'] != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format((orderData['timestamp'] as Timestamp).toDate()) : 'N/A'}",
                        ),
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
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
