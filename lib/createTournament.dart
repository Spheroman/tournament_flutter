import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';

const storage = FlutterSecureStorage();

class NewTournamentAlert extends StatefulWidget {
  const NewTournamentAlert({super.key});

  @override
  State<StatefulWidget> createState() => _NewTournamentAlertState();
}

class _NewTournamentAlertState extends State<NewTournamentAlert> {
  late TextEditingController _controller1;
  String type = "Single Elimination";
  String error = "";

  @override
  void initState() {
    super.initState();
    _controller1 = TextEditingController();
  }

  @override
  void dispose() {
    _controller1.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Login'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: "Tournament Name",
              border: OutlineInputBorder(),
            ),
            controller: _controller1,
          ),
          ListTile(
            title: const Text('Single Elimination'),
            leading: Radio<String>(value: 'Single Elimination', groupValue: type, onChanged: (String? value) {setState(() {
              type = value!;
            });},),
          ),
          ListTile(
            title: const Text('Double Elimination'),
            leading: Radio<String>(value: 'Double Elimination', groupValue: type, onChanged: (String? value) {setState(() {
              type = value!;
            });},),
          ),
          ListTile(
            title: const Text('Swiss'),
            leading: Radio<String>(value: 'Swiss', groupValue: type, onChanged: (String? value) {setState(() {
              type = value!;
            });},),
          ),
        ],),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            var token = await storage.read(key: "token");

            var body = jsonEncode({"name": _controller1.text, "componentType": type});
            final response = await http.post(Uri.parse('$url/api/createComponent'), headers: {"Content-Type": "application/json", "Authorization": token!}, body: body);
            if(response.statusCode == 200) {
              Map vals = jsonDecode(response.body) as Map<String, dynamic>;
              print(vals['data'][0]['Id']);
              if(!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tournament Created"),));
              var navigator = Navigator.of(context);
              navigator.pop("/${vals['data'][0]['Id']}");
            }
            else {
              setState(() {
                Map vals = jsonDecode(response.body) as Map<String, dynamic>;
                error = vals['data'].toString();
              });
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

}