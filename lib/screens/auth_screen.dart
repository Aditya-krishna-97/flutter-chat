import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:messenger/widgets/auth/auth_form.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    print("In Auth screen");
    super.initState();
  }

  void _submitAuthForm(
    String email,
    String password,
    String username,
    File image,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        // ignore: missing_return
        );
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ).catchError((e){
          if(e == "email-already-in-use"){
            final snackBarContent = SnackBar(content: Text("Email already registered, Please signin"));
            print("Email already registered");
            ScaffoldMessenger.of(context).showSnackBar(snackBarContent);
          }
          print("Error is $e");
        });

        final ref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child(authResult.user.uid + '.jpg');

        await ref.putFile(image);

        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user.uid)
            .set({
          'username': username,
          'password':password,
          'email': email,
          'image_url': url,
        });
      }
    } catch (err) {
      print("Error is $err");
      if(err == "network-request-failed"){
        final snackBarContent = SnackBar(content: Text("Please check your internet connection"));
        print("Please check your internet connection");
        ScaffoldMessenger.of(context).showSnackBar(snackBarContent);
      }
      else if(err.code == "wrong-password"){
        final snackBarContent = SnackBar(content: Text("Please enter correct password"));
        print("Please enter correct password");
        ScaffoldMessenger.of(context).showSnackBar(snackBarContent);
      }
      else if(err.code == "user-not-found"){
        final snackBarContent = SnackBar(content: Text("No user found with this email id or user might have deregistered.So,please register again"));
        print("No user found with this email id, might have been deleted.Please register again");
        ScaffoldMessenger.of(context).showSnackBar(snackBarContent);
      }
      else if(err.code == "email-already-in-use"){
        final snackBarContent = SnackBar(content: Text("Email already in registered"));
        print("Email already registered");
        ScaffoldMessenger.of(context).showSnackBar(snackBarContent);
      }
      else if(err.code =="NoSuchMethodError"){
        setState(() {
          _isLoading = false;
        });
      }
      setState(() {
        _isLoading = false;
      });
    }

    on PlatformException catch (err) {
      var message = 'An error occurred, please check your credentials!';

      if (err.message != null) {
        message = err.message;
      }

      Scaffold.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _isLoading,
      ),
    );
  }
}
