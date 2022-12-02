import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:todo_app/todo_model.dart';

class LocalFileTodoRepository implements TodoRepository {
  File? _file;

  Future<File> get _localFile async {
    _file = await _initFile();
    return _file!;
  }

  Future<File> _initFile() async {
    var directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/todo.json');
  }

  @override
  Future save(List<Todo> todos) async {
    var json = jsonEncode(todos);
    final localFile = await _localFile;
    localFile.writeAsString(json);
  }

  @override
  Future<List<Todo>> read() async {
    final localFile = await _localFile;
    final json = await localFile.readAsString();
    final List<dynamic> jsonObject = jsonDecode(json);
    return jsonObject.map((json) => Todo.fromJson(json)).toList();
  }
}

TodoRepository getTodoRepository() => LocalFileTodoRepository();