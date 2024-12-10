import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentwheels/carInfopage.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Fetch available cars from Firestore
  Stream<QuerySnapshot> _fetchAvailableCars() {
    return FirebaseFirestore.instance
        .collection('Cars')
        .where('bookedState', isEqualTo: 'available') // Filter by bookedState
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    border: Border.all(
                      color: Colors.black,
                      width: 0.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_left,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Page title
              Text(
                "Search Results",
                style: GoogleFonts.mulish(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Display cars
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _fetchAvailableCars(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error fetching cars",
                          style: GoogleFonts.mulish(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No Available Cars",
                          style: GoogleFonts.mulish(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }

                    // Display car data
                    final cars = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: cars.length,
                      itemBuilder: (context, index) {
                        final car = cars[index].data() as Map<String, dynamic>;
                        final imageUrls = car['imageURLs'] ?? [];
                        final imageUrl = imageUrls.isNotEmpty
                            ? imageUrls[0]
                            : 'assets/default_car.jpg'; // Fallback image

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CarInfoPage(CarId: cars[index].id),
                                ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // Car Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 150,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/default_car.jpg',
                                          width: 150,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Car Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          car['model'] ?? 'Unknown Model',
                                          style: GoogleFonts.mulish(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          car['brand'] ?? 'Unknown Brand',
                                          style: GoogleFonts.mulish(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "₹${car['price']?.toString() ?? '0.00'} per day",
                                          style: GoogleFonts.mulish(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
        ),
      ),
    );
  }
}
