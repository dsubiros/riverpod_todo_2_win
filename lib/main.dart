import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_todo_2/src/provider.dart';
import 'package:riverpod_todo_2/src/todo.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Material App',
      home: Home(),
    );
  }
}

final _currentTodo = Provider<Todo>((ref) => throw UnimplementedError());

class Home extends HookConsumerWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newTodoController = useTextEditingController();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          children: [
            const Tile(),
            _buildTextField(newTodoController, ref),
            const SizedBox(height: 42.0),
            const Toolbar(),
            const SizedBox(height: 10.0),
            ...ref.watch(filteredTodosProvider).map(
                  (todo) => Dismissible(
                    key: ValueKey(todo.id),
                    onDismissed: (direction) =>
                        ref.read(todoListProvider.notifier).remove(todo),
                    child: ProviderScope(overrides: [
                      _currentTodo.overrideWithValue(todo),
                    ], child: const TodoItem()),
                  ),
                ),
            const SizedBox(height: 50),
            ...ref
                .watch(filteredTodosProvider)
                .map((todo) => Text('- ${todo.toString()}'))
          ],
        ),
      ),
    );
  }

  TextField _buildTextField(TextEditingController controller, WidgetRef ref) {
    return TextField(
      key: addTodoKey,
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'What needs to be done?',
      ),
      onSubmitted: (value) {
        ref.watch(todoListProvider.notifier).add(value);
        controller.clear();
      },
    );
  }
}

class TodoItem extends HookConsumerWidget {
  const TodoItem({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(_currentTodo);

    final itemFocusNode = useFocusNode();
    final itemIsFocused = useItemIsFocused(itemFocusNode);

    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();

    return Material(
      color: Colors.white,
      elevation: 6,
      child: Focus(
        focusNode: itemFocusNode,
        onFocusChange: (isFocused) {
          if (isFocused) {
            textEditingController.text = todo.description;
          } else {
            // Commit changes only when the text field is unfocused, for performance
            ref
                .watch(todoListProvider.notifier)
                .edit(id: todo.id, description: textEditingController.text);
          }
        },
        child: ListTile(
          onTap: () {
            itemFocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          leading: Checkbox(
              value: todo.completed,
              onChanged: (_) =>
                  ref.read(todoListProvider.notifier).toggle(todo.id)),
          title: itemIsFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text(todo.description),
        ),
      ),
    );
  }
}

bool useItemIsFocused(FocusNode node) {
  final isFocused = useState(node.hasFocus);
  useEffect(() {
    void listener() {
      isFocused.value = node.hasFocus;
    }

    node.addListener(listener);

    return () => node.removeListener(listener);
  }, [node]);

  return isFocused.value;
}

class Toolbar extends ConsumerWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final count = ref.watch(uncompletedTodosCount);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text('${ref.watch(uncompletedTodosCount)} items left',
              overflow: TextOverflow.ellipsis),
        ),
        ToolbarItem(),
        Tooltip(
          key: activeTodoFilterKey,
          message: 'Active',
          child: TextButton(
            onPressed: () {},
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              foregroundColor: WidgetStatePropertyAll(Colors.blue),
            ),
            child: const Text('Active'),
          ),
        ),
        Tooltip(
          key: completedFilterKey,
          message: 'Completed',
          child: TextButton(
            onPressed: () {},
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              foregroundColor: WidgetStatePropertyAll(Colors.blue),
            ),
            child: const Text('Completed'),
          ),
        ),
      ],
    );
  }
}

class ToolbarItem extends StatelessWidget {
  const ToolbarItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      key: allFilterKey,
      message: 'All',
      child: TextButton(
        onPressed: () {},
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          foregroundColor: WidgetStatePropertyAll(Colors.blue),
        ),
        child: const Text('All'),
      ),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'todos',
      textAlign: TextAlign.center,
      style: TextStyle(
          fontSize: 100,
          color: Colors.orange,
          fontWeight: FontWeight.w100,
          fontFamily: 'Helvetica Neue'),
    );
  }
}

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a purple toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
