import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewImagePickerAndSend extends StatefulWidget {

  @override
  _NewImagePickerAndSendState createState() => _NewImagePickerAndSendState();
}

class _NewImagePickerAndSendState extends State<NewImagePickerAndSend> {
  File imageFile;

  Future getImage() async {
    // final _picker = ImagePicker();
    // // Pick an image
    // final XFile? image = await _picker.getImage(source: ImageSource.gallery);
    // // Capture a photo
    // final XFile? photo = await _picker.getImage(source: ImageSource.camera);
    // // Pick a video
    // final XFile? image = await _picker.getVideo(source: ImageSource.gallery);
    // // Capture a video
    // final XFile? video = await _picker.getVideo(source: ImageSource.camera);
    // Pick multiple images
    //final List<XFile>? images = await _picker.getImage(,source: ImageSource.gallery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ImagePicker'),
      ),
      body: Container(
          child:Column(
            children: [
              IconButton(
                  onPressed: getImage,
                  color: Colors.blue,
                  icon: Icon(Icons.attach_file,color: Colors.grey,)
      ),
            ],
          )
      ),
    );
  }
}
