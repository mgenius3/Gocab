import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Drivers {
  final _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<void> registerTaxiDriver(
      String name,
      String email,
      String phoneNumber,
      String vehicleInformation,
      String location,
      String country,
      String state,
      String meansOfIdentity,
      File? documents,
      String licensePlate) async {
    final user = _firebaseAuth.currentUser;
    print(user);
    final uid = user?.uid;

    final storageRef =
        FirebaseStorage.instance.ref().child('documents').child(uid!);
    final uploadTask = storageRef.putFile(documents!);

    final taskSnapshot = await uploadTask.whenComplete(() {});

    if (taskSnapshot.state == TaskState.success) {
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('drivers').doc(uid).set({
        "name": name,
        "email": email,
        "phoneNumber": phoneNumber,
        "vehicleInformation": vehicleInformation,
        "location": location,
        "country": country,
        "state": state,
        "meansOfIdentity": meansOfIdentity,
        'licensePlate': licensePlate,
        'documentUrl': downloadUrl,
      });
    } else {
      // Handle file upload error
      throw Exception('Failed to upload document file.');
    }
  }
}
