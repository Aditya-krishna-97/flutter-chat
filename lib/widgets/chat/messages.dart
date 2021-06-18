import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'message_bubble.dart';

class Messages extends StatefulWidget {

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  ScrollController _chatScrollController;
  int _currentMax = 15;
  var cameraStatus,alwaysLocationStatus,inUseLocationStatus,galleryStatus;

  CollectionReference chatsRef = FirebaseFirestore.instance.collection('chats');

  _checkPermissions() async{
    cameraStatus = await Permission.camera.status;
    alwaysLocationStatus = await Permission.locationAlways.status;
    inUseLocationStatus = await Permission.locationWhenInUse.status;
    galleryStatus = await Permission.mediaLibrary.status;

    print("Camera status is $cameraStatus & alwaysLocation is $alwaysLocationStatus & inUseLocationStatus is $inUseLocationStatus & galleryStatus is $galleryStatus");
  }


  @override
  void initState() {
    // TODO: implement initState
    _checkPermissions();
    _chatScrollController = ScrollController()
      ..addListener(() {
        if(_chatScrollController.position.atEdge) {
          if (_chatScrollController.position.pixels == 1) {
            print("Pixels = 1");
          }
        }

        if(_chatScrollController.position.pixels == _chatScrollController.position.maxScrollExtent){

          _getMoreData();
          print("_chatScrollController.position.maxScrollExtent current position is ${_chatScrollController.position.maxScrollExtent}");
          print("Current max is $_currentMax");
          setState(() {
            _currentMax = _currentMax + 10;

          });
        }
                          });
    super.initState();
  }
  _getMoreData(){
    print("in Get more data");
  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
            stream: chatsRef.orderBy('createdAt', descending: true,).limit(_currentMax).snapshots(),
            builder: (ctx, chatSnapshot) {
              if(chatSnapshot.connectionState == ConnectionState.none){
                print("Connectionstate is none");
              }
              if(chatSnapshot.connectionState == ConnectionState.active){
                print("Connection state is active");
              }
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                print("Connection state is waiting");
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if(chatSnapshot.data == ConnectionState.done){
                print("Connection state is done, no internet found");
              }
              if (chatSnapshot.data == ConnectionState.done && chatSnapshot.data == null) {
                return Text("No Data",style: TextStyle(color: Colors.white,backgroundColor: Colors.white),);
              }
              if(chatSnapshot.data == null){
                print("No data");
                return Text("No Messages",style: TextStyle(color: Colors.white,backgroundColor: Colors.white),);
              }
              else if(chatSnapshot.hasError){
                print("Error in snapshot");
                return null;
              }
              else {
                final chatDocs = chatSnapshot.data.docs;
                print("Total number of documents retrieved are ${chatDocs.length}");
                print("########################################################################################################################");
                for (int i=0; i<chatDocs.length;i++){
                  DocumentSnapshot doc = chatSnapshot.data.docs.elementAt(i);
                  //print(doc.metadata.isFromCache ? "FROM CACHE" : "FROM NETWORK");
                  print("${doc.metadata.isFromCache ? "FROM CACHE" : "FROM NETWORK"} and current document length is ${doc.data().toString().length}, current username is ${doc.get("username")} and the message is ${doc.get("text")}");
                }
                print("########################################################################################################################");

                return RawScrollbar(
                  thumbColor: Theme.of(context).primaryColor,
                  radius: Radius.circular(30),
                  child: ListView.builder(
                    controller: _chatScrollController,
                    reverse: true,
                    itemCount: chatDocs.length,
                    itemBuilder: (ctx, index) =>
                        MessageBubble(
                          chatDocs[index].data()['text'],
                          chatDocs[index].data()['username'],
                          chatDocs[index].data()['userImage'],
                          chatDocs[index].data()['userId'] == user.uid,
                          key: ValueKey(chatDocs[index].id),
                        ),
                  ),
                );
              }
            }
            );
  }
}
