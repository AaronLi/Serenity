import 'dart:io';

import 'package:serenity/note/i_note.dart';

class Note implements INote {
  String _body = "";
  DateTime _date = DateTime(0);
  File _image;
  double _score = 0;
  String _title = "";
  String _uuid = "";
  Note(this._uuid);

  @override
  String getBody() {
    return this._body;
  }

  @override
  DateTime getDate() {
    return this._date;
  }

  @override
  File getImage() {
    return this._image;
  }

  @override
  double getScore() {
    return this._score;
  }

  @override
  String getTitle() {
    return this._title;
  }

  @override
  String getUUID() {
    return this._uuid;
  }

  @override
  void setBody(String newBody) {
    this._body = newBody;
  }

  @override
  void setDate(DateTime newDate) {
    this._date = newDate;
  }

  @override
  void setImage(File newImage) {
    this._image = newImage;
  }

  @override
  void setTitle(String newTitle) {
    this._title = newTitle;
  }

  void setScore(double score) {
    this._score = score;
  }

  @override
  Map<String, dynamic> toJson() => {
        'body': this._body,
        'date': this._date.millisecondsSinceEpoch,
        'score': this._score,
        'title': this._title,
        'uuid': this._uuid,
        'image_path': this._image.path
      };
  @override
  Note.fromJson(Map<String, dynamic> json) {
    this._body = json['body'];
    this._date = DateTime.fromMillisecondsSinceEpoch(json['date']);
    this._score = json['score'];
    this._title = json['title'];
    this._uuid = json['uuid'];
    this._image = File(json['image_path']);
  }
}
