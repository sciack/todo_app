import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:todo_app/todo_model_repo.dart'
  if (dart.library.io) 'package:todo_app/todo_model_io.dart'
  if (dart.library.js) 'package:todo_app/todo_model_web.dart'
;

class TodoModel extends ChangeNotifier {
  final List<Todo> _todos = [];
  final TodoRepository repo;

  UnmodifiableListView<Todo> get todos => UnmodifiableListView(_todos);

  TodoModel(this.repo) {
    Future.microtask(() => _loadTodo());
    addListener(() {
      repo.save(todos);
    });
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

  void add(String name) {
    _todos.add(Todo(id: _todos.length, name: name, checked: false));
    notifyListeners();
  }
}

class Todo {
  Todo({required this.id, required this.name, required this.checked});

  Todo.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        id = json['id'],
        checked = json['checked'];

  final String name;
  final bool checked;
  final int id;

  Todo toggle() {
    return Todo(id: id, name: name, checked: !checked);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'checked': checked};
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


