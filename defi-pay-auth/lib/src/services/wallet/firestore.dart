import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

void addUserDetails(privateKey, publicKey) async {
  var userInstance = FirebaseAuth.instance.currentUser;
  print(userInstance?.uid);
  await FirebaseFirestore.instance
      .collection("users")
      .doc(userInstance!.email)
      .set({
        'email': userInstance.email,
        'privateKey': privateKey.toString(),
        'publicKey': publicKey.toString(),
        'wallet_created': true
      })
      .whenComplete(() => {print("executed")})
      .catchError((error) {
        print(error.toString());
      });
}

Future<dynamic> getUserDetails() async {
  dynamic data;
  log("In user details");
  var userInstance = FirebaseAuth.instance.currentUser;
  final DocumentReference document =
      FirebaseFirestore.instance.collection("users").doc(userInstance!.email);
  await document.get().then<dynamic>((DocumentSnapshot snapshot) {
    data = snapshot.data();
  });
  log("Outside");
  return data;
}
