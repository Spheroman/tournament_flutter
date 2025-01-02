import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';
import 'editTournament.dart';

const storage = FlutterSecureStorage();


class TournamentPage extends StatefulWidget {
  const TournamentPage({super.key, required this.id});
  final String id;

  @override
  State<TournamentPage> createState() => _TournamentPageState();
}

class _TournamentPageState extends State<TournamentPage> {
  late Future<Map> tournament = getTournament(widget.id);
  late Future<bool> saved = getJoined(widget.id);

  Future<Map> getTournament(String id) async {
    if(!await storage.containsKey(key: "token")) {
      return {"Name": "Error", "Description": "Please log in to view this page"};
    }
    var token = await storage.read(key: "token");

    final response = await http.get(Uri.parse('$url/api/tournament/$id'), headers: {"Authorization": token!});
    if (response.statusCode == 200) {
      Map vals = jsonDecode(response.body) as Map<String, dynamic>;
      if(vals['body'][0]['Description'] == null) vals['body'][0]['Description'] = "This tournament has no description.";
      vals['body'][0]['userId'] = await storage.read(key: "userId");
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

  Future<bool> getJoined(String id) async {
    if(!await storage.containsKey(key: "token")) {
      return false;
    }
    var token = await storage.read(key: "token");
    final response = await http.get(Uri.parse('$url/api/tournament/$id/players'), headers: {"Authorization": token!});
    if (response.statusCode == 200) {
      Map vals = jsonDecode(response.body) as Map<String, dynamic>;
      var id = int.parse((await storage.read(key: "userId"))!);
      print(vals);
      for(var val in vals['body']){
        print(val);
        if(val["user_id"] == id) return true;
      }
      return false;
    }
    else if (response.statusCode == 404) {
      return false;
    }
    else {
      throw Exception(response.body);
    }
  }

  Future<bool> updateJoined(String id, Future<bool> val) async {
    var token = await storage.read(key: "token");
    var uid = await storage.read(key: "userId");
    var body = jsonEncode({
      "user_id": uid,
      "relation": "joined",
      "value": !await val
    });
    print(body);
    final response = await http.post(Uri.parse('$url/api/tournament/$id/setRelation'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": token!
        },
        body: body);
    print(response.body.toString());
    if(response.statusCode == 200) {
      return !await val;
    }
    return await val;
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
              children: [
                Text(snapshot.data?['Description']),
                TextButton(
                  onPressed: () { saved = updateJoined(widget.id, saved); },
                  child: FutureBuilder(future: saved, builder: (context, snapshot) {
                    if(snapshot.hasData && snapshot.data!){
                      return const Text("Saved");
                    }
                    else {
                      return const Text("Save");
                    }
                  }),
                ),
              ],
            );
          } else {
            return const Text("Loading");
          }
        },
      ),
      floatingActionButton: FutureBuilder(
          future: tournament,
          builder: (context, snapshot) {
            if(snapshot.hasData && snapshot.data?['Owner'].toString() == snapshot.data?['userId']) {
              return FloatingActionButton(
                child: const Icon(Icons.edit),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return EditTournamentAlert(tournament: snapshot.data!,);
                      },
                    ).then((_){
                      setState(() {
                        tournament = getTournament(widget.id);
                      });
                    });
                  },
              );
            }
            return Container();
          },
      ),
    );
  }
}
