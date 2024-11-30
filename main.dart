import 'dart:html';
import 'dart:convert';

class TodoItem {
  String id;
  String text;
  bool isCompleted;

  TodoItem({
    required this.text, 
    this.isCompleted = false
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'isCompleted': isCompleted
  };

  static TodoItem fromJson(Map<String, dynamic> json) => TodoItem(
    text: json['text'],
    isCompleted: json['isCompleted']
  );
}

class TodoApp {
  final List<TodoItem> _todos = [];
  final InputElement _todoInput = querySelector('#todoInput') as InputElement;
  final ButtonElement _addTodoBtn = querySelector('#addTodoBtn') as ButtonElement;
  final UListElement _todoList = querySelector('#todoList') as UListElement;
  final SpanElement _totalTodosSpan = querySelector('#totalTodos') as SpanElement;
  final SpanElement _completedTodosSpan = querySelector('#completedTodos') as SpanElement;

  TodoApp() {
    _addTodoBtn.onClick.listen(_addTodo);
    _todoInput.onKeyPress.listen(_handleEnterKey);
    _loadTodos();
  }

  void _addTodo([Event? event]) {
    final text = _todoInput.value?.trim();
    if (text != null && text.isNotEmpty) {
      final newTodo = TodoItem(text: text);
      _todos.add(newTodo);
      _renderTodo(newTodo);
      _todoInput.value = '';
      _updateStats();
      _saveTodos();
    }
  }

  void _handleEnterKey(KeyboardEvent event) {
    if (event.key == 'Enter') {
      _addTodo();
    }
  }

  void _renderTodo(TodoItem todo) {
    final listItem = LIElement()
      ..className = 'todo-item ${todo.isCompleted ? 'completed' : ''}'
      ..setAttribute('data-id', todo.id);

    final textSpan = SpanElement()
      ..text = todo.text
      ..onClick.listen((_) => _toggleTodo(todo));

    final deleteBtn = ButtonElement()
      ..text = 'Delete'
      ..className = 'delete-btn'
      ..onClick.listen((_) => _deleteTodo(todo));

    listItem.children.addAll([textSpan, deleteBtn]);
    _todoList.append(listItem);
  }

  void _toggleTodo(TodoItem todo) {
    todo.isCompleted = !todo.isCompleted;
    _updateTodoDisplay(todo);
    _updateStats();
    _saveTodos();
  }

  void _updateTodoDisplay(TodoItem todo) {
    final todoElement = _todoList.querySelector('[data-id="${todo.id}"]');
    if (todoElement != null) {
      todoElement.classes.toggle('completed', todo.isCompleted);
    }
  }

  void _deleteTodo(TodoItem todo) {
    _todos.removeWhere((t) => t.id == todo.id);
    _todoList.querySelector('[data-id="${todo.id}"]')?.remove();
    _updateStats();
    _saveTodos();
  }

  void _updateStats() {
    final completedCount = _todos.where((todo) => todo.isCompleted).length;
    _totalTodosSpan.text = 'Total: ${_todos.length}';
    _completedTodosSpan.text = 'Completed: $completedCount';
  }

  void _saveTodos() {
    final todosJson = _todos.map((todo) => todo.toJson()).toList();
    window.localStorage['todos'] = jsonEncode(todosJson);
  }

  void _loadTodos() {
    final storedTodos = window.localStorage['todos'];
    if (storedTodos != null) {
      final List<dynamic> todosJson = jsonDecode(storedTodos);
      _todos.clear();
      _todoList.children.clear();
      
      for (var todoJson in todosJson) {
        final todo = TodoItem.fromJson(todoJson);
        _todos.add(todo);
        _renderTodo(todo);
      }
      _updateStats();
    }
  }
}

void main() {
  TodoApp();
}