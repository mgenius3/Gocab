import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? phone;
  String? name;
  String? id;
  String? email;
  String? address;
  String? image_url;

  UserModel(
      {this.name,
      this.phone,
      this.email,
      this.id,
      this.address,
      this.image_url});

  // UserModel.fromSnapshot(DataSnapshot snap){
  //   phone = (snap.value as dynamic)["phone"];
  //   name = (snap.value as dynamic)["name"];
  //   id = snap.key;
  //   email = (snap.value as dynamic)["email"];
  //   address = (snap.value as dynamic)["address"];
  // }
  UserModel.fromSnapshot(DocumentSnapshot snap) {
    Map<String, dynamic>? data = snap.data() as Map<String, dynamic>?;

    // Now you can safely access the data.
    phone = data?.containsKey("phone") == true ? data!["phone"] : '---';
    name = data?.containsKey("name") == true ? data!["name"] : '---';
    id = snap.id;
    email = data?.containsKey("email") == true ? data!["email"] : '---';
    address = data?.containsKey("address") == true ? data!["address"] : '---';
    image_url =
        data?.containsKey("image_url") == true ? data!["image_url"] : '---';
  }
}
