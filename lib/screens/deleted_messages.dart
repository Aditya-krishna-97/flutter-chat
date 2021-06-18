import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class DeletedMessages extends StatefulWidget {
  @override
  _DeletedMessagesState createState() => _DeletedMessagesState();
}

class _DeletedMessagesState extends State<DeletedMessages> {
  List messagesList = [];
  List<Timestamp> timestampList = [];

  void hs(){
    print("onHorizontalDragStart");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Deleted"),
          actions:[
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
                        Icon(Icons.delete_outline,color: Colors.deepOrangeAccent,),
                        SizedBox(width: 8),
                        Text('Delete all Messages'),
                      ],
                    ),
                  ),
                  value: 'deleteall',
                ),
              ],
              onChanged: (itemIdentifier) {
                if (itemIdentifier == 'deleteall') {
                  print("Delete all messages");
                  final snackbarMSG = SnackBar(content: Text("Delete all messages is not implemented, please check the code"));
                  ScaffoldMessenger.of(context).showSnackBar(snackbarMSG);
                }
              },
            ),
          ]
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.black),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("deleted").orderBy("deletedOn",descending: true)
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
                      print("Message is deleted on ${messagesList[i]["deletedOn"]}");
                      print("Message is from ${messagesList[i]["from"]}");
                      print("Message is ${messagesList[i]["messageIs"]}");
                      timestampList.add(messagesList[i]["deletedOn"]);
                    }

                    return RawScrollbar(
                      thumbColor: Theme.of(context).primaryColor,
                      radius: Radius.circular(30),
                      child: ListView.builder(
                        itemCount: msgDocs.length,
                        itemBuilder: (ctx,index){
                          return Column(
                            children: [
                             // Text("Deleted on ${timestampList[index].toDate().toString().substring(0,10)}",style: TextStyle(color: Colors.blue),),
                              Card(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(Icons.details),
                                      title: Text(msgDocs[index]["from"],style: TextStyle(color: Colors.red),),
                                      subtitle: Text(msgDocs[index]["messageIs"],style: TextStyle(color: Colors.black)),
                                    ),
                                    Text("Deleted on ${timestampList[index].toDate().toString().substring(0,10)} at ${timestampList[index].toDate().toString().substring(11,16)}",style: TextStyle(color: Colors.blue),),
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
            )
          ],
        ),
      ),
    );
  }
}
