// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:todo_app/main.dart';
import 'package:todo_app/todo_model.dart';

void main() {
  group('Main widget', () {
    SharedPreferences? prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'show complete': true});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('Should create the todo list app', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(TodoApp(todoRepo: MockTodoRepo(), prefs: prefs!));
      expect(find.text('Todo list'), findsOneWidget);

      expect(find.byTooltip('Add Item'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Should display the add dialog', (WidgetTester tester) async {
      const todoText = 'Test todo item';
      await tester.pumpWidget(TodoApp(todoRepo: MockTodoRepo(), prefs: prefs!));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text("Add"), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('Todo-Text')), todoText);

      await tester.tap(find.text("Add"));

      await tester.pumpAndSettle();
      expect(find.text(todoText), findsOneWidget);
      //add logic for adding a todo
    });

    testWidgets('Should remove a todo', (WidgetTester tester) async {
      const todoText = 'Test todo item';
      await tester.pumpWidget(TodoApp(todoRepo: MockTodoRepo(), prefs: prefs!));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text("Add"), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('Todo-Text')), todoText);

      await tester.tap(find.text("Add"));

      await tester.pumpAndSettle();

      expect(find.text(todoText), findsOneWidget);
      await tester.drag(find.text(todoText), const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(find.text(todoText), findsNothing);
    });

    testWidgets('Swipe left should check a todo', (WidgetTester tester) async {
      const todoText = 'Test todo item';
      await tester.pumpWidget(TodoApp(todoRepo: MockTodoRepo(), prefs: prefs!));

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text("Add"), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('Todo-Text')), todoText);

      await tester.tap(find.text("Add"));

      await tester.pumpAndSettle();

      expect(find.text(todoText), findsOneWidget);
      await tester.drag(find.text(todoText), const Offset(500, 0));
      await tester.pumpAndSettle();

      var item = tester.widget<TodoItem>(find.byKey(const Key("Todo-0")));
      expect(item.todo.checked, equals(true));
      var text = tester.widget<Text>(find.text(todoText));
      expect(text.style?.decoration, equals(TextDecoration.lineThrough));
    });
  });
}

class MockTodoRepo implements TodoRepository {
  List<Todo> _todos = [];

  @override
  Future<void> save(List<Todo> todos) async {
    _todos = todos;
  }

  @override
  Future<List<Todo>> read() async {
    return _todos;
  }
}
