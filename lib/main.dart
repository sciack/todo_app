import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/todo_add_dialog.dart';
import 'package:todo_app/todo_model.dart';

void main() {
  runApp(TodoApp(todoRepo: TodoRepository.INSTANCE));
}

class TodoApp extends StatelessWidget {
  final TodoRepository todoRepo;
  const TodoApp({super.key, required this.todoRepo});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => TodoModel(todoRepo),
        child: const MaterialApp(
          title: "Todo list",
          home: TodoList(),
        ));
  }
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    var model = context.watch<TodoModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo list'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: model.todos.map((Todo todo) {
          return TodoItem(
            todo: todo,
            onTodoChanged: _toggleTodoChecked,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () => _displayDialog(context),
          tooltip: 'Add Item',
          child: const Icon(Icons.add)),
    );
  }

  Future<void> _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const TodoDialog(key: ValueKey("Todo-Dialog"));
        });
  }

  void _toggleTodoChecked(Todo todo) {

  }
}

typedef TodoChangeFunction = void Function(Todo todo);

class TodoItem extends StatelessWidget {
  const TodoItem({super.key, required this.todo, required this.onTodoChanged});

  final Todo todo;
  final TodoChangeFunction onTodoChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () {
          Provider.of<TodoModel>(context, listen: false).set(todo.toggle());
        },
        leading: CircleAvatar(
          child: Text(todo.name[0]),
        ),
        title: Text(todo.name, style: _getTextStyle(todo.checked)));
  }

  TextStyle _getTextStyle(bool checked) {
    if (!checked) return const TextStyle(color: Colors.black54);
    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }
}




