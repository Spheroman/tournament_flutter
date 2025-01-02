import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';

const storage = FlutterSecureStorage();

class EditTournamentAlert extends StatefulWidget {
  const EditTournamentAlert({super.key, required this.tournament});
  final Map tournament;

  @override
  State<StatefulWidget> createState() => _EditTournamentAlertState();
}

class _EditTournamentAlertState extends State<EditTournamentAlert> {
  late TextEditingController _controller1;
  late TextEditingController _controller2;
  String? selected = "Name";
  dynamic second = "";
  String type = "Single Elimination";
  String error = "";

  @override
  void initState() {
    super.initState();
    _controller1 = TextEditingController();
    _controller2 = TextEditingController();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Tournament'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownMenu(
              initialSelection: "name",
              label: const Text('Option'),
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: "Name", label: "Name"),
                DropdownMenuEntry(value: "Description", label: "Description"),
                DropdownMenuEntry(value: "IsComplete", label: "Is Complete"),
                DropdownMenuEntry(value: "Address", label: "Address"),
                DropdownMenuEntry(value: "ChildOf", label: "Parent Tournament"),
                DropdownMenuEntry(value: "Public", label: "Public View"),
                DropdownMenuEntry(value: "ComponentType", label: "Type"),
              ],
            onSelected: (String? value) {
              setState(() {

                _controller2.text = (widget.tournament[value]??"").toString();
                print(widget.tournament[value]);
                second = widget.tournament[value];
                if ((value == "IsComplete" || value == "Public") && second.runtimeType != bool) second = second == 1 ? true : false;
                selected = value;
              });
            },
          ),
          SizedBox(height: 20,),
          Builder(builder: (context) {
            var shortField = SizedBox(
                width: 250,
                child: TextField(

                  onChanged: (val) {
                    setState(() {
                      second = val;
                    });
                  },
                    controller: _controller2,
                    decoration: const InputDecoration(
                      labelText: "Value",
                      border: OutlineInputBorder(),
                    )));
            var textField = SizedBox(
              width: 400,
              child: TextField(
                  onChanged: (val) {
                    setState(() {
                      second = val;
                    });
                  },
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: _controller2,
                  decoration: const InputDecoration(
                  labelText: "Value",
                  border: OutlineInputBorder(),
              )));
              var numberField = SizedBox(
            width: 250,
                child: TextField(
                onChanged: (val) {
              setState(() {
                second = int.parse(val);
              });
            },
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            controller: _controller2,
            decoration: const InputDecoration(
            labelText: "Value",
            border: OutlineInputBorder(),
            )));
            switch (selected) {
              case "Name":
                return shortField;
              case "Description":
                return textField;
              case "IsComplete":
                second ??= false;
                return Switch(
                    value: second ?? false,
                    onChanged: (bool value) {
                      setState(() {
                        second = value;
                      });
                    });
              case "Address":
                return textField;
              case "ChildOf":
                return numberField;
              case "Public":
                return Switch(
                    value: second ?? false,
                    onChanged: (bool value) {
                      setState(() {
                        second = value;
                      });
                    });
              case "ComponentType":
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Single Elimination'),
                      leading: Radio<String>(value: 'Single Elimination', groupValue: second, onChanged: (String? value) {setState(() {
                        second = value!;
                      });},),
                    ),
                    ListTile(
                      title: const Text('Double Elimination'),
                      leading: Radio<String>(value: 'Double Elimination', groupValue: second, onChanged: (String? value) {setState(() {
                        second = value!;
                      });},),
                    ),
                    ListTile(
                      title: const Text('Swiss'),
                      leading: Radio<String>(value: 'Swiss', groupValue: second, onChanged: (String? value) {setState(() {
                        second = value!;
                      });},),
                    ),
                  ],
                );

            }
            return Container();
          }),
          Text(second.runtimeType.toString()),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            var token = await storage.read(key: "token");

            var body =
                jsonEncode({"detailKey": selected, "detailsValue": second});
            final response = await http.post(
                Uri.parse('$url/api/tournament/${widget.tournament['Id']}/setDetails'),
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": token!
                },
                body: body);
            if (response.statusCode == 200) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Tournament Updated"),
              ));
              var navigator = Navigator.of(context);
              navigator.pop();
            } else {
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
