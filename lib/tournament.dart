import 'package:flutter/material.dart';

class TournamentPage extends StatelessWidget {
  TournamentPage({super.key, required this.id});
  final int id;
  late Future<Map> tournament;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map>(
          future: tournament,
          builder: (context, snapshot) {
            return Text(
              snapshot.data!['Name'],
            );
          },
        ),
      ),
      body: FutureBuilder<Map>(
        future: tournament,
        builder: (context, snapshot) {
          return Column(
            children: [Text(snapshot.data!['Description'])],
          );
        },
      ),
    );
  }
}
