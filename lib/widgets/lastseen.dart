import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messenger/models/Getuserdata.dart';

class LastSeen extends StatefulWidget {
  @override
  _LastSeenState createState() => _LastSeenState();
}

class _LastSeenState extends State<LastSeen> {

  CollectionReference chatsRef = FirebaseFirestore.instance.collection('chats');
  String userName,currentUserId;
  bool isLoading = false;
  GetUser getUser;


  void getCurrentUser() async{
    setState(() {
      isLoading = true;
    });
    User user = await FirebaseAuth.instance.currentUser;
    currentUserId = user.uid.toString();
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("users").doc(currentUserId).get();
    getUser = GetUser.fromDocument(doc);
    userName = getUser.username;
/*
    userImage = getUser.photoUrl;
    emailId = getUser.email;

    print("Current user id is $currentUserId");
    print("Image url is $userImage and type is ${userImage}");
    print("Email id is $emailId");
    print("Username is $userName");
 */

    setState(() {
      isLoading = false;
    });
    getUserLastSeen();
  }

  void getUserLastSeen() async{
    print("In getUserLAstSeen");
    print("Current username is $userName and user id is $currentUserId");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
          stream: chatsRef.snapshots(),
          builder: (context,chatSnapshot){
            if (chatSnapshot.data == ConnectionState.done && chatSnapshot.data == null) {
              return Text("No Data",style: TextStyle(color: Colors.red,backgroundColor: Colors.white),);
            }
            else if(chatSnapshot.data == ConnectionState.done && chatSnapshot.data == null){
              return Text("Unable to get data");
            }
            else if(chatSnapshot.data == null){
              return Text("No data");
            }
            else {
              try {
                chatSnapshot.data.documents.forEach((doc){
                  if(doc.docmentID == '03Fr9umn5rmDO5H4wI4G'){
                    print("Value is ${doc['createdAt']}");
                  }
                });
                print("Chat snapshot variable is ${chatSnapshot.data}");

                return Text("aaa");
              }
              catch(e){
                print("Error is $e");
              }
            }

            return Text("Last message at");
          }
          ),
    );
  }
}
