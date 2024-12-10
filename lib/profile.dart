import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentwheels/admin.dart';
import 'package:rentwheels/components/text_box.dart';
import 'package:rentwheels/login.dart';
import 'package:flutter/services.dart';
import 'package:rentwheels/services/bookings.dart'; // Import your admin page

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final currentuser = FirebaseAuth.instance.currentUser!;

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
  context: context,
  builder: (context) => AlertDialog(
    backgroundColor: Colors.white,
    title: Text(
      "Change Name",
      style: GoogleFonts.mulish(color: Colors.black, fontWeight: FontWeight.bold),
    ),
    content: TextField(
      autofocus: true,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: "Enter New $field",
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      inputFormatters: [
        // Only allows letters (uppercase and lowercase)
        FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
      ],
      onChanged: (value) {
        newValue = value;
      },
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
      ),
      TextButton(
        onPressed: () async {
          if (newValue.isNotEmpty) {
            try {
              await FirebaseFirestore.instance
                  .collection("Users")
                  .doc(currentuser.email)
                  .update({field.toLowerCase(): newValue});

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Field updated successfully!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to update. Please try again.')),
              );
            }
          }
          Navigator.pop(context);
        },
        child: const Text('Save', style: TextStyle(color: Colors.black)),
      ),
    ],
  ),
);
  }

  Future<void> editPhoneNumber() async {
    String newPhoneNumber = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "Change Phone Number",
          style: GoogleFonts.mulish(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.black),
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: "Enter New Phone Number",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newPhoneNumber = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (newPhoneNumber.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance
                      .collection("Users")
                      .doc(currentuser.email)
                      .update({'phone_number': newPhoneNumber});

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Phone number updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update phone number. Please try again.')),
                  );
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> deleteAccount() async {
    try {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentuser.email)
          .delete();

      await FirebaseAuth.instance.currentUser!.delete();
      await FirebaseAuth.instance.signOut();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'requires-recent-login') {
        errorMessage = 'You need to log in again before deleting your account.';
      } else {
        errorMessage = 'Failed to delete account. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete account from Firestore. Please try again.')),
      );
    }
  }

  Future<void> becomeAdmin() async {
  final userData = await FirebaseFirestore.instance
      .collection("Users")
      .doc(currentuser.email)
      .get();

  String? phoneNumber = userData.data()?['phone_number'];

  if (phoneNumber == null || phoneNumber.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You must have a phone number to become an admin.')),
    );
    return; // Exit the method if the phone number is missing
  }

  try {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentuser.email)
        .update({'role': 'seller'});

    // After updating the role, navigate to the admin page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AdminPage()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You can now rent your cars!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed. Please try again.')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'CUSTOMER PROFILE DETAILS',
          style: GoogleFonts.mulish(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          color: Colors.black,
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").doc(currentuser.email).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          }

          if (snapshot.hasData && snapshot.data != null) {
            final userData = snapshot.data!.data() as Map<String, dynamic>?;

            if (userData == null) {
              return const Center(child: Text('No user data found'));
            }

            return Stack(
              children: [
                ListView(
                  children: [
                    const SizedBox(height: 50),
                    Icon(
                      Icons.person,
                      color: Colors.grey[800],
                      size: 72,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        currentuser.email!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[800], fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: const Text(
                        'My details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    MyTextBox(
                      text: userData['name'] ?? 'No Name',
                      sectionName: 'Name',
                      onPressed: () => editField('Name'),
                    ),
                    MyTextBox(
                      text: userData['phone_number'] ?? 'No Phone Number',
                      sectionName: 'Phone Number',
                      onPressed: () => editPhoneNumber(),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: const Text(
                        'License',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 25.0),
                      child: userData['imageURLs'] != null && userData['imageURLs'] is List
                          ? SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: userData['imageURLs'].length,
                                itemBuilder: (context, index) {
                                  String imageUrl = userData['imageURLs'][index];
                                  return Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    width: 360,
                                    height: 200, // Adjust width as needed
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Center(
                                            child: Text(
                                              'Error loading image',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Center(
                              child: Text(
                                'No license image uploaded',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 32, 81, 203),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => YourBookings()),
                          );
                        },
                        child: Text(
                          'Bookings & Review',
                          style: GoogleFonts.mulish(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 32, 81, 203),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () => editField('Name'),
                        child: Text(
                          'Update Name',
                          style: GoogleFonts.mulish(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 32, 81, 203),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () => editPhoneNumber(),
                        child: Text(
                          'Update Phone Number',
                          style: GoogleFonts.mulish(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 207, 66, 56),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text(
                                  'Confirm Deletion',
                                  style: GoogleFonts.mulish(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to delete your account? This action cannot be undone.',
                                  style: GoogleFonts.mulish(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.mulish(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 207, 66, 56),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                      deleteAccount(); // Call the deleteAccount function
                                    },
                                    child: Text(
                                      'Delete',
                                      style: GoogleFonts.mulish(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          'Delete Account',
                          style: GoogleFonts.mulish(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ],
            );
          }

          return const Center(child: Text('User data not found'));
        },
      ),
    );
  }
}
