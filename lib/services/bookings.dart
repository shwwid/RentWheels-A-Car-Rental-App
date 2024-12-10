import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rentwheels/services/cancellation.dart';
import 'package:rentwheels/services/review.dart';

class YourBookings extends StatefulWidget {
  const YourBookings({super.key});

  @override
  State<YourBookings> createState() => _YourBookingsState();
}

class _YourBookingsState extends State<YourBookings> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text("BOOKINGS & REVIEW",
              style: GoogleFonts.mulish(fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              color: Colors.black,
              onPressed: () {
                 Navigator.pop(context);
              }, icon: const Icon(Icons.arrow_back)
            ),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            bottom: const TabBar(
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: [
                  Tab(icon: Icon(Icons.check, color: Colors.black), text: "Your Bookings"),
                  Tab(icon: Icon(Icons.star, color: Colors.black), text: "Your Reviews"),
                ]
            ),
          ),
          body: TabBarView(
            children: [
              YourBookingsTab(),
              YourReviewsTab(),
            ],
          ),
        )
    );
  }
}

class YourBookingsTab extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User user = FirebaseAuth.instance
      .currentUser!; // Current logged-in user

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('Users')
                  .doc(user.email) // Access the user's email document
                  .collection('bookings') // Access the bookings subcollection
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

                final bookings = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final bookingDoc = bookings[index];

                    final booking = bookingDoc.data() as Map<String, dynamic>;

                    // Extract booking data
                    final carName = booking['carName'] ?? 'N/A';
                    final startDate = booking['startDate'] ?? 'N/A';
                    final endDate = booking['endDate'] ?? 'N/A';
                    final amount = booking['amount'] ?? '0.00';
                    final orderId = booking['orderId'] ?? 'N/A';

                    return Card(
                      color: Colors.white,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: const Icon(Icons.directions_car,
                            color: Colors.blue),
                        title: Text(
                          carName,
                          style: GoogleFonts.mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Start Date: $startDate"),
                            Text("End Date: $endDate"),
                            Text(
                                "Date of Booking: ${booking['timestamp'] != null
                                    ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
                                    (booking['timestamp'] as Timestamp)
                                        .toDate())
                                    : 'N/A'}"),
                            Text("Amount: ₹$amount"),
                          ],
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Cancellation(orderId: orderId, carName:carName,)
                              ),
                            );
                          },
                          child: Text(
                            "Cancel",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        ),
                      );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class YourReviewsTab extends StatelessWidget{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('Users')
                  .doc(user.email) // Access the user's email document
                  .collection('bookings') // Access the bookings subcollection
              //.orderBy('dateOfBooking', descending: true) // Order by booking date
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading booked vehicles"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No cars to review"));
                }

                final bookings = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final bookingDoc = bookings[index];
                    final booking = bookingDoc.data() as Map<String, dynamic>;

                    // Extract booking data
                    final carName = booking['carName'] ?? 'N/A';
                    final startDate = booking['startDate'] ?? 'N/A';
                    final endDate = booking['endDate'] ?? 'N/A';
                    final amount = booking['amount'] ?? '0.00';
                    final carId = booking['carId'] ?? 'N/A';
                    return Card(
                      color: Colors.white,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: const Icon(Icons.directions_car, color: Colors.blue),
                        title: Text(
                          carName,
                          style: GoogleFonts.mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Text("Booking ID: $bookingId"), // Display the document ID
                            Text("Start Date: $startDate"),
                            Text("End Date: $endDate"),
                            Text("Date of Booking: ${booking['timestamp'] != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format((booking['timestamp'] as Timestamp).toDate()) : 'N/A'}"),
                            Text("Amount: ₹$amount"),
                          ],
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WriteReviewPage(
                                  carName: carName,
                                  carId:carId,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "Write Review",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),

                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


