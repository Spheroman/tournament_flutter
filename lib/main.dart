import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:tournament_app/createTournament.dart';
import 'package:tournament_app/login.dart';
import 'tournament.dart';
import 'ui.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';

const storage = FlutterSecureStorage();

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
  Future<bool> loggedIn = storage.containsKey(key: "token");
  UniqueKey key = UniqueKey();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          PopupMenuButton(
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    PopupMenuItem(
                      child: const Text("Login"),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const LoginAlert();
                            }).then((_) => setState(() {
                              loggedIn = storage.containsKey(key: "token");
                            }));
                      },
                    ),
                    PopupMenuItem(
                      child: const Text("Register"),
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const SignupAlert();
                            }).then((_) => setState(() {
                              loggedIn = storage.containsKey(key: "token");
                            }));
                      },
                    ),
                    PopupMenuItem(
                      child: const Text("Logout"),
                      onTap: () async {
                        await storage.deleteAll();
                        setState(() {
                          loggedIn = storage.containsKey(key: "token");
                        });
                      },
                    ),
                  ])
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: loggedIn,
          builder: (context, value) {
            List ret = ["All", "Next"];
            if (value.hasData && value.data!) {
              ret.add("Saved");
              ret.add("Owned");
            }
            return ListView.builder(
              key: key,
              itemCount: ret.length,
              itemBuilder: (context, index) {
                return UICard(
                  ret[index],
                  SizedBox(
                    height: 200,
                    child: TournamentList(
                      onReturn: () {
                        setState(() {
                          key = UniqueKey();
                        });
                      },
                        type: ret[index].toLowerCase()
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const NewTournamentAlert();
            },
          ).then((val) {
            setState(() {
              key = UniqueKey();
            });
            if(val != null && context.mounted) {context.push(val);}
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TournamentList extends StatefulWidget {
  const TournamentList({super.key, required this.type, required this.onReturn});
  final VoidCallback onReturn;
  final String type;
  @override
  State<TournamentList> createState() => _TournamentList();
}

class _TournamentList extends State<TournamentList> {
  ScrollController controller = ScrollController();
  List<Map> list = [];

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

  Future<void> refresh() async{
    getTournaments(widget.type);
  }

  Future<void> getTournaments(String type) async {
    String token;
    if (await storage.containsKey(key: "token")) {
      token = (await storage.read(key: "token"))!;
    } else {
      token = "";
    }
    final response = await http.get(
        Uri.parse('$url/api/list/$type'),
        headers: {"Authorization": token});
    if (response.statusCode == 200) {
      Map vals = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        if (vals['body'] != null) {
          list = [];
          for(var val in vals['body']){
            list.add(val);
          }
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
      controller: controller,
      scrollDirection: Axis.horizontal,
      itemCount: list.length,
      itemBuilder: (context, index) {
        return UICard(
          list[index]['Name'],
          Text("id: ${list[index]['Id']}"),
          clickable: true,
          inkWell: InkWell(
              onTap: () => context.push("/${list[index]['Id']}").whenComplete(
                    widget.onReturn
                  )),
        );
      },
    );
  }
}
