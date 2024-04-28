import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter/material.dart';
import 'dart:io';

//used to generate a unique reference for payment
String _getReference() {
  var platform = (Platform.isIOS) ? 'iOS' : 'Android';
  final thisDate = DateTime.now().millisecondsSinceEpoch;
  return 'ChargedFrom${platform}_$thisDate';
}

//async method to charge users card and return a response
Future<bool> chargeCard(BuildContext context,
    {required PaystackPlugin plugin,
    required Function showMessage,
    required int amount}) async {
  var charge = Charge()
    ..amount = amount *
        100 //the money should be in kobo hence the need to multiply the value by 100
    ..reference = _getReference()
    ..putCustomField('custom_id',
        '846gey6w') //to pass extra parameters to be retrieved on the response from Paystack
    ..email = 'tutorial@email.com';

  CheckoutResponse response = await plugin.checkout(
    context,
    method: CheckoutMethod.card,
    charge: charge,
  );

  //check if the response is true or not
  if (response.status == true) {
    //you can send some data from the response to an API or use webhook to record the payment on a database
    showMessage('Payment was successful!!!');
    return true;
  } else {
    //the payment wasn't successsful or the user cancelled the payment
    showMessage('Payment Failed!!!');
    return false;
  }
}
