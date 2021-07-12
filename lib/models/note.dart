class Note {
  int noteId;
  int categoryId;
  String noteName;
  String noteContent;
  String noteDate;
  int notePriority;
  String categoryName;

  Note(this.categoryId, this.noteName, this.noteContent, this.noteDate,
      this.notePriority);

  Note.withId(this.noteId, this.categoryId, this.noteName, this.noteContent,
      this.noteDate, this.notePriority);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['noteId'] = this.noteId;
    map['categoryId'] = this.categoryId;
    map['noteName'] = this.noteName;
    map['noteContent'] = this.noteContent;
    map['noteDate'] = this.noteDate;
    map['notePriority'] = this.notePriority;
    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    this.noteId = map['noteId'];
    this.categoryId = map['categoryId'];
    this.categoryName = map['categoryName'];
    this.noteName = map['noteName'];
    this.noteContent = map['noteContent'];
    this.noteDate = map['noteDate'];
    this.notePriority = map['notePriority'];
  }
}
