import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SavedMessages extends StatefulWidget {
  @override
  _SavedMessagesState createState() => _SavedMessagesState();
}

class _SavedMessagesState extends State<SavedMessages> {
  List messagesList = [];
  List<Timestamp> timestampList = [];

  void hs(){
    print("onHorizontalDragStart");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Saved Messages"),

      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.black),
        child: Center(
          child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("saved").orderBy("savedOn",descending: true)
                        .snapshots(),
                    builder: (ctx, messageSnapshot) {
                      if (messageSnapshot.data == null) {
                        return Text("No data related to messages");
                      } else if (messageSnapshot.hasError) {
                        return Text("An unexpected error has occurred");
                      } else {
                        final msgDocs = messageSnapshot.data.docs;
                        messageSnapshot.data.docs.forEach((data){
                          messagesList.add(data);
                        });

                        for(int i=0;i<messagesList.length;i++){
                          print("Message is saved on ${messagesList[i]["savedOn"]}");
                          print("Message is from ${messagesList[i]["from"]}");
                          print("Message is ${messagesList[i]["messageIs"]}");
                          timestampList.add(messagesList[i]["savedOn"]);
                        }

                        return RawScrollbar(
                          thumbColor: Theme.of(context).primaryColor,
                          radius: Radius.circular(30),
                          child: ListView.builder(
                            itemCount: msgDocs.length,
                            itemBuilder: (ctx,index){
                              return Column(
                                children: [
                                  // Text("saved on ${timestampList[index].toDate().toString().substring(0,10)}",style: TextStyle(color: Colors.blue),),
                                  Card(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading: Icon(Icons.details),
                                          title: Text(msgDocs[index]["from"],style: TextStyle(color: Colors.red),),
                                          subtitle: Text(msgDocs[index]["messageIs"],style: TextStyle(color: Colors.black)),
                                        ),
                                        Text("saved on ${timestampList[index].toDate().toString().substring(0,10)} at ${timestampList[index].toDate().toString().substring(11,16)}",style: TextStyle(color: Colors.blue),),
                                      ],
                                    ),

                                    shadowColor: Colors.grey,
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
        ),
      ),
            );
  }
}
