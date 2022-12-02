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

      todoModel.add(name, DateTime.now());
    });

    test('Set an item should be notified', () {
      final todoModel = TodoModel(MockTodoRepo());
      const name = "A todo";
      todoModel.add(name, DateTime.now());

      todoModel.addListener(() {
        expect(todoModel.todos[0].checked, equals(true));
      });

      var todo = todoModel.todos[0];
      todo = Todo(id: todo.id, name: todo.name, checked: !todo.checked, date: todo.date);
      todoModel.set(todo);
    });

    test('Store should trigger a save', () {
      final repo = MockTodoRepo();
      final todoModel = TodoModel(repo);
      const name = "A todo";
      repo.expectedElement = 1;
      todoModel.add(name, DateTime.now());
      repo.expectedElement = 0;
    });
  });
}


class MockTodoRepo implements TodoRepository {
  final List<Todo> _todos = [];
  int expectedElement = 0;
  
  @override
  Future<void> save(List<Todo> todos) async {
    expect(todos.length, greaterThanOrEqualTo(expectedElement));
    _todos.clear();
    _todos.addAll(todos);
  }

  @override
  Future<List<Todo>> read() async {
    return _todos;
  }
}