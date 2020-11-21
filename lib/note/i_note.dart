import 'dart:io';

abstract class INote implements Comparable {
  String getTitle();
  DateTime getDate();
  String getBody();
  File getImage();
  String getUUID();
  double getScore();
  bool shouldAnalyze();
  void setTitle(String newTitle);
  void setDate(DateTime newDate);
  void setBody(String newBody);
  void setImage(File newImage);
  void setAnalyze(bool shouldAnalyze);
  INote.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
