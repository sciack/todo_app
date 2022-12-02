import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo_app/todo_model_repo.dart'
    if (dart.library.io) 'package:todo_app/todo_model_io.dart'
    if (dart.library.js) 'package:todo_app/todo_model_web.dart';

class TodoModel extends ChangeNotifier {
  final List<Todo> _todos = [];
  final TodoRepository repo;
  bool _showExpired = false;

  set showExpired(bool show) {
    _showExpired = show;
    notifyListeners();
  }

  bool get isShowExpired => _showExpired;

  UnmodifiableListView<Todo> get todos => UnmodifiableListView(_todos);

  TodoModel(this.repo) {
    Future.microtask(() => _loadTodo());
    addListener(() {
      repo.save(todos);
    });
  }

  int _next() {
    if (_todos.isEmpty) {
      return 0;
    } else {
      return _todos.map((todo) => todo.id).reduce(max) + 1;
    }
  }

  Future<void> _loadTodo() async {
    _todos.clear();
    _todos.addAll(await repo.read());
    notifyListeners();
  }

  void set(Todo todo) {
    _todos[todo.id] = todo;
    notifyListeners();
  }

  void add(String name, DateTime date) {
    _todos.add(Todo(id: _next(), name: name, date: date, checked: false));
    notifyListeners();
  }

  bool remove(Todo todo) {
    final length = _todos.length;
    _todos.removeWhere((element) => element.id == todo.id);
    notifyListeners();
    return length != _todos.length;
  }


}

class Todo {
  Todo(
      {required this.id,
      required this.name,
      required this.checked,
      required this.date});

  Todo.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        id = json['id'],
        checked = json['checked'],
        date = parseDate(json['date']);

  final String name;
  final bool checked;
  final int id;
  final DateTime date;

  Todo toggle() {
    return Todo(id: id, name: name, date: date, checked: !checked);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'checked': checked,
      'date': date.toIso8601String()
    };
  }

  bool isLate() {
    var now = DateTime.now();
    var difference = date.difference(now);
    return difference.inDays < 0;
  }
}

abstract class TodoRepository {
  Future save(List<Todo> todos);

  static TodoRepository? _instance;

  Future<List<Todo>> read();


  static TodoRepository get instance {
    _instance ??= getTodoRepository();
    return _instance!;
  }
}

DateTime parseDate(String? dateStr) {
  if (dateStr == null) {
    return DateTime.now();
  }
  return DateTime.parse(dateStr);
}
