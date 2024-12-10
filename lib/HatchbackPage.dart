import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HatchbackPage extends StatefulWidget {
  const HatchbackPage({super.key});

  @override
  State<HatchbackPage> createState() => _HatchbackPageState();
}

class _HatchbackPageState extends State<HatchbackPage> {
  // Method to fetch data from Firestore based on carType = 'Hatchback'
  Stream<List<DocumentSnapshot>> _fetchHatchbacks() {
    return FirebaseFirestore.instance
        .collection('Cars') // Assuming 'Cars' is the global collection
        .where('carType', isEqualTo: 'Hatchback')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
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
                  "Hatchbacks",
                  style: GoogleFonts.mulish(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                // StreamBuilder to fetch and display Hatchback data
                StreamBuilder<List<DocumentSnapshot>>(
                  stream: _fetchHatchbacks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No Hatchbacks available.'));
                    }

                    var cars = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
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

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // Rounded corners
                          ),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              carImage != null
                                  ? Container(
                                      height: 150,
                                      width: double.infinity,
                                      child: Image.network(
                                        carImage,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      height: 150,
                                      color: Colors.grey[300],
                                      child: Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
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
                                  carData['brand'] ?? 'No Brand',
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
                                  '\₹${carData['price'] ?? '0'}',
                                  style: GoogleFonts.mulish(fontSize: 14),
                                ),
                              ),
                            ],
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
