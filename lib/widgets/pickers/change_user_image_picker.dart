import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChangeUserImagePicker extends StatefulWidget {
  ChangeUserImagePicker(this.imagePickFn);

  final void Function(File pickedImage) imagePickFn;

  @override
  _ChangeUserImagePickerState createState() => _ChangeUserImagePickerState();
}

class _ChangeUserImagePickerState extends State<ChangeUserImagePicker> {
  File _pickedImage;

  void _pickImage() async {
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 40,
            // backgroundColor: Colors.grey,
            backgroundImage: _pickedImage != null ? FileImage(_pickedImage) : null,
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
