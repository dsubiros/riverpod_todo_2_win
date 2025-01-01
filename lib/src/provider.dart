import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_todo_2/src/todo.dart';

part 'provider.g.dart';

/// Keys
final addTodoKey = UniqueKey();
final activeTodoFilterKey = UniqueKey();
final completedFilterKey = UniqueKey();
final allFilterKey = UniqueKey();

/// Filters available
enum TodoListFilter {
  all,
  active,
  completed,
}

@riverpod
TodoListFilter todoListFilter(_) => TodoListFilter.all;

@riverpod
List<Todo> filteredTodos(Ref ref) {
  final filter = ref.watch(todoListFilterProvider);
  final todos = ref.watch(todoListProvider);

  switch (filter) {
    case TodoListFilter.completed:
      return todos.where((todo) => todo.completed).toList();
    case TodoListFilter.active:
      return todos.where((todo) => !todo.completed).toList();
    case TodoListFilter.all:
      return todos;
  }
}

@riverpod
List<Todo> completedTodos(Ref ref) =>
    ref.watch(todoListProvider).where((todo) => todo.completed).toList();

// @riverpod
// int uncompletedTodosCount(Ref ref) =>
//     ref.watch(todoListProvider).where((todo) => !todo.completed).length;

final uncompletedTodosCount = Provider<int>((ref) =>
    ref.watch(todoListProvider).where((todo) => !todo.completed).length);
