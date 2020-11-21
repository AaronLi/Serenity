import 'dart:io';

abstract class INote {
  String getTitle();
  DateTime getDate();
  String getBody();
  File getImage();
  String getUUID();
  double getScore();
  void setTitle(String newTitle);
  void setDate(DateTime newDate);
  void setBody(String newBody);
  void setImage(File newImage);
  INote.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}