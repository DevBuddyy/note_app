import 'package:flutter/material.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetails extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  const NoteDetails({required this.note, required this.appBarTitle});

  @override
  _NoteDetailsState createState() => _NoteDetailsState();
}

class _NoteDetailsState extends State<NoteDetails> {
  static const List<String> _priorities = ['High', 'Low'];

  final DatabaseHelper _helper = DatabaseHelper();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late String _appBarTitle;
  late Note _note;

  late TextStyle _textStyle; // Custom text style

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _appBarTitle = widget.appBarTitle;
    _titleController.text = _note.title;
    _descriptionController.text = _note.description;

    _textStyle = TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      // More properties as needed
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _moveToLastScreen();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_appBarTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _moveToLastScreen,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: <Widget>[
              _buildPriorityDropdown(),
              _buildTitleTextField(),
              _buildDescriptionTextField(),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return ListTile(
      title: DropdownButton<String>(
        items: _priorities.map((String priority) {
          return DropdownMenuItem<String>(
            value: priority,
            child: Text(priority, style: _textStyle),
          );
        }).toList(),
        value: _getPriorityAsString(_note.priority),
        onChanged: (value) {
          setState(() {
            _updatePriorityAsInt(value!);
          });
        },
      ),
    );
  }

  Widget _buildTitleTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: TextField(
        controller: _titleController,
        style: _textStyle,
        onChanged: (value) {
          _updateTitle();
        },
        decoration: InputDecoration(
          labelText: 'Title',
          labelStyle: _textStyle,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: TextField(
        controller: _descriptionController,
        style: _textStyle,
        onChanged: (value) {
          _updateDescription();
        },
        decoration: InputDecoration(
          labelText: 'Description',
          labelStyle: _textStyle,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              child: const Text('Save', style: TextStyle(fontSize: 18.0)),
              onPressed: () {
                setState(() {
                  _save();
                });
              },
            ),
          ),
          const SizedBox(width: 5.0),
          Expanded(
            child: ElevatedButton(
              child: const Text('Delete', style: TextStyle(fontSize: 18.0)),
              onPressed: () {
                setState(() {
                  _delete();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _moveToLastScreen() {
    Navigator.pop(context, true); // Pass true to indicate success
  }

  void _updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        _note.priority = 1;
        break;
      case 'Low':
        _note.priority = 2;
        break;
    }
  }

  String _getPriorityAsString(int priority) {
    return priority == 1 ? _priorities[0] : _priorities[1];
  }

  void _updateTitle() {
    _note.title = _titleController.text;
  }

  void _updateDescription() {
    _note.description = _descriptionController.text;
  }

  void _save() async {
    _note.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if (_note.id != null && _note.id != 0) {
      result = await _helper.updateNote(_note);
    } else {
      result = await _helper.insertNote(_note);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Note Saved Successfully');
      _moveToLastScreen(); // Navigate back to note list
    } else {
      _showAlertDialog('Status', 'Problem Saving Note');
    }
  }

  void _delete() async {
    // Cancel
    setState(() {
      _appBarTitle = 'Cancel';
    });

    // Navigate back to note list
    _moveToLastScreen();
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
      ),
    );
  }
}
