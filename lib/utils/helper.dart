import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

String shortenString(String text) {
  const int maxLength = 30;

  if (text.length <= maxLength) {
    return text;
  } else {
    return text.substring(0, maxLength) + '...';
  }
}
