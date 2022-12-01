// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/main.dart';
import 'package:todo_app/todo_model.dart';

void main() {
  group('Main widget', () {
    testWidgets('Should create the todo list app', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(TodoApp(todoRepo: MockTodoRepo()));

      expect(find.text('Todo list'), findsOneWidget);

      expect(find.byTooltip('Add Item'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Should display the add dialog', (WidgetTester tester) async {
      const todoText = 'Test todo item';
      await tester.pumpWidget(TodoApp(todoRepo: MockTodoRepo()));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text("Add"), findsOneWidget);
      await tester.enterText(
          find.byKey(const ValueKey('Todo-Text')), todoText);

      await tester.tap(find.text("Add"));

      await tester.pumpAndSettle();
      expect(find.text(todoText), findsOneWidget);
      //add logic for adding a todo
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