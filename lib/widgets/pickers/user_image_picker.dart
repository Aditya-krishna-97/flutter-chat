import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class UserImagePicker extends StatefulWidget {
  UserImagePicker(this.imagePickFn);

  final void Function(File pickedImage) imagePickFn;

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage;
  var cameraStatus;


  void _pickImage() async {
    cameraStatus = await Permission.camera.status;
    print("In user_image_picker and Camera status is $cameraStatus");
    try{
      if(cameraStatus == PermissionStatus.granted){
        final picker = ImagePicker();
        final pickedImage = await picker.getImage(
          source: ImageSource.camera,
          imageQuality: 100,
          maxWidth: 150,
        );
        final pickedImageFile = File(pickedImage.path);

        setState(() {
          _pickedImage = pickedImageFile;
        });
        widget.imagePickFn(pickedImageFile);
      }
      else if(cameraStatus == PermissionStatus.denied){
        print("No camera access");
//        await Permission.camera.request();
        return showDialog(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text('Camera Permission'),
              content: Text(
                  'This app needs camera access to get user profile photo'),
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
    }
    catch(e){
      final snackbarMSG = SnackBar(content: Text("No image taken,so could not update profile pic. Please check permissions and try again"),backgroundColor: Colors.redAccent);
      ScaffoldMessenger.of(context).showSnackBar(snackbarMSG);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 40,
           // backgroundColor: Colors.grey,
            backgroundImage: _pickedImage != null ? FileImage(_pickedImage) : AssetImage('a.png'),
          ),
        ),
        FlatButton.icon(
          textColor: Theme.of(context).primaryColor,
          onPressed: _pickImage,
          icon: Icon(Icons.image),
          label: Text('Add Image'),
        ),
      ],
    );
  }
}
