import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';

const storage = FlutterSecureStorage();


class TournamentPage extends StatefulWidget {
  const TournamentPage({super.key, required this.id});
  final String id;

  @override
  State<TournamentPage> createState() => _TournamentPageState();
}

class _TournamentPageState extends State<TournamentPage> {
  late Future<Map> tournament = getTournament(widget.id);

  Future<Map> getTournament(String id) async {
    if(!await storage.containsKey(key: "token")) {
      return {"Name": "Error", "Description": "Please log in to view this page"};
    }
    var token = await storage.read(key: "token");
    final response = await http.get(Uri.parse('$url/api/tournament/$id'), headers: {"Authorization": token!});
    if (response.statusCode == 200) {
      Map vals = jsonDecode(response.body) as Map<String, dynamic>;
      if(vals['body'][0]['Description'] == null) vals['body'][0]['Description'] = "This tournament has no description.";
      return vals['body'][0];
    }
    else if (response.statusCode == 404) {
      Map vals = {"Name": "Error 404", "Description": "This page does not exist."};
      return vals;
    }
    else {
      throw Exception(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map>(
          future: tournament,
          builder: (context, snapshot) {
            if(snapshot.hasData) {
              return Text(snapshot.data?["Name"]);
            } else {
              return const Text("Loading");
            }
          },
        ),
      ),
      body: FutureBuilder<Map>(
        future: tournament,
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return Column(
              children: [Text(snapshot.data?['Description'])],
            );
          } else {
            return const Text("Loading");
          }
        },
      ),
    );
  }
}
