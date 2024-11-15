import 'package:rentwheels/admin.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class host_button extends StatelessWidget {
  final Function()? onTap;

  const host_button({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPage()));
      },
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25.0),
        decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15)),
        child: const Text(
          "Sign In",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),

        ),
      ),
    );
  }
}