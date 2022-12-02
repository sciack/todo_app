import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/todo_add_dialog.dart';
import 'package:todo_app/todo_model.dart';

void main() {
  TodoRepository repo = TodoRepository.instance;
  runApp(TodoApp(todoRepo: repo));
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
    var todos = <Todo>[];
    todos.addAll(model.todos);
    todos.sort((first, second) {
      if (first.checked && !second.checked) {
        return -1;
      }
      if (second.checked) {
        return 1;
      }
      return first.date.compareTo(second.date);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo list'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: todos
            .where((todo) => !(todo.isLate() && todo.checked))
            .map((Todo todo) {
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

  void _toggleTodoChecked(Todo todo) {}
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
      title: Text(todo.name, style: _getTextStyle(todo)),
      subtitle: Text(formatDate(todo.date), style: _getDateStyle(todo)),

    );
  }

  TextStyle _getTextStyle(Todo todo) {
    Color color = colorFromDate(todo);
    if (!todo.checked) return TextStyle(color: color);
    return TextStyle(
      color: color,
      decoration: TextDecoration.lineThrough,
    );
  }

  TextStyle _getDateStyle(Todo todo) {
    TextStyle style = _getTextStyle(todo);
    return TextStyle(
        color: style.color,
        decoration: style.decoration,
        fontStyle: FontStyle.italic,
        fontSize: (style.fontSize ?? 14) * 0.8);
  }

  Color colorFromDate(Todo todo) {
    Color color;
    if (todo.isLate()) {
      color = Colors.red;
    } else {
      color = Colors.black54;
    }
    return color;
  }
}

String formatDate(DateTime date) {
  return DateFormat(DateFormat.YEAR_MONTH_DAY).format(date);
}


