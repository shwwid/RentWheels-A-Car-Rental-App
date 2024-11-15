import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rentwheels/components/text_box.dart';
import 'package:rentwheels/login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final currentuser = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "Change",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter New $field",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          // Cancel
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          // Save
          TextButton(
            onPressed: () async {
              if (newValue.isNotEmpty) {
                // Update the name in Firestore
                try {
                  await FirebaseFirestore.instance
                      .collection("Users")
                      .doc(currentuser.email)
                      .update({'name': newValue});

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Name updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update name. Please try again.')),
                  );
                }
              }
              Navigator.pop(context); // Close the dialog after saving
            },
            child: Text('Save', style: TextStyle(color: Colors.white)),
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
        backgroundColor: Colors.black,
        title: const Text(
          "Change Phone Number",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.phone, // Phone number keyboard
          decoration: InputDecoration(
            hintText: "Enter New Phone Number",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newPhoneNumber = value;
          },
        ),
        actions: [
          // Cancel
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          // Save
          TextButton(
            onPressed: () async {
              if (newPhoneNumber.isNotEmpty) {
                try {
                  // Update the phone number in Firestore
                  await FirebaseFirestore.instance
                      .collection("Users")
                      .doc(currentuser.email)
                      .update({'phone_number': newPhoneNumber});

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Phone number updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update phone number. Please try again.')),
                  );
                }
              }
              Navigator.pop(context); // Close the dialog after saving
            },
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> deleteAccount() async {
    try {
      await FirebaseAuth.instance.currentUser!.delete();
      // Sign out the user after deleting the account
      await FirebaseAuth.instance.signOut();
      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account deleted successfully!')),
      );
      // Navigate the user to the login or splash screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()), // Replace with your login page
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
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").doc(currentuser.email).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return Stack(
              children: [
                ListView(
                  children: [
                    const SizedBox(height: 50),
                    // Profile pic
                    Icon(
                      Icons.person,
                      color: Colors.grey[800],
                      size: 72,
                    ),
                    const SizedBox(height: 20),
                    // Email (centered)
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
                      child: Text(
                        'My details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    // Name
                    MyTextBox(
                      text: userData['name'] ?? 'No Name',
                      sectionName: 'Name',
                      onPressed: () => editField('Name'),
                    ),
                    // Phone Number
                    MyTextBox(
                      text: userData['phone_number'] ?? 'No Phone Number', // Show phone number
                      sectionName: 'Phone Number',
                      onPressed: () => editPhoneNumber(), // Open dialog for phone number
                    ),
                    // Update Name button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 32, 81, 203), // Red background color
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () => editField('Name'), // Open the dialog to edit name
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
                    // Update Phone Number button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 32, 81, 203), // Red background color
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () => editPhoneNumber(), // Open dialog for phone number
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
                    // Delete Account Button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0), // Reduced vertical padding
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 207, 66, 56), // Red background color
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        onPressed: () => deleteAccount(),
                        child: Text(
                          'Delete Account',
                          style: GoogleFonts.mulish(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
