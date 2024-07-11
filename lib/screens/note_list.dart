import 'dart:async';
import 'package:flutter/material.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/utils/database_helper.dart';
import 'package:note_app/screens/note_details.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  const NoteList({super.key}); //

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Note>? _noteList;
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    if (_noteList == null) {
      _noteList = <Note>[];
      _updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: _getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToDetail(Note('', '', 2), 'Add Note');
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }

  ListView _getNoteListView() {
    final TextStyle titleStyle = const TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
    );

    return ListView.builder(
      itemCount: _count,
      itemBuilder: (BuildContext context, int position) {
        final Note note = _noteList![position];
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getPriorityColor(note.priority),
              child: _getPriorityIcon(note.priority),
            ),
            title: Text(note.title, style: titleStyle),
            subtitle: Text(note.date),
            trailing: GestureDetector(
              child: const Icon(Icons.delete, color: Colors.grey),
              onTap: () => _delete(context, note),
            ),
            onTap: () {
              _navigateToDetail(note, 'Edit Note');
            },
          ),
        );
      },
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
      default:
        return Colors.yellow;
    }
  }

  Icon _getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return const Icon(Icons.note_alt);
      case 2:
      default:
        return const Icon(Icons.note_alt);
    }
  }

  Future<void> _delete(BuildContext context, Note note) async {
    int result = await _databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      _updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _navigateToDetail(Note note, String title) async {
    bool? result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetails(note: note, appBarTitle: title); // NoteDetails
    }));

    if (result == true) {
      _updateListView();
    }
  }

  void _updateListView() {
    final Future<Database> dbFuture = _databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = _databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          _noteList = noteList;
          _count = noteList.length;
        });
      });
    });
  }
}
