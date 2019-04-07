import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';

class DatabaseHelper {

  static DatabaseHelper _databaseHelper;  // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance(); //Named constructor, creates the instance of DatabaseHelper

  factory DatabaseHelper(){

    if(_databaseHelper == null){
      _databaseHelper = DatabaseHelper._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null){
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both android and ios so we can store the database
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';


    //Open/create the database at the path
    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {

    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }


  //Fetch operation: get all notes
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  //Insert operation: Insert a note to the database
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result =  await db.insert(noteTable, note.toMap());
    return result;
  }


  //Update operation: Update a note that exists in the db already
  Future<int> updateNote(Note note) async {
    var db = await this.database;
    var result =  await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  //Delete operation: Delete a note from the database
  Future<int> deleteNote(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  //Get number of notes
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //get map list and convert to note list
  Future<List<Note>> getNoteList() async {

    var noteMapList = await getNoteMapList(); //Gets list of maps from database
    int count = noteMapList.length; // Count the number of map entries in the db tables

    List<Note> noteList = List<Note>();
    //Loop over Map list and convert to notes.
    for (int i =0; i < count; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }

}