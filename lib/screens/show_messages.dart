import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:messenger/screens/deleted_messages.dart';
import 'package:messenger/screens/messages_settings.dart';
import 'package:messenger/screens/saved_messages.dart';

class InboxMessages extends StatefulWidget {
  @override
  _InboxMessagesState createState() => _InboxMessagesState();
}

class _InboxMessagesState extends State<InboxMessages> {

  void hs(){
    print("onHorizontalDragStart");
  }

  dynamic DeleteMessage(String from,String messageIs) async{
    print("Delete the message $messageIs which is from $from");
    //store the message into deleted collection and then remove it from messages collection
    // 1) storing the message into deleted collection
    try {
      FirebaseFirestore.instance.collection("deleted").add({
        "from": from,
        "messageIs": messageIs,
        "deletedOn": FieldValue.serverTimestamp(),
      }).catchError((e) {
        print("Error is from deleted collection and the error is $e");
      }).whenComplete(() {
        FirebaseFirestore.instance.collection("messages").where("messageIs", isEqualTo: messageIs).get().then((value) {
                  value.docs.forEach((element) {
                                FirebaseFirestore.instance.collection("messages").doc(element.id).delete().then((value) {
                                  print("$messageIs which is from $from has been deleted successfully and has been added to deleted collection");
                                                                                                                        }).catchError((e) {
                                                                                print("Error is from deleting from messages and the error is $e");
                                                                                                                                          });
          });
        });
      });
    }
    catch (e){
      print("error is $e");
    }

  }

  dynamic SaveMessage(String from,String messageIs) async{
    print("Saving message to saved collection");
    try{
      FirebaseFirestore.instance.collection("saved").add({
        "from": from,
        "messageIs": messageIs,
        "savedOn": FieldValue.serverTimestamp(),
      }).catchError((e) {
        print("Error is from deleted collection and the error is $e");
      }).whenComplete(() {
        FirebaseFirestore.instance.collection("messages").where("messageIs", isEqualTo: messageIs).get().then((value) {
          value.docs.forEach((element) {
            FirebaseFirestore.instance.collection("messages").doc(element.id).delete().then((value) {
              print("$messageIs which is from $from has been saved successfully and has been added to saved collection");
            }).catchError((e) {
              print("Error is from deleting from messages and the error is $e");
            });
          });
        });
      });
    }
    catch(e){
      print("Error while saving the message and the error is $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages",style: TextStyle(fontSize: 16),),
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
                      Text('Deleted Messages'),
                    ],
                  ),
                ),
                value: 'deleted',
              ),

              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.save,color: Colors.blue,),
                      SizedBox(width: 8),
                      Text('Saved'),
                    ],
                  ),
                ),
                value: 'saved',
              ),
              DropdownMenuItem(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.delete_forever,color: Colors.red,),
                      SizedBox(width: 8),
                      Text('Messages Settings'),
                    ],
                  ),
                ),
                value: 'messagessettings',
              ),

            ],
            onChanged: (itemIdentifier) {
              if (itemIdentifier == 'deleted') {
                print("Show deleted messages");
                Navigator.push(context, MaterialPageRoute(builder: (context) => DeletedMessages()));
              }
              if(itemIdentifier == 'saved'){
                print("Show saved messages");
                Navigator.push(context, MaterialPageRoute(builder: (context) => SavedMessages()));
              }
              if(itemIdentifier == 'messagessettings'){
                print("Show Messages settings");
                Navigator.push(context, MaterialPageRoute(builder: (context) => MessagesSettings()));
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
                     .collection("messages")
                     .snapshots(),
                 builder: (ctx, messageSnapshot) {
                   if (messageSnapshot.data == null) {
                     return Text("No data related to messages",style: TextStyle(color: Colors.tealAccent),);
                   } else if (messageSnapshot.hasError) {
                     return Text("An unexpected error has occurred",style: TextStyle(color: Colors.tealAccent),);
                   } else {
                     final msgDocs = messageSnapshot.data.docs;
                     return RawScrollbar(
                       thumbColor: Theme.of(context).primaryColor,
                       radius: Radius.circular(30),
                       child: ListView.builder(
                         itemCount: msgDocs.length,
                         itemBuilder: (ctx,index){
                           return Slidable(
                             actionPane: SlidableScrollActionPane(),
                             actionExtentRatio: 1/4,
                             actions: [
                               IconSlideAction(
                                 caption: 'Delete',
                                 color: Colors.red,
                                 icon: Icons.delete,
                                 onTap: () => DeleteMessage(msgDocs[index]["from"].toString(),msgDocs[index]["messageIs"].toString()),
                             //        ()=>print("Delete the message ${msgDocs[index]["messageIs"]} which is from ${msgDocs[index]["from"]}"),
                               ),
                               IconSlideAction(
                                 caption: 'Save',
                                 color: Colors.blue,
                                 icon: Icons.delete,
                                 onTap: () => SaveMessage(msgDocs[index]["from"].toString(),msgDocs[index]["messageIs"].toString()),
                               ),
                               IconSlideAction(
                                 caption: 'Do nothing',
                                 color: Colors.tealAccent,
                                 icon: Icons.delete,
                                 onTap: ()=>print("Do nothing"),
                               ),
                               IconSlideAction(
                                 caption: 'Do nothing',
                                 color: Colors.purpleAccent,
                                 icon: Icons.delete,
                                 onTap: ()=>print("Do nothing"),
                               ),
                             ],
                             child:Padding(
                               padding: const EdgeInsets.only(top: 5,bottom: 2),
                               child: ListTile(
                                 title:Text(msgDocs[index]["from"],style: TextStyle(color: Colors.blue),),
                                 subtitle: Text(msgDocs[index]["messageIs"],style: TextStyle(color: Colors.white),),
                                 isThreeLine: true,
                               ),
                             ),
                           );
                         },

                       ),
                     );
                     /*
                       ListView.builder(
                         itemCount: msgDocs.length,
                         itemBuilder: (ctx, index) {
                           return (Row(
                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                             children: [
                               Text(msgDocs[index].data()["from"]),
                               Spacer(),
                               Text(msgDocs[index].data()["messageIs"]),
                             ],
                           ));
                         });

                      */
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
