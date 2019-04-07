import 'package:flutter/material.dart';
import 'dart:async';
import '../models/note.dart';
import '../ultils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget{

  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState(){

    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail>{

  static var _priorities = [ 'High', 'Low'];

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context){

    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(

      onWillPop: () {
        //put something here to control what happens when user pressed back in on device bottom bar
        moveToLastScreen();
      },

      child: Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(icon: Icon(
            Icons.arrow_back),
            onPressed: () {
          //put something here to control what happens when user pressed back in AppBar
              moveToLastScreen();
            }
        )
      ),

      body: Padding(
        padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[

            //First element
            ListTile(
              title: DropdownButton(
                items: _priorities.map((String dropDownStringItem) {
                  return DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: Text(dropDownStringItem),
                  );
                }).toList(),

                style: textStyle,

                value: getPriorityAsString(note.priority),

                onChanged: (valueSelectedByUser){
                  setState(() {
                    debugPrint('User selected $valueSelectedByUser');
                    updatePriorityAsInt(valueSelectedByUser);
                  });
                },
                ),
              ),

              //Second element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: titleController,
                style: textStyle,
                onChanged: (value) {
                  debugPrint('Someting changed in the title text field');
                  updateTitle();
                },
                decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),

              ),
            ),

            //Third element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: descriptionController,
                style: textStyle,
                onChanged: (value) {
                  debugPrint('Someting changed in the description text field');
                  updateDescription();
                },
                decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0)
                    )
                ),

              ),
            ),

            //Fourth element
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).primaryColorDark,
                      textColor: Theme.of(context).primaryColorLight,
                      child: Text(
                        'Save',
                        textScaleFactor: 1.5,
                      ),
                      onPressed: (){
                        setState(() {
                          debugPrint("Save button clicked");
                          _save();
                        });
                      }


                    )
                  ),

                  Container(width: 5.0,),

                  Expanded(
                      child: RaisedButton(
                          color: Theme.of(context).primaryColorDark,
                          textColor: Theme.of(context).primaryColorLight,
                          child: Text(
                            'Delete',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: (){
                            setState(() {
                              debugPrint("Delete button clicked");
                              _delete();
                            });
                          }


                      )
                  ),
                ]
              ),
            ),

            ]),




      ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  //Convert the String priority to int for saving in database
  void updatePriorityAsInt(String value){
    switch (value){
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }

  //Convert int into priority string for display
  String getPriorityAsString(int value){
      String priority;
      switch (value){
        case 1:
          priority = _priorities[0]; //'High'
          break;
        case 2:
          priority = _priorities[1]; //'Low'
          break;
      }
      return priority;
  }

  // Update title of note object
  void updateTitle(){
    note.title = titleController.text;
  }

  //Update the description of Note object
  void updateDescription(){
    note.description = descriptionController.text;
  }

  //Save note to database
  void _save() async {

    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null){ //Update operation
      result = await helper.updateNote(note);
    } else { //Insert operation
      result = await helper.insertNote(note);
    }

    if (result != 0){ // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else { //Operation failed
      _showAlertDialog('Status', 'Error, note not saved');
    }
  }

  // delete note from database
  void _delete() async {

    moveToLastScreen();

    //Case 1 - delete on new note
    if (note.id == null){
      _showAlertDialog('Status', 'No note to delete!');
      return;
    }

    //Case 2 - delete on note that already exists in database
    int result = await helper.deleteNote(note.id);

    if (result != 0){
      _showAlertDialog('Status', 'Note deleted successfully');
    } else {
      _showAlertDialog('Status', 'Error occurred while deleting note');
    }
  }

  void _showAlertDialog(String title, String message){

    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog
    );
  }

}