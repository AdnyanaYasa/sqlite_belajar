import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttersqlite/data/data.dart';
import 'package:fluttersqlite/db_helper/db_helder.dart';
import 'package:fluttersqlite/layar/detail_data.dart';
import 'package:fluttersqlite/pengembang/penulis.dart';
import 'package:sqflite/sqflite.dart';

GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
class NoteList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {

    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {

    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        centerTitle: true,

        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              _scaffoldState.currentContext,
              MaterialPageRoute(builder: (BuildContext context) {
                return penulis();
              }),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Icon(
                Icons.account_box,
                color: Colors.orange,

              ),
            )
          ),
        ),

        title: Text('Catatan Hutang'),
        actions: <Widget>[
          Icon(Icons.star),
          Padding(padding: EdgeInsets.only(right: 15))
        ],
      ),

      body: getNoteListView(),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetail(Note('', '', 2), 'Tambah Catatan');
        },

        tooltip: 'Add Note',

        child: Icon(Icons.add),

      ),
    );
  }

  ListView getNoteListView() {

    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.blueGrey,
          elevation: 2.0,
          margin: EdgeInsets.all(15),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.noteList[position].priority),
              child: getPriorityIcon(this.noteList[position].priority),
            ),
            title: Text(this.noteList[position].title, style: titleStyle,),
            subtitle: Text(this.noteList[position].date +" | "+ "Rp. " +this.noteList[position].description,),

            trailing: GestureDetector(
              child: Icon(Icons.delete_forever, color: Colors.red,size: 35,),
              onTap: () {
                _delete(context, noteList[position]);
              },
            ),


            onTap: () {
              debugPrint("Catatan Disadap");
              navigateToDetail(this.noteList[position],'Edit Catatan');
            },

          ),
        );
      },
    );
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.blue;
        break;

      default:
        return Colors.blue;
    }
  }

  // Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.timer_off);
        break;
      case 2:
        return Icon(Icons.timer);
        break;

      default:
        return Icon(Icons.timer);
    }
  }

  void _delete(BuildContext context, Note note) async {

    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Catatan Berhasil Dihapus');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {

    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {

    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {

      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}







