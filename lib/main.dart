import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'tournament.dart';
import 'ui.dart';

// GoRouter configuration
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MyHomePage(title: 'Tournament App'),
    ),
    GoRoute(
      path: '/:id',
      builder: (context, state) =>
          TournamentPage(id: state.pathParameters['id']!),
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
        child: Column(children: [
            UICard("All", Container(height: 200,
              child:TournamentList(type: "all")))
            
        ],),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TournamentList extends StatefulWidget {
  const TournamentList({super.key, required this.type});
  final String type;
  @override
  State<TournamentList> createState() => _TournamentList();
}

class _TournamentList extends State<TournamentList> {
  ScrollController controller = ScrollController();
  final List<Map> list = [];

  @override
  void initState() {
    super.initState();
    getTournaments(widget.type);
    controller.addListener(() {
      if (controller.position.atEdge) {
        if (controller.position.pixels == 0) {
          print('ListView scroll at top');
        } else {
          print('ListView scroll at bottom');
        }
      }
    });
  }

  Future<void> getTournaments(String type) async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/api/list/$type'));
    if (response.statusCode == 200) {
      Map vals = jsonDecode(response.body) as Map<String, dynamic>;
      print(vals['body'][0].runtimeType);
      setState(() {
        for (Map val in vals['body']) {
          list.add(val);
        }
      });
    } else {
      throw Exception(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: list.length,
      itemBuilder: (context, index) {
        return UICard(
          list[index]['Name'],
          Text("id: ${list[index]['Id']}"),
          clickable: true,
          inkWell: InkWell(onTap: () => context.go("/${list[index]['Id']}")),
        );
      },
    );
  }
}
