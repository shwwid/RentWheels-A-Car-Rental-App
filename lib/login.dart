import 'package:flutter/material.dart';
import 'package:rentwheels/components/square_tile.dart';
import 'package:rentwheels/components/my_textfield.dart';
import 'package:rentwheels/components/button.dart';
//import 'package:rentwheels/host_login.dart';
import 'package:rentwheels/registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rentwheels/services/auth_google.dart';
import 'package:rentwheels/forgotpasswordpage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  // sign user in method
  void signUserIn() async {
    //loading circle
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    );

    //sign in
    try {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: emailController.text,
    password: passwordController.text,
  );
  if(mounted) {
  Navigator.pop(context);
  } // Navigate back after successful login
} on FirebaseAuthException catch (e) {
  if(mounted) {
  Navigator.pop(context); // Close any loading indicator or screen transition
  }
  String errorMessage;

  // Handle different error codes from Firebase
  if (e.code == 'user-not-found') {
    errorMessage = 'No user found for that email.';
  } else if (e.code == 'wrong-password') {
    errorMessage = 'Incorrect password.';
  } else {
    errorMessage = 'Please enter correct E-mail and Password.';
  }

  // Show the error message in a Snackbar
  if(mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.black, // You can customize the background color
    ),
  );
  }
}


  }

  void wrongEmailMessage() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog( // Added `return` keyword here
        title: const Text("Wrong Email"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

void wrongPasswordMessage() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog( // Added `return` keyword here
        title: const Text("Incorrect Password"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // logo
                const Text(
                  'RentWheels',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),

                ),

                const SizedBox(height: 10),

                // welcome back, you've been missed!
                Text(
                  'Welcome!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // username textfield
                MyTextfield(
                  controller: emailController,
                  hintText: 'E-Mail',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // forgot password?
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return ForgotPasswordPage();
                          }));
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: Color.fromARGB(255, 0, 0, 255)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // sign in button
                button(
                  onTap: signUserIn,

                ),

                const SizedBox(height: 50),

                // or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // google
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                      onTap: () => AuthGoogle().signInWithGoogle(), // Add parentheses to call the method
                      imagePath: 'assets/images/google.png',
                    ),
                  SizedBox(width: 0),
                  ],
                ),
                const SizedBox(height: 50),

                // register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a Member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) => RegistrationPage()),
                        );
                      },
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 255),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                /*const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Admin?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => HostLoginPage()),
                        );
                      },
                      child: const Text(
                        'Tap here to Sign-In',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 255),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),*/

              ],
            ),
          ),
        ),
      ),
    );
  }
}