import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.mulish(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Booking Confirmation Section
            Text(
              'Booking Confirmations',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _fetchUserBookings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error loading bookings."));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "No bookings found.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final bookingDocs = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: bookingDocs.length,
                    itemBuilder: (context, index) {
                      final booking = bookingDocs[index];
                      final startDate = booking['startDate']; // String
                      final endDate = booking['endDate'];   // String

                      return ListTile(
                        leading: Icon(Icons.check_circle, color: Colors.green),
                        title: Text(
                          "Your booking has been confirmed from $startDate to $endDate.",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 24),
            // Offer Section
            Text(
              'Offers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  final offerNotifications = [
                    "Get 20% off on your next booking!",
                    "Limited-time offer: Book now and save up to 250 Rupees!",
                    "Flash Sale: Enjoy 15% discount on weekend trips!",
                  ];
                  return ListTile(
                    leading: Icon(Icons.local_offer, color: Colors.orange),
                    title: Text(offerNotifications[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fetch the user-specific bookings stream
  Stream<QuerySnapshot> _fetchUserBookings() {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.email != null) {
      return _firestore
          .collection('Users') // Access the users collection
          .doc(user.email) // Reference the user's document by their email
          .collection('bookings') // Access the 'bookings' subcollection
          .snapshots();
    } else {
      return Stream.empty(); // Return an empty stream if no user is logged in
    }
  }
}
