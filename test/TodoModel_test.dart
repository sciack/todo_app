import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/todo_model.dart';

void main() {

  group('Todo Notifier', () {
    test('Adding item should be notified', () {
      final todoModel = TodoModel(MockTodoRepo());
      const name = "A todo";
      todoModel.addListener(() {
        expect(todoModel.todos.length, equals(1));
        expect(todoModel.todos[0].name, equals(name));
      });

      todoModel.add(name);
    });

    test('Set an item should be notified', () {
      final todoModel = TodoModel(MockTodoRepo());
      const name = "A todo";
      todoModel.add(name);

      todoModel.addListener(() {
        expect(todoModel.todos[0].checked, equals(true));
      });

      var todo = todoModel.todos[0];
      todo = Todo(id: todo.id, name: todo.name, checked: !todo.checked);
      todoModel.set(todo);
    });
  });
}


class MockTodoRepo implements TodoRepository {
  List<Todo> _todos = [];

  @override
  Future<void> save(List<Todo> todos) async {
    expect(todos.length, greaterThan(0));
    _todos = todos;
  }

  @override
  Future<List<Todo>> read() async {
    return _todos;
  }
}