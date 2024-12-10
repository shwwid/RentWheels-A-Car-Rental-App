import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
import 'package:rentwheels/services/bookingcancelled.dart';
import 'package:rentwheels/services/bookingconfirmed.dart';

class Phonepepayment extends StatefulWidget {
  final String carId;
  final String customerName;
  final String phone_number;
  final String email;
  final String carName;
  final double amount;
  final String startDate;
  final String endDate;

  const Phonepepayment({
    super.key,
    required this.customerName,
    required this.phone_number,
    required this.email,
    required this.carName,
    required this.carId,
    required this.amount,
    required this.startDate,
    required this.endDate
    }
  );

  @override
  State<Phonepepayment> createState() => _PhonepepaymentState();
}

class _PhonepepaymentState extends State<Phonepepayment> {
  String environmentValue = "SANDBOX";
  String appId = "";
  String merchantId = "PGTESTPAYUAT86";
  bool enableLogging = true;

  String saltKey = "96434309-7796-489d-8924-ab56988a6076";
  String saltIndex = "1";

  String body = "";
  String callback = "https://webhook-test.com/992468a872f09423d715e24a63fc7cd9";
  String checksum = "";

  String packageName = "";

  String apiEndPoint = "/pg/v1/pay";

  Object? result;

  @override
  void initState() {
    super.initState();
    initializePayment();
  }

  void initializePayment() async {
    try {
      // Initialize the PhonePe SDK
      await PhonePePaymentSdk.init(
          environmentValue, appId, merchantId, enableLogging);

      // Generate the body and checksum
      body = getChecksum();

      // Start the transaction
      startTransaction();
    } catch (error) {
      handleError(error);
    }
  }

  void handleError(error) {
    setState(() {
      result = error;
    });
  }

  void startTransaction() {
    PhonePePaymentSdk.startTransaction(body, callback, checksum, packageName)
        .then((response) {
      setState(() {
        if (response != null) {
          String status = response['status'].toString();
          String error = response['error'].toString();
          if (status == 'SUCCESS') {
            result = "Flow Completed - Status: Success!";

            // Redirect to BookingConfirmationPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BookingConfirmationPage(
                  customerName: widget.customerName,
                  phone_number: widget.phone_number,
                  email: widget.email,
                  amount: widget.amount.toString(),
                  carName: widget.carName,
                  carId: widget.carId,
                  startDate: widget.startDate,
                  endDate: widget.endDate,
                ),
              ),
            );
          } else {
            result =
            "Flow Completed - Status: $status and Error: $error";
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BookingCancelledPage(),
              ),
            );
          }
        } else {
          result = "Flow Incomplete";
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BookingCancelledPage(),
            ),
          );
        }
      });
    }).catchError((error) {
      handleError(error);
    });
  }

  String getChecksum() {
    int amountInPaise =
    (widget.amount * 100).toInt(); // Convert amount to the smallest unit
    final reqdata = {
      "merchantId": merchantId,
      "merchantTransactionId": "t_52554",
      "merchantUserId": "MUID123",
      "amount": amountInPaise,
      "callbackUrl": callback,
      "mobileNumber": "9999999999",
      "paymentInstrument": {"type": "PAY_PAGE"}
    };

    String base64body = base64.encode(utf8.encode(json.encode(reqdata)));

    checksum =
    '${sha256.convert(utf8.encode(base64body + apiEndPoint + saltKey)).toString()}###$saltIndex';

    return base64body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(result != null
            ? result.toString()
            : 'Initializing Payment Gateway...'),
      ),
    );
  }
}
