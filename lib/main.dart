import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/notification/notification_api.dart';
import 'package:todo_app/settings.dart';
import 'package:todo_app/todo_add_dialog.dart';
import 'package:todo_app/todo_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  TodoRepository repo = TodoRepository.instance;
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(TodoApp(todoRepo: repo, prefs: prefs));
}

class TodoApp extends StatelessWidget {
  final TodoRepository todoRepo;
  final SharedPreferences prefs;

  const TodoApp({super.key, required this.todoRepo, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => TodoModel(todoRepo),
        child: MaterialApp(
            title: "Todo list",
            initialRoute: '/',
            routes: {
              '/': (context) => TodoList(prefs: prefs),
              '/todo': (context) => const TodoPage(),
              '/settings': (context) => SettingsPage(prefs: prefs)
            },
            theme: ThemeData(
                brightness: Brightness.light,
                primarySwatch: Colors.blueGrey,
                scaffoldBackgroundColor: Colors.white,
                textTheme: const TextTheme(bodyText2: TextStyle(color: Colors.redAccent)),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.titleMedium,
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white),
                ))));
  }
}

class TodoList extends StatefulWidget {
  final SharedPreferences prefs;

  const TodoList({super.key, required this.prefs});

  @override
  State createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    var model = context.watch<TodoModel>();
    var todos = <Todo>[];
    todos.addAll(model.todos);
    todos.sort((first, second) {
      var result = first.date.compareTo(second.date);
      if (result != 0 ) {
        return result;
      }
      if (first.checked && !second.checked) {
        return -1;
      }
      if (second.checked) {
        return 1;
      }
      return 0;
    });

    return Scaffold(
        appBar: AppBar(
          title: const Text('Todo list'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, "/settings").whenComplete(() {
                  setState(() {});
                });
              },
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: todos
                  .where((todo) => (widget.prefs.getBool(showComplete) ?? false) || !(todo.checked))
                  .map((Todo todo) {
                return TodoItem(
                  key: Key("Todo-${todo.id}"),
                  todo: todo,
                );
              }).toList(),
            ))
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, "/todo"), tooltip: 'Add Item', child: const Icon(Icons.add)));
  }
}

typedef TodoChangeFunction = void Function(BuildContext context, Todo? todo);

class TodoItem extends StatelessWidget {
  const TodoItem({super.key, required this.todo});

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    var model = context.watch<TodoModel>();
    return Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            model.remove(todo);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Todo "${todo.name}" dismissed')));
          } else {
            Provider.of<TodoModel>(context, listen: false).set(todo.toggle());
            NotificationHelper.instance.notify("Todo App", "Todo: ${todo.name} completed");
          }
        },
        background: Container(
          alignment: AlignmentDirectional.centerStart,
          color: todo.checked ? Colors.amber : Colors.green,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: Icon(
              todo.checked ? Icons.check_box_outline_blank : Icons.check_box,
              color: Colors.white,
            ),
          ),
        ),
        secondaryBackground: Container(
          alignment: AlignmentDirectional.centerEnd,
          color: Colors.red,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        child: ListTile(
          leading: IconButton(
            icon: todo.checked ? const Icon(Icons.check_box_outlined) : const Icon(Icons.check_box_outline_blank),
            onPressed: () {
              Provider.of<TodoModel>(context, listen: false).set(todo.toggle());
              NotificationHelper.instance.notify("Todo App", "Todo: ${todo.name} completed");
            },
          ),
          title: Text(todo.name, style: _getTextStyle(todo, _styleFromDate(todo, context))),
          subtitle: Text(formatDate(todo.date), style: _getDateStyle(todo, _styleFromDate(todo, context))),
          onTap: () {
            Navigator.pushNamed(context, "/todo", arguments: todo);
          },
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
