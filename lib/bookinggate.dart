import 'package:flutter/material.dart';

class BookingGateway extends StatefulWidget {
  final String carName;
  final double basePrice; // Base price for the car

  const BookingGateway({
    super.key,
    required this.carName,
    required this.basePrice,
  });

  @override
  State<BookingGateway> createState() => _BookingGatewayState();
}

class _BookingGatewayState extends State<BookingGateway> {
  bool isDelivery = false; // Toggle for self-pick-up or delivery
  double deliveryFee = 50.0; // Example delivery fee

  double get totalPrice {
    // Calculate total price based on selection
    return widget.basePrice + (isDelivery ? deliveryFee : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Booking Gateway',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Car: ${widget.carName}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Base Price: ₹${widget.basePrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Pick-up Option:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            RadioListTile(
              title: Text('Self Pick-up'),
              value: false,
              groupValue: isDelivery,
              onChanged: (bool? value) {
                setState(() {
                  isDelivery = value ?? false;
                });
              },
            ),
            RadioListTile(
              title: Text('Delivery (Additional ₹${deliveryFee.toStringAsFixed(2)})'),
              value: true,
              groupValue: isDelivery,
              onChanged: (bool? value) {
                setState(() {
                  isDelivery = value ?? false;
                });
              },
            ),
            const SizedBox(height: 20),
            Divider(),
            Text(
              'Total Price: ₹${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add booking confirmation logic here
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Booking Confirmed'),
                      content: Text('Your booking for ${widget.carName} has been confirmed.\nTotal: ₹${totalPrice.toStringAsFixed(2)}'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 