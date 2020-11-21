import 'package:flutter/material.dart';
import 'package:serenity/note_storage/demo_local_file_note_storage.dart';
import 'package:serenity/sentiment_analysis/demo_naive_sentiment_analyzer.dart';
import './pages/add_note.dart';
import 'note/i_note.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serenity',
      theme: ThemeData(
        primaryColor: Colors.orange[200],
        accentColor: Colors.orange[200],
        canvasColor: Colors.yellow[50],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: JournalHomePage(title: 'Notes'),
    );
  }
}

class JournalHomePage extends StatefulWidget {
  final String title;
  JournalHomePage({this.title});

  @override
  State<JournalHomePage> createState() {
    return _JournalHomepageState(title);
  }
}

class _JournalHomepageState extends State<JournalHomePage> {
  final String title;
  _JournalHomepageState(this.title);

  Widget drawINote(INote note) {
    return Padding(
        padding: EdgeInsets.all(15),
        child: Column(children: [
          Center(
              child: AspectRatio(
                  aspectRatio: 500 / 70,
                  child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.fitWidth,
                              image: FileImage(note.getImage())))))),
          ElevatedButton(onPressed: () => {}, child: Text(note.getTitle()))
        ]));
  }

  void openEditor({uuid}) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NoteMakerScreen(
                  DemoLocalFileNoteStorage(),
                  DemoNaiiveSentimentAnalyzer(),
                  title: "New Journal Entry",
                  noteUUID: uuid,
                )));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var readDatabase =
        DemoLocalFileNoteStorage().getNotes(DateTime(0), DateTime.now());
    return Scaffold(
      appBar: AppBar(title: Text(this.title)),
      body: FutureBuilder(
          future: readDatabase,
          builder: (context, AsyncSnapshot<List<INote>> snapshot) {
            if (snapshot.hasData) {
              List<Widget> entries = [];
              for (INote note in snapshot.data) {
                entries.add(drawINote(note));
              }
              return ListView(
                children: entries,
              );
            } else if (snapshot.hasError) {
              return Text("Error reading database");
            } else {
              return Text("Working...");
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await openEditor();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
