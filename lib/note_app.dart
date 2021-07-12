import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_note_app/categoryPage.dart';
import 'package:flutter_note_app/models/category.dart';
import 'package:flutter_note_app/note_detail.dart';
import 'package:flutter_note_app/utils/database_helper.dart';

import 'models/note.dart';

class NoteApp extends StatefulWidget {
  @override
  _NoteAppState createState() => _NoteAppState();
}

class _NoteAppState extends State<NoteApp> {
  DatabaseHelper db;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    db = DatabaseHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "Add Note",
        tooltip: "Add Note",
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NoteDetail(
                        title: "Add note",
                      ))).then(onGoBack);
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        actions: [
          PopupMenuButton(onSelected: (value) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => CategoryPage()))
                .then((onGoBack));
          }, itemBuilder: (context) {
            return [PopupMenuItem(value: 1, child: Text("Categories"))];
          }),
        ],
        title: Text("Note List"),
      ),
      body: NoteListWidget(),
    );
  }

  onGoBack(dynamic value) {
    setState(() {});
  }
}

class NoteListWidget extends StatefulWidget {
  @override
  _NoteListWidgetState createState() => _NoteListWidgetState();
}

class _NoteListWidgetState extends State<NoteListWidget> {
  DatabaseHelper db;
  TextEditingController _noteTextController = TextEditingController();
  int updateNoteId;
  List<Category> allCategories;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    db = DatabaseHelper();
    allCategories = [];
    db.bringCategories().then((kategoriIcerenMapListesi) {
      for (Map okunanMap in kategoriIcerenMapListesi) {
        allCategories.add(Category.fromMap(okunanMap));
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<Note>>(
          future: db.bringNotes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return ExpansionTile(
                      leading: noteLeading(snapshot, index),
                      title: Text(
                        snapshot.data[index].noteName,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey),
                      ),
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Category",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  Text(snapshot.data[index].categoryName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.orange)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Date Created",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  Text(
                                    db.dateFormat(DateTime.parse(
                                        snapshot.data[index].noteDate)),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.orange),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: Text(
                                "Content",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                snapshot.data[index].noteContent,
                                style: TextStyle(
                                    fontSize: 20, color: Colors.grey.shade700),
                              ),
                            ),
                            ButtonBar(
                              children: [
                                OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.red),
                                        primary: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        db
                                            .deleteNote(
                                                snapshot.data[index].noteId)
                                            .then((value) {
                                          if (value > 0) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        "Note has been deleted!")));
                                          }
                                        });
                                      });
                                    },
                                    child: Text("DELETE")),
                                OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.blue),
                                        primary: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => NoteDetail(
                                                    title: "Update Note",
                                                    note: snapshot.data[index],
                                                  ))).then(onGoBack);
                                    },
                                    child: Text("UPDATE")),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  });
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  onGoBack(dynamic value) {
    setState(() {});
  }

  CircleAvatar noteLeading(AsyncSnapshot<List<Note>> snapshot, int index) {
    return snapshot.data[index].notePriority == 1
        ? CircleAvatar(backgroundColor: Colors.green)
        : snapshot.data[index].notePriority == 2
            ? CircleAvatar(backgroundColor: Colors.blue)
            : CircleAvatar(
                backgroundColor: Colors.red,
              );
  }
}
