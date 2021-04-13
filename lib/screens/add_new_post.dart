import 'dart:io';


import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journey_app/models/post.dart';

import 'package:journey_app/services/firestore_database.dart';
import 'package:toast/toast.dart';

class AddNewPostScreen extends StatefulWidget {
  @override
  _AddNewPostScreenState createState() => _AddNewPostScreenState();
}

class _AddNewPostScreenState extends State<AddNewPostScreen> {
  final TextEditingController title = TextEditingController();

  ImagePicker imagePicker;
  PickedFile file;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                width: MediaQuery.of(context).size.width * .5,
                height: 100,
                child: Stack(
                  children: [
                    file == null
                        ? Container()
                        : Image.file(
                            File(file.path),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt_rounded),
                        onPressed: _pickPhoto,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            TextField(
              controller: title,
              decoration: InputDecoration(hintText: 'Post'),
            ),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RaisedButton(
                    child: Text('Add'),
                    onPressed: () async {
                      if ( title.text.isEmpty) {
                        Toast.show('Post is Empty', context);
                        return;
                      }
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        FirestoreDatabase().addPost(
                            Post(
                                body: title.text,
                                id: '',
                                dateTime: DateTime.now(),
                                image: ''),
                            file);

                        Toast.show('Your Post Added Sucessfully!', context);
                        // }
                        Toast.show('Your Post has been Added!', context);
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.of(context).pop();
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        Toast.show(
                            'Something went wrong,please try again!', context);
                      }
                    })
          ],
        ),
      ),
    );
  }

  void _pickPhoto() async {
    file = await imagePicker.getImage(source: ImageSource.gallery);

    setState(() {});
  }
}
