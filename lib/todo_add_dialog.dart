import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/todo_model.dart';

class TodoDialog extends StatefulWidget {
  const TodoDialog({super.key});

  @override
  TodoDialogState createState() => TodoDialogState();
}

class TodoDialogState extends State<TodoDialog> {
  final TextEditingController _textFieldController = TextEditingController();

  TodoDialogState();

  String? get _errorText {
    final text = _textFieldController.text;
    // Note: you can do your own custom validation here
    // Move this logic this outside the widget for more testable code
    if (text.isEmpty) {
      return "Can't be empty";
    }

    return null;
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a new todo item'),
      content: TextField(
        key: const ValueKey('Todo-Text'),
        controller: _textFieldController,
        decoration: InputDecoration(
            hintText: 'Type your new todo', errorText: _errorText),
        onChanged: (_) => setState(() {}),
      ),
      actions: <Widget>[
        TextButton(
            child: const Text('Add'),
            onPressed: () {
              if (_textFieldController.text.isEmpty) {
                return;
              }
              Navigator.of(context).pop();
              _addTodoItem(context, _textFieldController.text);
            }),
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  void _addTodoItem(BuildContext context, String name) {
    Provider.of<TodoModel>(context, listen: false).add(name);
    _textFieldController.clear();
  }
}
