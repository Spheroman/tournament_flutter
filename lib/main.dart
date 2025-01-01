import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'tournament.dart';

// GoRouter configuration
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(title: 'Tournament App'),
    ),
    GoRoute(
      path: '/:id',
      builder: (context, state) => tournament(id: state.pathParameters['id']!),
    ),
  ],
);

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => context.go('/1234'),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [TournamentList()],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<Map> fetchTournamentList(String endpoint) async{
  final response = await http.get(Uri.parse('http://115.165.225.39:3000/api/list/$endpoint'));
  if(response.statusCode == 200){
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception(response.body);
  }
}

class TournamentList extends StatefulWidget {
  const TournamentList({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _TournamentList extends State<TournamentList> {
  late ScrollController controller;
  late List<Future<Map>> items;

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(_scrollListener);
    items.addAll()
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return FutureBuilder(future: items[index], builder: (context, snapshot) {
          return Card(child: Text(snapshot.data!['Name']),);
        }, );
      },
    );
  }

  void _scrollListener() {
    print(controller.position.extentAfter);
    if (controller.position.extentAfter ==
        controller.position.maxScrollExtent) {
      setState(() {
        items.addAll(List.generate(42, (index) => 'Inserted $index'));
      });
    }
  }
}
