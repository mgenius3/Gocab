import 'package:flutter/material.dart';
import 'package:Gocab/utils/paystack_payment.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:Gocab/utils/paystack_payment.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Gocab/app/sub_screens/rate_driver.dart';

class Payment extends StatefulWidget {
  double fareAmount;
  String assignedDriverId;
  Payment(
      {super.key, required this.fareAmount, required this.assignedDriverId});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String publicKey =
      'pk_test_ieu49ej839u984urenewuwe06eishra'; //pass in the public test key obtained from paystack dashboard here
  final plugin = PaystackPlugin(); // Create an instance

  //a method to show the message
  void _showPaymentMessage(String message) {
    Fluttertoast.showToast(msg: message);
  }

  @override
  void initState() {
    super.initState();
    plugin.initialize(publicKey: publicKey); // Call using the instance
    //----
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Make your Payment For Your Ride",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            const SizedBox(height: 10),
            Container(
              margin: EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Fare Amount".toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Divider(thickness: 2, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    "\u20A6" + widget.fareAmount.toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 50),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "This is the total trip fare amount. Please pay it to the driver",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                      padding: EdgeInsets.all(20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                        ),
                        onPressed: () async {
                          var response = await chargeCard(context,
                              plugin: plugin,
                              showMessage: _showPaymentMessage,
                              amount: widget.fareAmount.toInt());

                          if (response == true) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => RateDriverScreen(
                                          assignedDriverId:
                                              widget.assignedDriverId,
                                        )));
                          } else {
                            Fluttertoast.showToast(msg: "Please try again");
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => RateDriverScreen(
                                          assignedDriverId:
                                              widget.assignedDriverId,
                                        )));
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Pay :",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "\u20A6" + widget.fareAmount!.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            )
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ));
  }
}
