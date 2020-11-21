import 'package:serenity/note/i_note.dart';
import 'package:serenity/note/note.dart';
import 'dart:io';
import 'i_note_storage.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class DemoLocalFileNoteStorage implements INoteStorage {
  static Map<String, INote> localDatabase;

  Future<String> get _localpath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _filepath async {
    final path = await _localpath;
    final fileHandle = File('$path/notes.json');
    if (!await fileHandle.exists()) {
      await fileHandle.create().then((value) => value.writeAsString("\{\}"));
    }
    return fileHandle;
  }

  Future<Map<String, INote>> get _readDatabase async {
    print("Database ${localDatabase.toString()}");
    if (localDatabase == null) {
      // if we haven't intialized the local database
      File loadFile = await _filepath;
      Map<String, dynamic> values = jsonDecode(await loadFile.readAsString());
      Map<String, INote> outDb = Map();
      for (String note_uuid in values.keys) {
        outDb[note_uuid] = Note.fromJson(values[note_uuid]);
      }
      localDatabase = outDb;
      return outDb;
    } else {
      // we have initialized it, just return the loaded version from memory
      return localDatabase;
    }
  }

  @override
  Future<INote> getNote(String uuid) async {
    return (await _readDatabase)[uuid];
  }

  @override
  Future<List<String>> getNotes(DateTime from, DateTime to) async {
    List<String> out = [];
    for (INote note in (await _readDatabase).values) {
      if (note.getDate().isAfter(from) && note.getDate().isBefore(to)) {
        out.add(note.getUUID());
      }
    }
    return out;
  }

  @override
  Future<String> getTitle(String uuid) async {
    return (await _readDatabase)[uuid].getTitle();
  }

  @override
  void putNote(INote newNote) async {
    var db = await _readDatabase;
    db[newNote.getUUID()] = newNote;
    Map<String, dynamic> encodableNotes = Map();
    for (Note note in db.values) {
      encodableNotes[note.getUUID()] = note.toJson();
    }
    (await _filepath).writeAsString(jsonEncode(encodableNotes));
    //_local_database = null; // purge the local copy since the file has been updated
  }

  @override
  Future<int> numNotes() async {
    var db = await _readDatabase;
    return db.keys.length;
  }
}
