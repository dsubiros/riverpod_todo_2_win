import 'package:flutter/foundation.dart' show immutable;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'todo.g.dart';

final _uuid = Uuid();

@immutable
class Todo {
  final String id;
  final String description;
  final bool completed;

  const Todo({
    required this.id,
    required this.description,
    this.completed = false,
  });

  @override
  String toString() {
    return 'Todo(id: $id, description: $description, completed: $completed)';
  }

  Todo copyWith({
    id,
    description,
    completed,
  }) {
    return Todo(
      id: id ?? this.id,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }
}

@riverpod
class TodoList extends _$TodoList {
  @override
  List<Todo> build() {
    return [
      const Todo(id: 'todo-0', description: 'Pray before going to sleep'),
      const Todo(id: 'todo-1', description: 'Take the dog out'),
      const Todo(id: 'todo-2', description: 'Build an app'),
      const Todo(id: 'todo-3', description: 'Obey the Lord in everything'),
    ];
  }

  void add(String description) {
    state = [
      ...state,
      Todo(id: _uuid.v4(), description: description),
    ];
  }

  void toggle(String id) => state = state
      .map((todo) =>
          todo.id == id ? todo.copyWith(completed: !todo.completed) : todo)
      .toList();

  void remove(Todo target) {
    state = state.where((todo) => todo.id != target.id).toList();
  }

  void edit({required String id, required description}) {
    state = state
        .map((todo) =>
            todo.id == id ? todo.copyWith(description: description) : todo)
        .toList();
  }
}
