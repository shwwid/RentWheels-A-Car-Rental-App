import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentwheels/login.dart';
import 'package:rentwheels/showroom.dart';
import 'package:rentwheels/admin.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<String?> _getUserRole(String email) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(email)
          .get();
      if (userDoc.exists) {
        return userDoc['role1'] as String?; // Assuming 'role1' is the field name
      } else {
        return null; // Return null if the user document doesn't exist
      }
    } catch (e) {
      print('Error fetching user role: $e');
      return null; // Return null in case of any error
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // User logged in
            if (snapshot.hasData) {
              final User user = snapshot.data!;
              return FutureBuilder<String?>(
                future: _getUserRole(user.email!),
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (roleSnapshot.hasError || roleSnapshot.data == null) {
                    // Show a SnackBar and sign out the user
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showSnackBar(context, 'Your account was not found. Please register.');
                      FirebaseAuth.instance.signOut();
                    });
                    return LoginPage(); // Redirect to the login page
                  }
                  final role = roleSnapshot.data!;
                  if (role == 'admin') {
                    return AdminPage();
                  } else if (role == 'client') {
                    return Showroom();
                  } else {
                    return const Center(
                      child: Text(
                        'Invalid role assigned. Contact support.',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }
                },
              );
            }

            // User not logged in
            else {
              return LoginPage();
            }
          },
        ),
      ),
    );
  }
}
