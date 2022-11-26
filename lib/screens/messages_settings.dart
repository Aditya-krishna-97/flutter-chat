import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessagesSettings extends StatefulWidget {


  @override
  _MessagesSettingsState createState() => _MessagesSettingsState();
}

class _MessagesSettingsState extends State<MessagesSettings> {

  var GetMessagestextValue = 'GetMessages : ';
  var MessagesAlreadyPresenttextvalue = 'MessagesAlreadyPresent: ';

  DocumentReference checkUserRef = FirebaseFirestore.instance.collection("checkuser").doc("name");
  

  Future<dynamic> toggleGetMessages(bool a) {
    print("Change value in GetMessages to $a");
    try{
      checkUserRef.update({
        'getMessages':a
      });
    }
    catch(e){
      print(e.toString());
    }
  }

  Future<dynamic> deleteAllMessages(){
    print("Now delete messages collection");
    FirebaseFirestore.instance.collection('messages').get().then((snapshot){
      for(DocumentSnapshot ds in snapshot.docs){
        ds.reference.delete();
      }
    }).whenComplete(() {
      print("Deleted all messages");
      toggleMessagesAlreadyPresent(false);
    });
  }

  Future<bool> toggleMessagesAlreadyPresent(bool b){
    print("Change value in MessagesAlreadyPresent to $b");
    try{
      checkUserRef.update({
        'messagesAlreadyPresent':b
      });
    }
    catch(e){
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MessagesSettings"),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.black),
        padding: EdgeInsets.all(10),
        child: Center(
          child: StreamBuilder(
              stream: checkUserRef.snapshots(),
              builder: (context, snapshot) {
              if(snapshot.hasData == null){
                return CircularProgressIndicator.adaptive();
              }
              else if(snapshot.connectionState == ConnectionState.waiting){
                return Center(child: CircularProgressIndicator(),);
              }
              var userDocument = snapshot.data;
              return  Column(
                  children: [
                    userDocument["messagesAlreadyPresent"] ? Row(
                      children: [
                        OutlinedButton(
                            onPressed: deleteAllMessages,
                            child: Text("Clear already present messages",style: TextStyle(fontSize: 20),),
                            style: OutlinedButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.red.shade500
                          ),
                        ),
                      ],
                    ):Text("No messages present",style: TextStyle(color: Colors.green,fontSize: 20),),
                    Padding(padding: EdgeInsets.only(top: 15)),
                    Row(
                      children: [
                        Text("Make getMessages to ",style: TextStyle(color: Colors.red),),
                        Text("true",style: TextStyle(color: Colors.blue),),
                        Text(" and",style: TextStyle(color: Colors.red),),
                      ],
                    ),
                    Row(
                      children: [
                        Text("messagesAlreadyPresent to ", style: TextStyle(color: Colors.red),),
                        Text("false", style: TextStyle(color: Colors.blue),),
                        Text(" to fetch messages",style: TextStyle(color: Colors.red),)
                      ],
                    ),
                    Row(
                      children: [
                        Text(GetMessagestextValue,style: TextStyle(fontSize: 20,color: Colors.lightGreenAccent),),
                        Text(userDocument["getMessages"].toString(),style: TextStyle(fontSize: 20,color: Colors.amber),),
                        Padding(padding: EdgeInsets.only(left: 10)),
                        Switch(onChanged: (value){
                          setState(() {
                            print("getMessagesValue is $value");
                            toggleGetMessages(value);
                          });
                        },
                          value: userDocument["getMessages"],
                          activeColor: Colors.green,
                          activeTrackColor: Colors.green,
                          inactiveThumbColor: Colors.redAccent,
                          inactiveTrackColor: Colors.red,  ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(MessagesAlreadyPresenttextvalue,style: TextStyle(fontSize: 18,color: Colors.cyanAccent),),
                        Text(userDocument["messagesAlreadyPresent"].toString(),style: TextStyle(fontSize: 18,color: Colors.white60),),
                        Padding(padding: EdgeInsets.only(left: 10)),
                        Switch(onChanged: (value){
                          setState(() {
                            print("MessagesAlreadyPresent value is $value");
                            toggleMessagesAlreadyPresent(value);
                          });
                        },
                          value: userDocument["messagesAlreadyPresent"],
                          activeColor: Colors.green,
                          activeTrackColor: Colors.lightGreenAccent,
                          inactiveThumbColor: Colors.redAccent,
                          inactiveTrackColor: Colors.red,  ),
                      ],
                    ),
                  ],
                );

            }
          ),
        ),
      ),
    );
  }
}
