import 'package:cloud_firestore/cloud_firestore.dart';

class GetUser{
  final String username;
  final String email;
  final String photoUrl;


  GetUser({
    this.username,
    this.email,
    this.photoUrl,
  });

  factory GetUser.fromDocument(DocumentSnapshot doc) {
    return GetUser(
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['image_url'],
    );
  }
}