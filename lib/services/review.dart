import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class WriteReviewPage extends StatefulWidget {
  final String carName;
  final String carId;

  const WriteReviewPage({
    required this.carName,
    required this.carId,
    Key? key,
  }) : super(key: key);

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0.0; // Rating value
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Write Review",
          style: GoogleFonts.mulish(fontWeight: FontWeight.bold, fontSize: 18),
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
        //backgroundColor: Colors.blue,
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Review for ${widget.carName}",
              style: GoogleFonts.mulish(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reviewController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: "Your Review",
                hintText: "Share your experience...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Rating",
              style: GoogleFonts.mulish(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) =>
              const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _submitReview();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Set the button color to blue
                  backgroundColor: Colors.blue, // Set the text color to white
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12), // Optional: Adjust padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        8), // Optional: Rounded corners
                  ),
                ),
                child: Text(
                  "Submit Review",
                  style: GoogleFonts.mulish(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    if (_reviewController.text
        .trim()
        .isEmpty || _rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a review and rating!")),
      );
      return;
    }

    try {
      // Save review to Firestore under the specific car's document
      await _firestore
          .collection('Cars') // Access the Cars collection
          .doc(widget.carId) // Use the car ID to identify the specific document
          .collection('reviews') // Access the reviews subcollection
          .add({
        'reviewText': _reviewController.text.trim(),
        'rating': _rating,
        'userEmail': user.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review submitted successfully!")),
      );
      Navigator.pop(context); // Close the review page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error submitting review!")),
      );
    }
  }
}
