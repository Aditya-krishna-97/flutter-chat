import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewMessage extends StatefulWidget {
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var _controller = new TextEditingController();
  var _enteredMessage = '';
  FocusNode inputFocusNode;

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
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    inputFocusNode.dispose();
    super.dispose();
  }

  void _getLocation() {
    print("Getting location");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: <Widget>[
          Expanded(
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
                  _enteredMessage = value;
                });
              },
              onTap: _getLocation,
            ),
          ),
          IconButton(
            color: Colors.blue,
            icon: Icon(Icons.send,),
            onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
          )
        ],
      ),
    );
  }
}