import 'package:flutter/material.dart';
// import 'package:paystack_manager/paystack_manager.dart';

class AddCardScreen extends StatefulWidget {
  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cvcController = TextEditingController();
  TextEditingController expiryMonthController = TextEditingController();
  TextEditingController expiryYearController = TextEditingController();

  @override
  void dispose() {
    cardNumberController.dispose();
    cvcController.dispose();
    expiryMonthController.dispose();
    expiryYearController.dispose();
    super.dispose();
  }

  void initiatePayment() async {
    // ... your payment initiation code ...
  }

  void moveToNextField(FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

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
              onPressed: initiatePayment,
              child: Text('Make Payment'),
            ),
          ],
        ),
      ),
    );
  }

  final FocusNode cardNumberFocusNode = FocusNode();
  final FocusNode cvcFocusNode = FocusNode();
  final FocusNode expiryMonthFocusNode = FocusNode();
  final FocusNode expiryYearFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    cardNumberFocusNode.addListener(() {
      if (!cardNumberFocusNode.hasFocus) {
        cardNumberController.text =
            cardNumberController.text.replaceAll(' ', '');
      }
    });
  }
}

// void main() {
//   PaystackManager().initialize(publicKey: 'your_public_key');
//   runApp(MaterialApp(home: AddCardPage()));
// }
