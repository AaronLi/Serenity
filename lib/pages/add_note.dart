import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serenity/note/note.dart';
import 'package:serenity/note_storage/i_note_storage.dart';
import 'package:uuid/uuid.dart';

class NoteMakerScreen extends StatefulWidget {
  final String title;
  final INoteStorage noteStorageLocation;
  NoteMakerScreen(this.noteStorageLocation, {Key key, this.title})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _NoteMakerState();
}

class _NoteMakerState extends State<NoteMakerScreen> {
  final _noteMakerKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat(DateFormat.YEAR_MONTH_DAY);
  File _image;
  final _picker = ImagePicker();
  final _date = DateTime.now();
  Note noteOut = Note(Uuid().v4());

  void pickImage() async {
    final pickedImage = await _picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _image = File(pickedImage.path);
      } else {
        print("No image selected");
      }
    });
  }

  void submitNote() async {
    this._noteMakerKey.currentState.save();
    noteOut.setDate(_date);
    print("submitNote $_image");
    noteOut.setImage(_image);
    this.widget.noteStorageLocation.putNote(noteOut);
    print(await this.widget.noteStorageLocation.numNotes());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Form(
            key: _noteMakerKey,
            child: Scaffold(
              appBar: AppBar(title: Text(widget.title)),
              body: ListView(
                children: <Widget>[
                  InkWell(
                      onTap: pickImage,
                      child: Center(
                          child: AspectRatio(
                              aspectRatio: 500 / 200,
                              child: Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.fitWidth,
                                          image: (_image != null)
                                              ? FileImage(
                                                  _image,
                                                )
                                              : AssetImage(
                                                  "assets/beaver.jpg"))))))),
                  Padding(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: Column(children: <Widget>[
                        Text(
                          _dateFormat.format(_date),
                          textAlign: TextAlign.left,
                        ),
                        TextFormField(
                          onSaved: (newValue) => noteOut.setTitle(newValue),
                          decoration: const InputDecoration(
                            hintText: "Title",
                          ),
                          style: TextStyle(height: 1, fontSize: 35),
                          textCapitalization: TextCapitalization.words,
                          validator: (contents) {
                            if (contents.isEmpty) {
                              return "A title helps you when you look back";
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          onSaved: (newValue) => noteOut.setBody(newValue),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: const InputDecoration(
                              hintText: "Write about your day"),
                        )
                      ])),
                  Padding(
                      padding: EdgeInsets.only(left: 15, right: 15, top: 10),
                      child: ElevatedButton(
                          onPressed: submitNote, child: Text("Save")))
                ],
              ),
            )));
  }
}
