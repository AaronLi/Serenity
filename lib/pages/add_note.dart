import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serenity/note/note.dart';
import 'package:serenity/note_storage/i_note_storage.dart';
import 'package:serenity/sentiment_analysis/i_sentiment_analysis.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';

class NoteMakerScreen extends StatefulWidget {
  final String title;
  final INoteStorage noteStorageLocation;
  final ISentimentAnalyzer noteAnalyzer;
  final String noteUUID;
  NoteMakerScreen(this.noteStorageLocation, this.noteAnalyzer,
      {Key key, this.title, this.noteUUID})
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
  _NoteMakerState() {
    prepareNote();
  }

  void prepareNote() async {
    if (this.widget.noteUUID == null) {
      print("Creating a new note");
      this.noteOut = Note(Uuid().v4());
    } else {
      print("Editing an old note");
      this.noteOut =
          await this.widget.noteStorageLocation.getNote(this.widget.noteUUID);
      _image = this.noteOut.getImage();
    }
  }

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

  Future<void> submitNote() async {
    this._noteMakerKey.currentState.save();
    noteOut.setDate(_date);
    print("submitNote $_image");
    Directory files_directory = await getApplicationDocumentsDirectory();
    String filename = _image.path.split('/').last;
    File safeSpace = File(files_directory.path + '/' + filename);
    if (!safeSpace.existsSync()) {
      _image.copy(safeSpace.path);
    }
    noteOut.setImage(safeSpace);
    noteOut.setScore(this.widget.noteAnalyzer.analyzeText(noteOut.getBody()));

    this.widget.noteStorageLocation.putNote(noteOut);
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
                          initialValue: noteOut.getTitle(),
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
                          initialValue: noteOut.getBody(),
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
                          onPressed: () async {
                            if (_image != null) {
                              await submitNote();
                              Navigator.pop(context, noteOut);
                            }
                          },
                          child: Text("Save")))
                ],
              ),
            )));
  }
}
