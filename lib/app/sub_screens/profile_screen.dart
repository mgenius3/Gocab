import 'package:flutter/material.dart';
import 'package:Gocab/global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../Assistants/assistant_method.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();

  // DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
  CollectionReference userRef = FirebaseFirestore.instance.collection('users');

  bool? refresh = false;

  Future<void> uploadImageToFirestore(String userId) async {
    try {
      // Pick an image from the device's gallery
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        // Create a reference to the Firebase Storage bucket
        Reference storageRef = FirebaseStorage.instance.ref();

        // Generate a unique ID for the image
        String imageName = DateTime.now().millisecondsSinceEpoch.toString();

        // Upload the image to Firestore
        TaskSnapshot snapshot = await storageRef
            .child('users/$userId/images/$imageName.jpg')
            .putFile(File(image.path));

        // Retrieve the download URL of the uploaded image
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Store the download URL in Firestore
        userRef.doc(userId).set({
          'image_url': downloadUrl,
        }, SetOptions(merge: true)).then((_) {
          Fluttertoast.showToast(msg: "Updated Successfully.");
          AssistantMethods.readCurrentOnlineUserInfo();
          setState(() {
            refresh = true;
          });
        }).catchError((error) {
          Fluttertoast.showToast(msg: "Error Occurred. \n $error");
        });
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> showUserNameDialogAlert(BuildContext context, String name) {
    nameTextEditingController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(children: [
                TextFormField(
                  controller: nameTextEditingController,
                )
              ]),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel", style: TextStyle(color: Colors.red))),
              TextButton(
                  onPressed: () {
                    userRef.doc(FirebaseAuth.instance.currentUser!.uid).update({
                      "name": nameTextEditingController.text.trim()
                    }).then((value) {
                      nameTextEditingController.clear();
                      Fluttertoast.showToast(msg: "Updated Successfully.");

                      AssistantMethods.readCurrentOnlineUserInfo();
                      setState(() {
                        refresh = true;
                      });
                    }).catchError((errorMessage) {
                      print("error");
                      Fluttertoast.showToast(
                          msg: "Error Occurred. \n $errorMessage");
                    });
                    Navigator.pop(context);
                  },
                  child: Text("OK", style: TextStyle(color: Colors.black))),
            ],
          );
        });
  }

  Future<void> showAddressDialogAlert(BuildContext context, String name) {
    addressTextEditingController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(children: [
                TextFormField(
                  controller: addressTextEditingController,
                )
              ]),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel", style: TextStyle(color: Colors.red))),
              TextButton(
                  onPressed: () {
                    userRef.doc(FirebaseAuth.instance.currentUser!.uid).update({
                      "address": addressTextEditingController.text.trim()
                    }).then((value) {
                      addressTextEditingController.clear();
                      Fluttertoast.showToast(msg: "Updated Successfully.");

                      AssistantMethods.readCurrentOnlineUserInfo();
                      setState(() {
                        refresh = true;
                      });
                    }).catchError((errorMessage) {
                      print("error");
                      Fluttertoast.showToast(
                          msg: "Error Occurred. \n $errorMessage");
                    });
                    Navigator.pop(context);
                  },
                  child: Text("OK", style: TextStyle(color: Colors.black))),
            ],
          );
        });
  }

  Future<void> showPhoneDialogAlert(BuildContext context, String name) {
    phoneTextEditingController.text = name;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update"),
            content: SingleChildScrollView(
              child: Column(children: [
                TextFormField(
                  controller: phoneTextEditingController,
                )
              ]),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel", style: TextStyle(color: Colors.red))),
              TextButton(
                  onPressed: () {
                    userRef.doc(FirebaseAuth.instance.currentUser!.uid).update({
                      "phone": phoneTextEditingController.text.trim()
                    }).then((value) {
                      phoneTextEditingController.clear();
                      Fluttertoast.showToast(msg: "Updated Successfully.");

                      AssistantMethods.readCurrentOnlineUserInfo();
                      setState(() {
                        refresh = true;
                      });
                    }).catchError((errorMessage) {
                      print("error");
                      Fluttertoast.showToast(
                          msg: "Error Occurred. \n $errorMessage");
                    });
                    Navigator.pop(context);
                  },
                  child: Text("OK", style: TextStyle(color: Colors.black))),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios, color: Colors.black)),
            title: Text("Profile Screen",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            centerTitle: true,
            elevation: 0.0,
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 50),
              child: Column(
                children: [
                  Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          uploadImageToFirestore(
                              FirebaseAuth.instance.currentUser!.uid);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50.5,
                              backgroundImage: NetworkImage(userModelCurrentInfo
                                      ?.image_url
                                      ?.toString() ??
                                  'https://img.icons8.com/color/48/circled-user-male-skin-type-4--v1.png'), // Replace with user's profile image
                            ),
                            Icon(Icons.camera_alt),
                          ],
                        ),
                      )),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${userModelCurrentInfo?.name}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () {
                            showUserNameDialogAlert(
                                context, userModelCurrentInfo?.name ?? "");
                          },
                          icon: Icon(
                            Icons.edit,
                          ))
                    ],
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${userModelCurrentInfo?.phone}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () {
                            showPhoneDialogAlert(
                                context, userModelCurrentInfo?.phone ?? "");
                          },
                          icon: Icon(
                            Icons.edit,
                          ))
                    ],
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${userModelCurrentInfo?.address}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () {
                            showAddressDialogAlert(
                                context, userModelCurrentInfo?.address ?? "");
                          },
                          icon: Icon(
                            Icons.edit,
                          ))
                    ],
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Text(
                    "${userModelCurrentInfo?.email}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
