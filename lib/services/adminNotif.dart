import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentwheels/add_vehicle.dart';

class AdminNotif extends StatefulWidget {
  const AdminNotif({super.key});

  @override
  State<AdminNotif> createState() => _AdminNotifState();
}

class _AdminNotifState extends State<AdminNotif> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor, // Use your primary color
        title: Text(
          "Notification",
          style: GoogleFonts.mulish(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Stream to listen to changes in the 'cancellation' collection
        stream: FirebaseFirestore.instance
            .collection('cancellation')
            .orderBy('timestamp', descending: true) // Order by timestamp to show most recent
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No cancellation requests found"));
          }

          // List of cancellation requests from Firestore
          final cancellationRequests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cancellationRequests.length,
            itemBuilder: (context, index) {
              var request = cancellationRequests[index];
              String description = request['description'] ?? 'No description';
              String email = request['email'] ?? 'No email';
              String orderId = request['orderId'] ?? 'No Order ID';

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10.0),
                  title: Text('Order ID: $orderId', style: GoogleFonts.mulish(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Description: $description"),
                      Text("Email: $email"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Delete cancellation request if needed
                      await FirebaseFirestore.instance
                          .collection('cancellation')
                          .doc(request.id)
                          .delete();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
