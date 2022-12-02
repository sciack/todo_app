import 'dart:convert';
import 'dart:html';

import 'package:todo_app/todo_model.dart';

class LocalStorageTodoRepository implements TodoRepository {
  final Storage _localStorage = window.localStorage;

  @override
  Future save(List<Todo> todos) async {
    var json = jsonEncode(todos);
    _localStorage['todos'] = json;
  }

  @override
  Future<List<Todo>> read() async {
    var json = _localStorage['todos'];
    if (json == null) {
      return [];
    }
    final List<dynamic> jsonObject = jsonDecode(json);
    return jsonObject.map((json) => Todo.fromJson(json)).toList();
  }
}

TodoRepository getTodoRepository() => LocalStorageTodoRepository();