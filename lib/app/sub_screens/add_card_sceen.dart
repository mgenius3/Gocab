import 'package:flutter/material.dart';
import 'package:Gocab/utils/paystack_payment.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'dart:io';

class AddCardScreen extends StatefulWidget {
  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cvcController = TextEditingController();
  TextEditingController expiryMonthController = TextEditingController();
  TextEditingController expiryYearController = TextEditingController();
  String publicKey =
      'pk_test_ieu49ej839u984urenewuwe06eishra'; //pass in the public test key obtained from paystack dashboard here

  final plugin = PaystackPlugin(); // Create an instance

  @override
  void initState() {
    super.initState();
    plugin.initialize(publicKey: publicKey); // Call using the instance
    cardNumberFocusNode.addListener(() {
      if (!cardNumberFocusNode.hasFocus) {
        cardNumberController.text =
            cardNumberController.text.replaceAll(' ', '');
      }
    });
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    cvcController.dispose();
    expiryMonthController.dispose();
    expiryYearController.dispose();
    super.dispose();
  }

  initiatePayment(BuildContext context) {
    print("hello");
    // makePayment(context, 200, "benmos16@gmail.com", "payment", paystackPlugin);
  }

  void moveToNextField(FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  final FocusNode cardNumberFocusNode = FocusNode();
  final FocusNode cvcFocusNode = FocusNode();
  final FocusNode expiryMonthFocusNode = FocusNode();
  final FocusNode expiryYearFocusNode = FocusNode();

  //a method to show the message
  void _showMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // //used to generate a unique reference for payment
  // String _getReference() {
  //   var platform = (Platform.isIOS) ? 'iOS' : 'Android';
  //   final thisDate = DateTime.now().millisecondsSinceEpoch;
  //   return 'ChargedFrom${platform}_$thisDate';
  // }

  // //async method to charge users card and return a response
  // chargeCard() async {
  //   var charge = Charge()
  //     ..amount = 10000 *
  //         100 //the money should be in kobo hence the need to multiply the value by 100
  //     ..reference = _getReference()
  //     ..putCustomField('custom_id',
  //         '846gey6w') //to pass extra parameters to be retrieved on the response from Paystack
  //     ..email = 'tutorial@email.com';

  //   CheckoutResponse response = await plugin.checkout(
  //     context,
  //     method: CheckoutMethod.card,
  //     charge: charge,
  //   );

  //   //check if the response is true or not
  //   if (response.status == true) {
  //     //you can send some data from the response to an API or use webhook to record the payment on a database
  //     _showMessage('Payment was successful!!!');
  //   } else {
  //     //the payment wasn't successsful or the user cancelled the payment
  //     _showMessage('Payment Failed!!!');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Card Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: cardNumberController,
              maxLength: 19, // Maximum card number length (with spaces)
              decoration: InputDecoration(labelText: 'Card Number'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                if (value.length == 19) {
                  moveToNextField(cardNumberFocusNode, cvcFocusNode);
                }
              },
            ),
            TextField(
              controller: cvcController,
              maxLength: 4, // Maximum CVC length
              decoration: InputDecoration(labelText: 'CVC'),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                if (value.length == 4) {
                  moveToNextField(cvcFocusNode, expiryMonthFocusNode);
                }
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: expiryMonthController,
                    maxLength: 2, // Maximum expiry month length
                    decoration: InputDecoration(labelText: 'Expiry Month'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) {
                      if (value.length == 2) {
                        moveToNextField(
                            expiryMonthFocusNode, expiryYearFocusNode);
                      }
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: expiryYearController,
                    maxLength: 2, // Maximum expiry year length
                    decoration: InputDecoration(labelText: 'Expiry Year'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => chargeCard(context,
                  plugin: plugin,
                  showMessage: _showMessage,
                  amount: 100.00.toInt()),
              child: Text('Add Card'),
            ),
          ],
        ),
      ),
    );
  }
}
