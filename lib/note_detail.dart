import 'package:flutter/material.dart';
import 'package:flutter_note_app/models/category.dart';
import 'package:flutter_note_app/models/note.dart';
import 'package:flutter_note_app/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteDetail extends StatefulWidget {
  String title;
  Note note;

  NoteDetail({this.title, this.note});

  @override
  _NoteDetailState createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  int categoryValue ;
  double _rating = 1;
  String noteTitle;
  String noteContent;
  List<Category> allCategories;

  DatabaseHelper dbHelper;
  var formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allCategories = [];

    dbHelper = DatabaseHelper();
    dbHelper.bringCategories().then((kategoriIcerenMapListesi) {
      for (Map okunanMap in kategoriIcerenMapListesi) {
        allCategories.add(Category.fromMap(okunanMap));
      }
      setState(() {});
    });
    if (widget.note != null) {
      categoryValue = widget.note.categoryId;
      _rating = widget.note.notePriority.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Category"),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    width: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        shape: BoxShape.rectangle,
                        border: Border.all(
                          color: Colors.blue,
                          width: 2,
                        )),
                    child: DropdownButton(
                      underline: Container(),
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          categoryValue = value;
                        });
                      },
                      value: categoryValue,
                      items: createCategoryItems(),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: widget.note != null ? widget.note.noteName : "",
                  onSaved: (value) {
                    noteTitle = value;
                  },
                  decoration: InputDecoration(
                      labelText: "Note Title",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      )),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue:
                      widget.note != null ? widget.note.noteContent : "",
                  onSaved: (value) {
                    noteContent = value;
                  },
                  maxLines: 4,
                  decoration: InputDecoration(
                      labelText: "Note Content",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      )),
                ),
              ),
              Text("Priority"),
              Slider(
                min: 1,
                max: 3,
                value: _rating,
                onChanged: (newRating) {
                  setState(() {
                    _rating = newRating;
                  });
                },
                divisions: 2,
                label: _rating == 1
                    ? "Low"
                    : _rating == 2
                        ? "Medium"
                        : "High",
              ),
              ButtonBar(
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.grey),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel")),
                  ElevatedButton(
                      onPressed: () {
                        DateTime now = DateTime.now();
                        formKey.currentState.save();

                        if (widget.note == null) {
                          dbHelper
                              .addNote(Note(categoryValue, noteTitle,
                                  noteContent, now.toString(), _rating.toInt()))
                              .then((value) {
                            if (value > 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      duration: Duration(seconds: 3),
                                      content: Text("Note has been added!")));
                              Navigator.pop(context);
                            }
                          });
                        } else {
                          dbHelper
                              .updateNote(Note.withId(
                                  widget.note.noteId,
                                  categoryValue,
                                  noteTitle,
                                  noteContent,
                                  now.toString(),
                                  _rating.toInt()))
                              .then((value) {
                            if (value > 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Note has been updated!")));
                            }
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Text(widget.note == null ? "Add" : "Update")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  createCategoryItems() {
    List<DropdownMenuItem<int>> categoryItems = [];
    //  print(allCategories.length.toString());
    for (Category category in allCategories) {
      categoryItems.add(DropdownMenuItem(
          value: category.categoryId, child: Text(category.categoryName)));
    }
    return categoryItems;
  }
}
