import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class NotificationPage extends StatelessWidget {
  final List<String> bookingNotifications = [
    "Your booking for 11-11-2024 has been confirmed!",
    "Your reservation on 12-11-2024 is now confirmed.",
    "Booking on 15-11-2024 has been processed successfully.",
  ];

  final List<String> offerNotifications = [
    "Get 20% off on your next booking!",
    "Limited-time offer: Book now and save up to 250 Rupees!",
    "Flash Sale: Enjoy 15% discount on weekend trips!",
  ];

  NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications',
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
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: bookingNotifications.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text(bookingNotifications[index]),
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
                itemCount: offerNotifications.length,
                itemBuilder: (context, index) {
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
}
