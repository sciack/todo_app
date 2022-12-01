import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';

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
    return {
      'id': id,
      'name': name,
      'checked': checked
    };
  }

}

class TodoRepository {
  var _file;
  static final TodoRepository INSTANCE = TodoRepository._privateConstructor();

  TodoRepository._privateConstructor();

  Future<File> get _localFile async {
    _file ??= await _initFile();
    return _file;
  }

  Future<File> _initFile() async {
    var directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/todo.json');
  }

  Future<void> save(List<Todo> todos) async {
    var json = jsonEncode(todos);
    final localFile = await _localFile;
    localFile.writeAsString(json);
  }

  Future<List<Todo>> read() async {
    final localFile = await _localFile;
    final json = await localFile.readAsString();
    final List<dynamic> jsonObject = jsonDecode(json);
    return jsonObject.map((json) => Todo.fromJson(json)).toList();
  }
}
