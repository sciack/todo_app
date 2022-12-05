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
        child: MaterialApp(
            title: "Todo list",
            home: const TodoList(),
            theme: ThemeData(
                brightness: Brightness.light,
                primarySwatch: Colors.blueGrey,
                scaffoldBackgroundColor: Colors.white,
                textTheme: const TextTheme(
                    bodyText2: TextStyle(color: Colors.redAccent)))));
  }
}

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.caption;
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
      body: Column(
        children: [
          Row(children: [
            Switch(
                key: const Key('completed-switch'),
                value: model.isShowExpired,
                onChanged: (bool value) {
                  model.showExpired = value;
                }),
            Container(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Text(
                  'Show completed item',
                  style: textStyle,
                )),
          ]),
          Expanded(
              child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            children: todos
                .where((todo) => model.isShowExpired || !(todo.checked))
                .map((Todo todo) {
              return TodoItem(
                key: Key("Todo-${todo.id}"),
                todo: todo,
                onTodoChanged: _toggleTodoChecked,
              );
            }).toList(),
          ))
        ],
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
    var model = context.watch<TodoModel>();
    return Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            model.remove(todo);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Todo "${todo.name}" dismissed')));
          } else {
            Provider.of<TodoModel>(context, listen: false).set(todo.toggle());
          }
        },
        background: Container(
          alignment: AlignmentDirectional.centerStart,
          color: Colors.green,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
            child: Icon(
              todo.checked?Icons.check_box_outline_blank:Icons.check_box,
              color: Colors.white,
            ),
          ),
        ),
        secondaryBackground: Container(
          alignment: AlignmentDirectional.centerEnd,
          color: Colors.red,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            child: Text(todo.name[0].toUpperCase()),
          ),
          title: Text(todo.name,
              style: _getTextStyle(todo, _styleFromDate(todo, context))),
          subtitle: Text(formatDate(todo.date),
              style: _getDateStyle(todo, _styleFromDate(todo, context))),
        ));
  }

  TextStyle? _getTextStyle(Todo todo, TextStyle? baseTextStyle) {
    if (!todo.checked) return baseTextStyle;
    return TextStyle(
      color: baseTextStyle?.color,
      decoration: TextDecoration.lineThrough,
    );
  }

  TextStyle _getDateStyle(Todo todo, TextStyle? baseTextStyle) {
    TextStyle? style = _getTextStyle(todo, baseTextStyle);
    return TextStyle(
        color: style?.color,
        decoration: style?.decoration,
        fontStyle: FontStyle.italic,
        fontSize: (style?.fontSize ?? 14) * 0.8);
  }

  TextStyle? _styleFromDate(Todo todo, BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    if (todo.isLate()) {
      return textTheme.bodyText2;
    } else {
      return textTheme.bodyText1;
    }
  }
}

String formatDate(DateTime date) {
  return DateFormat(DateFormat.YEAR_MONTH_DAY).format(date);
}
