import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class PhonePePayment extends StatefulWidget {
  const PhonePePayment({super.key});

  @override
  State<PhonePePayment> createState() => _PhonePePaymentState();
}

class _PhonePePaymentState extends State<PhonePePayment> {


   String environment = "UAT_SIM";
   String appId = "";
   String merchantId = "PGTESTPAYUAT86";
   bool enableLogging = true;

   String checksum = "";
   String saltKey = "96434309-7796-489d-8924-ab56988a6076";
   String saltIndex = "1";

   String callbackUrl = "https://webhook.site/callback-url";

   String body = "";

   Object? result ;

   String apiEndPoint = "pg/v1/pay";

   String packagename = '';


   getChecksum() {
    final requestData = {
      "merchantId": merchantId,
      "merchantTransactionId": "transaction_123",
      "merchantUserId": "90223250",
      "amount": 1000,
      "mobileNumber": "9999999999",
      "callbackUrl": callbackUrl,
      "paymentInstrument": {"type": "PAY_PAGE"}
     };


    String base64Body = base64.encode(utf8.encode(json.encode(requestData)));

    checksum = '${sha256.convert(utf8.encode(base64Body+apiEndPoint+saltKey)).toString()}###$saltIndex';

    return base64Body;

   }

   @override 
   void initState() {
    super.initState();

    phonepeInit();

    body = getChecksum().toString();

   }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Gateway",
        style: GoogleFonts.mulish(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        ),
      ),

      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              startPgTransaction();
              
            },
            child: Text("Start Transaction",),
          ),

          const SizedBox(height: 20),

          Text("Result /n $result"),

        ],
      ),

    );
  }


  void phonepeInit() {

    PhonePePaymentSdk.init(environment, appId, merchantId, enableLogging)
        .then((val) => {
              setState(() {
                result = 'PhonePe SDK Initialized - $val';
              })
            })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });

  }
  
  void startPgTransaction() async {


    try {
      var response = PhonePePaymentSdk.startTransaction(
          body, callbackUrl, checksum, packagename);
      response
          .then((val) => {
                setState(() {
                
                if (val != null) {
                  
                  String status = val['status'].toString();
                  String error = val['error'].toString();

                  if (status == 'SUCCESS') {
                    result = "FLow Complete - status: SUCCESS";
                  } else {
                    result = "Flow Complete - status: $status and error: $error";
                  }

                } else {
                  result = "Flow Incomplete";
                }
                  
                })
              })
          .catchError((error) {
        handleError(error);
        return <dynamic>{};
      });
    } catch (error) {
      handleError(error);
    }
  }

  void handleError(error) {
    setState(() {
      result = {"error" : error};
    }); 
  }
}