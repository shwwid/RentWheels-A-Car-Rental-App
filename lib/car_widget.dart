import 'package:flutter/material.dart';
import 'package:rentwheels/data.dart';

Widget buildCar(Car car, int index) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(
        Radius.circular(15),
      ),
    ),
    padding: EdgeInsets.all(16),
    // ignore: unnecessary_null_comparison
    margin: EdgeInsets.only(right: 16, left: index == 0 ? 16 : 0),
    width: 220,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 8,
        ),

        Text(
          car.model,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),

        SizedBox(
          height: 120,
          child: Center(
            child: Image.asset(
              car.images[0],
              fit: BoxFit.fitWidth,
            ),
          ),
        ),

        SizedBox(
          height: 24,
        ),

        Text(
          car.brand,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
        Text(
          "₹${car.price.toString()}",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}