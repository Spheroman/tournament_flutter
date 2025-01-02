import 'package:flutter/material.dart';

class TournamentPage extends StatelessWidget {
  const TournamentPage({super.key, required this.id});
  final String id;
  Future<Map> tournament;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FutureBuilder(future:tournament , builder: (context, tournament) => AppBar(title: ),)
    )
  }
}
