import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:serenity/note/i_note.dart';
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
  State<StatefulWidget> createState() =>
      _NoteMakerState(noteStorageLocation, noteAnalyzer, uuid: this.noteUUID);
}

class _NoteMakerState extends State<NoteMakerScreen> {
  final _noteMakerKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat(DateFormat.YEAR_MONTH_DAY);
  File _image;
  final _picker = ImagePicker();
  final _date = DateTime.now();
  final INoteStorage storage;
  final ISentimentAnalyzer analyzer;
  Note noteOut;
  Future<INote> noteLoader;

  _NoteMakerState(this.storage, this.analyzer, {String uuid}) {
    print("Created noteloader");
    this.noteLoader = prepareNote(uuid);
  }

  Future<INote> prepareNote(String uuid) async {
    if (uuid == null) {
      print("Creating a new note");
      return Note(Uuid().v4());
    } else {
      print("Loading an existing note");
      return await this.storage.getNote(uuid);
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
    //save form values into their objects
    this._noteMakerKey.currentState.save();

    // set date
    noteOut.setDate(_date);

    // copy image to storage
    Directory filesDirectory = await getApplicationDocumentsDirectory();
    String filename = _image.path.split('/').last;
    File safeSpace = File(filesDirectory.path + '/' + filename);
    if (!safeSpace.existsSync()) {
      _image.copy(safeSpace.path);
    }
    noteOut.setImage(safeSpace);
    // score text
    if (noteOut.shouldAnalyze()) {
      noteOut.setScore(this.widget.noteAnalyzer.analyzeText(noteOut.getBody()));
    }
    // store in database
    this.widget.noteStorageLocation.putNote(noteOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: noteOut == null
              ? []
              : [
                  Row(children: [
                    Text("Silence"),
                    Checkbox(
                        value: noteOut.shouldAnalyze(),
                        onChanged: (state) {
                          setState(() {
                            noteOut.setAnalyze(state);
                          });
                          return noteOut.shouldAnalyze();
                        })
                  ])
                ],
        ),
        body: FutureBuilder(
            future: this.noteLoader,
            builder: (context, AsyncSnapshot<INote> snapshot) {
              if (snapshot.hasData) {
                if (noteOut == null) {
                  noteOut = snapshot.data;
                  _image = snapshot.data.getImage();
                  //_date = snapshot.data.getDate(); // uncomment for edited entries to remain in their original positions
                }
                return Form(
                    key: _noteMakerKey,
                    child: Scaffold(
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
                                  initialValue: snapshot.data.getTitle(),
                                  onSaved: (newValue) =>
                                      noteOut.setTitle(newValue),
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
                                  initialValue: snapshot.data.getBody(),
                                  onSaved: (newValue) =>
                                      noteOut.setBody(newValue),
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  decoration: const InputDecoration(
                                      hintText: "Write about your day"),
                                )
                              ])),
                          Padding(
                              padding:
                                  EdgeInsets.only(left: 15, right: 15, top: 10),
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
                    ));
              } else if (snapshot.hasError) {
                return Text("Error");
              } else {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [CircularProgressIndicator()])
                    ]);
              }
            }));
  }
}
