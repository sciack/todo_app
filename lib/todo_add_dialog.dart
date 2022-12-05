import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/todo_model.dart';

class TodoDialog extends StatefulWidget {
  TodoDialog({super.key, this.todo});

  Todo? todo;

  @override
  TodoDialogState createState() => TodoDialogState();
}

class TodoDialogState extends State<TodoDialog> {
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _dateFieldController = TextEditingController();
  DateTime date = DateTime.now();

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
  void initState() {
    super.initState();
    var todo = widget.todo;
    date = todo?.date ?? DateTime.now();
    _dateFieldController.text = formatDate(date);
    _textFieldController.text = todo?.name ?? "";
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const ValueKey('Todo-Text'),
            controller: _textFieldController,
            decoration: InputDecoration(
                labelText: 'Todo',
                errorText: _errorText),
            onChanged: (_) => setState(() {}),
          ),
          TextField(
              key: const ValueKey('Todo-Date'),
              controller: _dateFieldController,
              decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.calendar_today), //icon of text field
                  labelText: "Enter Date" //label text of field
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    //get today's date
                    firstDate: DateTime(2020),
                    //DateTime.now() - not to allow to choose before today.
                    lastDate: DateTime(2030)
                );
                if (pickedDate != null) {
                  _dateFieldController.text = formatDate(pickedDate);
                  setState(() {
                    date = pickedDate;
                  });
                }
              })
        ],
      ),
      actions: <Widget>[
        TextButton(
            child: const Text('Add'),
            onPressed: () {
              if (_textFieldController.text.isEmpty) {
                return;
              }
              Navigator.of(context).pop();
              var todo = widget.todo;
              if (todo == null) {
                _addTodoItem(context, _textFieldController.text,
                    date);
              } else {
               _setTodoItem(context, todo, _textFieldController.text, date);
              }
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

  void _addTodoItem(BuildContext context, String name, DateTime date) {
    Provider.of<TodoModel>(context, listen: false).add(name, date);
    _textFieldController.clear();
  }

  void _setTodoItem(BuildContext context, Todo todo, String name, DateTime date) {
   var newTodo = Todo(id: todo.id,
        name: name,
        checked: todo.checked,
        date: date);
    Provider.of<TodoModel>(context, listen: false).set(newTodo);
  }
}


