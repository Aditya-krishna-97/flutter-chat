import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/models/Getuserdata.dart';
import 'package:messenger/widgets/lastseen.dart';

import 'package:messenger/widgets/pickers/change_user_image_picker.dart';
import 'package:messenger/widgets/pickers/user_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  DateTime a;
  bool isLoading = false;
  String currentUserId,userImage,userName,emailId,profilePic,uuid,url,otherUser,lastMessageDate,lastMessageTime,h;
  var updatedProfilePicName;
  File _userImageFile;
  GetUser getUser;
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  CollectionReference chatsRef = FirebaseFirestore.instance.collection('chats');
  final firebaseStorageRef = FirebaseStorage.instance.ref().child('user_image');
  File _image;
  final picker = ImagePicker();
  var cameraStatus;
  int messagesLimit = 30;

  void _showPicker(context) {
    updatedProfilePicName = Uuid().v4().toString();
    print("in _showPicker and updated profile-pic name is ${updatedProfilePicName}");
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  _imgFromCamera() async {
    cameraStatus = await Permission.camera.status;
    print("Camera status is $cameraStatus");
    try {
      if (cameraStatus == PermissionStatus.granted) {
        print("In _imgFromCamera");
        final pickedImage = await picker.getImage(
            source: ImageSource.camera, imageQuality: 100
        );
        final pickedImageFile = File(pickedImage.path);
        if (pickedImageFile != null) {
          setState(() {
            _image = pickedImageFile;
          });
          print("Received image from user");
          print(
              "Now calling pushImageToFirebase to replace the link in firestore");
          pushImageToFirebase();
        }
        else{
          print("No image picked");
        }
      }

      else if(cameraStatus == PermissionStatus.denied){
        print("No camera access");
//        await Permission.camera.request();
        return showDialog(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text('Camera Permission'),
              content: Text(
                  'This app needs camera access to update user profile photo'),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text('Deny'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child: Text('Settings'),
                  onPressed: () => openAppSettings(),
                ),
              ],
            ));
      }

      else{
        print("Now what should i do");
      }
    } catch(e){
      print("Error in settings is ${e.toString()}");
      final snackbarMSG = SnackBar(content: Text("No image taken,so could not update profile pic. Please try again"),backgroundColor: Colors.redAccent);
      ScaffoldMessenger.of(context).showSnackBar(snackbarMSG);
    }

  }

  _imgFromGallery() async {
    print("In _imgFromGallery");
    final pickedImage = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 100
    );
    final pickedImageFile = File(pickedImage.path);
    if(pickedImageFile != null){
      setState(() {
        _image = pickedImageFile;
      });
      print("Received image from user");
      print("Now calling pushImageToFirebase to replace the link in firestore");
      pushImageToFirebase();
    }
    else{
      print("No image picked");
      final snackbarMSG = SnackBar(content: Text("No image picked,so could not update profile pic"));
      ScaffoldMessenger.of(context).showSnackBar(snackbarMSG);
    }

  }

  pushImageToFirebase() async{
    try {
      print("About to upload pic to firebase");
      print("Pic name is ${updatedProfilePicName.toString()}");
      String filePath = '${updatedProfilePicName.toString() + '.jpg'}';
      final ref = firebaseStorageRef.child(filePath);

      await ref.putFile(_image);

      url = await ref.getDownloadURL();
      print("The url is $url and Now upload pic to firestore");
      updateProfilePicInFirestore(url);
    } on PlatformException catch(err){
      var message="unknown error";
      if(err.message == null){
        print(message);
      }
    }


/*
    final ref = firebaseStorageRef.child(updatedProfilePicName + '.jpg');
    await ref.putFile(_image).whenComplete(() async {
      print("Then get its URL and provide it to updateProfilePicInFirestore method");
      url = await ref.getDownloadURL();
      print("New image URL is ${url.toString()}");
    });
 */
  }

  updateProfilePicInFirestore(String imageURL){
    print("Change image_url field in users collection");
    print(currentUserId);
    usersRef.doc(currentUserId).update({
      'image_url':imageURL,
    }).whenComplete(() {
      print("Updated profile pic");
      final snackbarMSG = SnackBar(content: Text("Profile pic updated successfully"));
      ScaffoldMessenger.of(context).showSnackBar(snackbarMSG);
    });
  }

  void _pickedImage(File image) {
    _userImageFile = image;
  }

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
    print("In getUserLastSeen");
    print("Current username is $userName and user id is $currentUserId");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    print("In settings screen");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.black),
        child: Column(
          children: [
            StreamBuilder(
                stream: usersRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data == ConnectionState.done && snapshot.data == null) {
                    return Text("No Data",style: TextStyle(color: Colors.white,backgroundColor: Colors.white),);
                  }
                  else{
                    final usersData = snapshot.data.docs;
                    for(int i=0;i<usersData.length;i++){
                      if(usersData[i].data()['username'].toString() == userName){
                        print("Hii, from settings screen");
                        print("Username is ${usersData[i].data()['username'].toString()}");
                        print("Image link is ${usersData[i].data()['image_url'].toString()}");
                        profilePic = usersData[i].data()['image_url'].toString();
                        print("Email id is ${usersData[i].data()['email'].toString()}");
                        return Container(
                          padding: EdgeInsets.only(top: 15,bottom: 20),
                          child: Center(
                            child: GestureDetector(
                              onTap: ()=>_showPicker(context),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(6),
                                    child: CircleAvatar(radius: 50.0,backgroundImage: NetworkImage(profilePic),),
//                          child: ChangeUserImagePicker(_pickedImage),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Text("Click here to update your profile pic",style: TextStyle(color: Colors.white),),)
                                ],
                              ),
                            ),
                          ),
                        );
                      }
//              print(usersData);
//              print("username is ${usersData[i].data()['username']}");
                    }
                  }
                  return Center(child: CircularProgressIndicator());
