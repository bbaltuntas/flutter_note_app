import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_note_app/models/category.dart';
import 'package:flutter_note_app/models/note.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper.internal();
      return _databaseHelper;
    } else {
      return _databaseHelper;
    }
  }

  DatabaseHelper.internal();

  Future<Database> _getDatabase() async {
    if (_database == null) {
      _database = await initializeDatabase();
      return _database;
    } else {
      return _database;
    }
  }

  initializeDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "appDB.db");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "notes.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
// open the database
    return await openDatabase(path, readOnly: false);
  }

  Future<List<Map<String, dynamic>>> bringCategories() async {
    var db = await _getDatabase();
    var result = await db.query("category");
    return result;
  }

  Future<List<Category>> bringCategoryList() async {
    List<Category> list = [];
    var result = await bringCategories();
    for (Map map in result) {
      list.add(Category.fromMap(map));
    }
    return list;
  }

  Future<int> addCategory(Category category) async {
    var db = await _getDatabase();
    var result = await db.insert("category", category.toMap());
    return result;
  }

  Future<int> updateCategory(Category category) async {
    var db = await _getDatabase();
    var result = await db.update("category", category.toMap(),
        where: "categoryId = ?", whereArgs: [category.categoryId]);
    return result;
  }

  Future<int> deleteCategory(int categoryId) async {
    var db = await _getDatabase();
    var result =
        db.delete("category", where: "categoryId = ?", whereArgs: [categoryId]);
    return result;
  }

  Future<List<Note>> bringNotes() async {
    var db = await _getDatabase();
    var result = await db.rawQuery(
        "SELECT * from note INNER JOIN category WHERE note.categoryId == category.categoryId order by noteId DESC");

    List<Note> noteList = [];
    for (Map map in result) {
      noteList.add(Note.fromMap(map));
    }
    return noteList;
  }

  Future<int> addNote(Note note) async {
    var db = await _getDatabase();
    var result = await db.insert("note", note.toMap());
    return result;
  }

  Future<int> updateNote(Note note) async {
    var db = await _getDatabase();
    var result = await db.update("note", note.toMap(),
        where: "noteId = ?", whereArgs: [note.noteId]);
    return result;
  }

  Future<int> deleteNote(int noteId) async {
    var db = await _getDatabase();
    var result = db.delete("note", where: "noteId = ?", whereArgs: [noteId]);
    return result;
  }

  String dateFormat(DateTime tm) {
    DateTime today = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration twoDay = new Duration(days: 2);
    Duration oneWeek = new Duration(days: 7);
    String month;
    switch (tm.month) {
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
    }

    Duration difference = today.difference(tm);

    if (difference.compareTo(oneDay) < 1) {
      return "Today";
    } else if (difference.compareTo(twoDay) < 1) {
      return "Yesterday";
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (tm.weekday) {
        case 1:
          return "Monday";
        case 2:
          return "Tuesday";
        case 3:
          return "Wednesday";
        case 4:
          return "Thursday";
        case 5:
          return "Friday";
        case 6:
          return "Saturday";
        case 7:
          return "Sunday";
      }
    } else if (tm.year == today.year) {
      return '${tm.day} $month';
    } else {
      return '${tm.day} $month ${tm.year}';
    }
    return "";
  }
}
