import '../note/i_note.dart';

abstract class INoteStorage {
  Future<List<String>> getNotes(DateTime from, DateTime to);
  Future<INote> getNote(String uuid);
  Future<String> getTitle(String uuid);
  Future<int> numNotes();
  void putNote(INote newNote);
}
