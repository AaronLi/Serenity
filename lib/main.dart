import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:serenity/note_storage/demo_local_file_note_storage.dart';
import 'package:serenity/pages/calendar_view.dart';
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
          ElevatedButton(
              onPressed: () => {openEditor(uuid: note.getUUID())},
              child: Row(children: [
                Text(note.getTitle()),
                Text(note.getScore().toStringAsPrecision(2)),
              ], mainAxisAlignment: MainAxisAlignment.spaceAround))
        ]));
  }

  Future<void> openEditor({uuid}) async {
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

  Widget makeNavDrawer() {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          child: Column(children: [
            Text(
              "Serenity",
              textAlign: TextAlign.center,
              style: GoogleFonts.sacramento(textStyle: TextStyle(fontSize: 60)),
            ),
            Image.asset(
              "assets/cat.png",
              height: 49,
            )
          ]),
          decoration: BoxDecoration(color: Colors.orange[200]),
        ),
        ElevatedButton.icon(
            onPressed: null,
            icon: Icon(Icons.calendar_view_day),
            label: Text("Daily view")),
        ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return CalendarHome(title: "Your Month");
              }));
            },
            icon: Icon(Icons.calendar_today),
            label: Text("Monthly view"))
      ],
    ));
  }

  Widget makeDateMarker(DateTime time) {
    return Padding(
        padding: EdgeInsets.only(left: 10, top: 15, right: 10),
        child: Column(children: [
          Text(
            DateFormat(DateFormat.MONTH_DAY).format(time),
            style:
                GoogleFonts.josefinSans(textStyle: TextStyle(fontSize: 40.0)),
          ),
          Divider(thickness: 4)
        ]));
  }

  @override
  Widget build(BuildContext context) {
    var readDatabase =
        DemoLocalFileNoteStorage().getNotes(DateTime(0), DateTime.now());
    return Scaffold(
      appBar: AppBar(title: Text(this.title)),
      drawer: makeNavDrawer(),
      body: FutureBuilder(
          future: readDatabase,
          builder: (context, AsyncSnapshot<List<INote>> snapshot) {
            if (snapshot.hasData) {
              List<Widget> entries = [];
              snapshot.data.sort();
              INote oldNote;
              for (INote note in snapshot.data) {
                if (oldNote == null ||
                    note.getDate().month != oldNote.getDate().month) {
                  entries.add(makeDateMarker(note.getDate()));
                  oldNote = note;
                }
                entries.add(drawINote(note));
              }
              return ListView(
                children: entries,
              );
            } else if (snapshot.hasError) {
              return Text("Error reading database");
            } else {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [CircularProgressIndicator()])
                  ]);
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
