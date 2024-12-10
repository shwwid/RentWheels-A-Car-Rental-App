import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentwheels/add_vehicle.dart';
import 'package:rentwheels/booking_gateway.dart';
import 'package:intl/intl.dart';

class CarInfoPage extends StatefulWidget {
  final String CarId;

  const CarInfoPage({super.key, required this.CarId});

  @override
  _CarInfoPageState createState() => _CarInfoPageState();
}

class _CarInfoPageState extends State<CarInfoPage> {

  Future<Map<String, dynamic>> _fetchUserDetails() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // If the user is not authenticated
        return {'customerName': 'Not Signed In', 'phone_number': 'N/A', 'customerEmail': 'N/A'};
      }

      final userEmail = user.email;

      // Fetch user document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail) // Assuming userEmail is the document ID
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        return {
          'customerName': data?['name'] ?? 'Unknown User',
          'phone_number': data?['phone_number'] ?? 'Unknown Number',
          'customerEmail': data?['email'] ?? 'Unknown Email',
        };
      } else {
        // Document does not exist
        return {'customerName': 'User Not Found', 'phone_number': 'N/A', 'customerEmail': 'N/A'};
      }
    } catch (e) {
      // Handle any errors
      print("Error fetching user details: $e");
      return {'customerName': 'Error', 'phone_number': 'N/A', 'customerEmail': 'N/A'};
    }
  }



  // Fetch car details from Firestore
  Future<DocumentSnapshot> _fetchCarDetails() {
    return FirebaseFirestore.instance.collection('Cars')
        .doc(widget.CarId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Fix crossAxisAlignment placement
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_left,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 25),
              // FutureBuilder for car details
              FutureBuilder<DocumentSnapshot>(
                future: _fetchCarDetails(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error loading car details.'));
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('Car not found.'));
                  }

                  var carData = snapshot.data!.data() as Map<String, dynamic>;
                  List<dynamic> imageUrls = carData['imageURLs'] ?? [];

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Car Model and Brand
                        Center(
                          child: Text(
                            carData['model'] ?? 'Unknown Model',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            carData['brand'] ?? 'Unknown Brand',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),

                        // Car Image PageView
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: imageUrls.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrls[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/default_car.jpg',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),

                        // Specifications Bar
                        _buildSpecificationBar(carData),
                        const SizedBox(height: 24.0),

                        // Price and Book Now Button
                        _buildPriceAndButton(
                          double.tryParse(carData['price'].toString()) ?? 0.0,
                          carData['bookedState'] ?? 'available', // Pass bookedState to the method
                        ),
                        const SizedBox(height: 25),
                        Divider(
                          color: Colors.grey,
                          thickness: 1.5,
                        ),
                        Text('Reviews',
                          style: GoogleFonts.mulish(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                            fontSize: 34,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CarReviewsWidget(carId: widget.CarId),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build specifications bar
  Widget _buildSpecificationBar(Map<String, dynamic> carData) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white, // Set the background color here
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //rating bar
            CarRatingWidget(carId: widget.CarId),
            //specification bar
            Text(
              "Specifications",
              style: GoogleFonts.mulish(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8.0),
            _buildSpecRow("Brand", carData['brand'] ?? 'N/A'),
            _buildSpecRow("Model", carData['model'] ?? 'N/A'),
            _buildSpecRow("Fuel Type", carData['fuelType'] ?? 'N/A'),
            _buildSpecRow("Transmission", carData['transmission'] ?? 'N/A'),
            _buildSpecRow("Seats", carData['seats']?.toString() ?? 'N/A'),
            _buildSpecRow(
                "Mileage(km/l)", carData['mileage']?.toString() ?? 'N/A'),
            _buildSpecRow("Car Type", carData['carType'] ?? 'N/A'),
            _buildSpecRow(
                "Registration Number", carData['registrationNumber'] ?? 'N/A'),
            _buildSpecRow("Model Year", carData['year']?.toString() ?? 'N/A'),
          ],
        ),
      ),
    );
  }


  // Helper function to display a row of specification
  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.mulish(fontSize: 16, color: Colors.black54)),
          Text(value, style: GoogleFonts.mulish(
              fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

// Widget for Price and Book Now Button
  Widget _buildPriceAndButton(double price, String bookedState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Displaying the price on the left
        Text(
          "₹${price.toStringAsFixed(2)} per day",
          style: GoogleFonts.mulish(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(width: 8),
        // Check bookedState before showing the button
        if (bookedState != 'booked')
          ElevatedButton(
            onPressed: () async {
              // Fetch user details
              final userDetails = await _fetchUserDetails();

              final customerName = userDetails['customerName'];
              final phoneNumber = userDetails['phone_number'];
              final customerEmail = userDetails['customerEmail'];

              if (phoneNumber == 'Unknown Number' || phoneNumber == 'N/A') {
                // Show a dialog if phone number is not registered
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text('Phone Number Required',
                        style: GoogleFonts.mulish(fontWeight: FontWeight.bold),
                      ),
                      content: const Text(
                        'You must have a phone number registered in your account to proceed with the booking.',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close the dialog
                          },
                          child: Text('OK',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                // Proceed with the booking if the phone number is available
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingGatewayPage(
                      email: customerEmail,
                      carId: widget.CarId,
                      customerName: customerName,
                      phone_number: phoneNumber, // Pass phone_number
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 8,
            ),
            child: const Text("Book Now", style: TextStyle(fontSize: 16)),
          )
        else
          Text(
            "Car is not available.",
            style: GoogleFonts.mulish(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
      ],
    );
  }
}


class CarRatingWidget extends StatelessWidget {
  final String carId;

  const CarRatingWidget({super.key, required this.carId});

  Future<double> _fetchAverageRating() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Cars')
          .doc(carId)
          .collection('reviews')
          .get();

      if (querySnapshot.docs.isEmpty) {
        return 0.0; // No reviews yet
      }

      double totalRating = 0.0;
      int reviewCount = querySnapshot.docs.length;

      for (var doc in querySnapshot.docs) {
        totalRating += (doc['rating'] ?? 0.0);
      }

      return totalRating / reviewCount;
    } catch (e) {
      print("Error fetching reviews: $e");
      return 0.0; // Return 0.0 in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: _fetchAverageRating(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Loading indicator
        }

        if (snapshot.hasError) {
          return const Text('Error fetching rating');
        }

        final averageRating = snapshot.data ?? 0.0;

        return Row(
          children: [
            // Star Rating Display
            for (int i = 1; i <= 5; i++)
              Icon(
                i <= averageRating
                    ? Icons.star
                    : (i - averageRating < 1
                    ? Icons.star_half
                    : Icons.star_border),
                color: Colors.amber,
              ),
            const SizedBox(width: 8),
            // Average Rating Text
            Text(
              averageRating > 0.0
                  ? averageRating.toStringAsFixed(1)
                  : 'No ratings yet',
              style: GoogleFonts.mulish(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        );
      },
    );
  }
}

class CarReviewsWidget extends StatelessWidget {
  final String carId;

  const CarReviewsWidget({super.key, required this.carId});

  Future<List<Map<String, dynamic>>> _fetchReviews() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Cars')
          .doc(carId)
          .collection('reviews')
          .orderBy('timestamp', descending: true) // Sort by latest reviews
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'userEmail': data['userEmail'] ?? 'Anonymous',
          'reviewText': data['reviewText'] ?? 'No review provided.',
          'rating': data['rating'] ?? 0.0,
          'timestamp': data['timestamp'] != null
              ? (data['timestamp'] as Timestamp).toDate()
              : null,
        };
      }).toList();
    } catch (e) {
      print("Error fetching reviews: $e");
      return []; // Return empty list in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No reviews available for this car.'),
            );
          }

          final reviews = snapshot.data!;

          return SizedBox(
            height: 200, // Adjust height to fit review cards
            child: PageView.builder(
              itemCount: reviews.length,
              controller: PageController(viewportFraction: 0.8),
              itemBuilder: (context, index) {
                final review = reviews[index];
                final userEmail = review['userEmail'];
                final reviewText = review['reviewText'];
                final rating = review['rating'];
                final timestamp = review['timestamp'];

                return Card(
                  color: Colors.grey[100],
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Email
                        Text(
                          userEmail,
                          style: GoogleFonts.mulish(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Timestamp
                        if (timestamp != null)
                          Text(
                            "Reviewed on ${DateFormat.yMMMd().add_jm().format(timestamp)}",
                            style: GoogleFonts.mulish(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 6),
                        // Rating
                        Row(
                          children: List.generate(
                            5,
                                (starIndex) => Icon(
                              starIndex < rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Review Text
                        Text(
                          reviewText,
                          style: GoogleFonts.mulish(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