/*
                  return Container(
                      padding: EdgeInsets.only(top: 15,bottom: 20),
                      child: Center(
                        child: isLoading
                            ? CircularProgressIndicator()
                            : Column(
                          children: [
                            Padding(
                                padding: EdgeInsets.all(6),
                                child: GestureDetector(
                                    onTap: changeUserImage,
                                    child: ChangeUserImagePicker(_pickedImage),
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(6),
                              child: Text("Edit Username"),)
                          ]
                        )
                      ),
                  );
*/
                }
            ),
            StreamBuilder(
                stream: chatsRef.orderBy("createdAt",descending: true).limit(messagesLimit).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.data == ConnectionState.done && snapshot.data == null) {
                    return Text("No Data hereeeee",style: TextStyle(color: Colors.white,backgroundColor: Colors.white),);
                  }
                  else{
                    final messages = snapshot.data.docs;
                    List latestMessages = [];
                    snapshot.data.docs.forEach((data){
                      if(data["username"].toString() == "Sathwika"){
                        latestMessages.add(data);
                        //  print("Username is ${data["username"]} and message is ${data["text"]} which is sent at ${data["createdAt"].toString()}");
                      }
                    });
                    for(int i=0;i<latestMessages.length;i++){
                      if(i==0){
                        h =  latestMessages[i]["text"];
                        otherUser = latestMessages[i]["username"];
                        Timestamp msgCreatedAt = latestMessages[i]["createdAt"];
                        print(h);
                        print(otherUser);
                        a = msgCreatedAt.toDate();
                        print(a.toString());
                        //   print("Date is ${DateTime.parse(msgCreatedAt.toDate().toString().substring(9))}");
                      }
                    }


                    // snapshot.data.docs.map((doc) {print(doc["username"]);});
                    //  print(messages);
                    return Container(
                      child: Column(
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Last Message by $otherUser is: ", style: TextStyle(color: Colors.white,),),
                                ),
                                Padding(
                                    padding:EdgeInsets.all(5.0,),
                                    child:Text(h,style: TextStyle(color: Colors.lime,))
                                ),
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: Text(a.toString(),style: TextStyle(color: Colors.blue,)),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
/*
                      for(int i=0;i<messages.length;i++)
                      {
                        if(messages[i].data()['username'].toString() == "Sathwika"){
                          print("Hii, from settings screen");
                          print("Username is ${messages[i].data()['username'].toString()}");
                          print("Image link is ${messages[i].data()['userImage'].toString()}");
                          profilePic = messages[i].data()['userImage'].toString();
                          final DateTime messageDateTime = (messages[i].data()['createdAt']).toDate();

                          otherUser = messages[i].data()['username'].toString();
                          lastMessageDate = messageDateTime.toString().substring(0,10);
                          lastMessageTime = messageDateTime.toString().substring(11,19);
                          print(DateTime.now());
                          print(lastMessageDate);
                          print("Message created at $messageDateTime by ${messages[i].data()['username'].toString()} and the message "
                                    "is ${messages[i].data()['text'].toString()}");
                          h = otherUser + " texted you last on " + lastMessageDate + " at " +lastMessageTime;

                          return Container(
                            padding: EdgeInsets.only(top: 15,bottom: 20),
                            child: Center(
                              child: GestureDetector(
                                onTap: ()=>_showPicker(context),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Text(h),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        else{
                          return Container(
                            padding: EdgeInsets.only(top: 15,bottom: 20),
                            child: Center(
                              child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Text("No message"),
                                    ),
                                  ],
                                ),
                              ),
                          );
                        }
               print(usersData);
                print("username is ${usersData[i].data()['username']}");
                      }
  */
                  }
                  return Center(child: CircularProgressIndicator());
/*
                  return Container(
                      padding: EdgeInsets.only(top: 15,bottom: 20),
                      child: Center(
                        child: isLoading
                            ? CircularProgressIndicator()
                            : Column(
                          children: [
                            Padding(
                                padding: EdgeInsets.all(6),
                                child: GestureDetector(
                                    onTap: changeUserImage,
                                    child: ChangeUserImagePicker(_pickedImage),
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(6),
                              child: Text("Edit Username"),)
                          ]
                        )
                      ),
                  );
*/
                }
            ),
            Text("Version 1.0",style: TextStyle(color: Colors.red),),
            //    LastSeen(),
          ],
        ),
      ),

    );
  }
}