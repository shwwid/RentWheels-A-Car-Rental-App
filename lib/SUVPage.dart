import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentwheels/carInfopage.dart';

class SUVPage extends StatefulWidget {
  const SUVPage({super.key});

  @override
  State<SUVPage> createState() => _SUVPageState();
}

class _SUVPageState extends State<SUVPage> {
  // Method to fetch data from Firestore based on carType = 'SUV'
  Stream<List<DocumentSnapshot>> _fetchSUVs() {
    return FirebaseFirestore.instance
        .collection('Cars') // Assuming 'Cars' is the global collection
        .where('carType', isEqualTo: 'SUV')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView( // Wrap the whole body with SingleChildScrollView
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  "SUVs",
                  style: GoogleFonts.mulish(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                // StreamBuilder to fetch and display SUV data
                StreamBuilder<List<DocumentSnapshot>>(
                  stream: _fetchSUVs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No SUVs available.'));
                    }

                    var cars = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true, // Allow GridView to take only the required space
                      physics: NeverScrollableScrollPhysics(), // Disable scrolling for GridView
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of columns in the grid
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.15 / 1.5,
                      ),
                      itemCount: cars.length,
                      itemBuilder: (context, index) {
                        var carData = cars[index].data() as Map<String, dynamic>;

                        // Check if imageURLs exists and fetch the first image
                        String? carImage = carData['imageURLs'] != null && carData['imageURLs'].isNotEmpty
                            ? carData['imageURLs'][0]
                            : null;

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
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), // Rounded corners
                            ),
                            color: Colors.white, // Set card color to white
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Display the first image from the imageURLs array if available
                                carImage != null
                                    ? Image.network(
                                        carImage,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    carData['model'] ?? 'No Model',
                                    style: GoogleFonts.mulish(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    carData['brand'] ?? 'No Brand', // Display the brand
                                    style: GoogleFonts.mulish(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    '₹${carData['price'] ?? '0'}',
                                    style: GoogleFonts.mulish(fontSize: 14,
                                    color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
