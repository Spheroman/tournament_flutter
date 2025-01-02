import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';

const storage = FlutterSecureStorage();

class LoginAlert extends StatefulWidget {
  const LoginAlert({super.key});

  @override
  State<StatefulWidget> createState() => _LoginAlertState();
}

class _LoginAlertState extends State<LoginAlert> {
  late TextEditingController _controller1;
  late TextEditingController _controller2;
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
      title: const Text('Login'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        TextField(
          decoration: const InputDecoration(
            labelText: "Username",
            border: OutlineInputBorder(),
          ),
          controller: _controller1,

        ),
        const SizedBox(height: 20,),
        TextField(
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(),
          ),
          controller: _controller2,
        ),
        Text(error),
      ],),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            print("ok");
            var navigator = Navigator.of(context);
            var body = jsonEncode({"username": _controller1.text, "password": _controller2.text});
            final response = await http.post(Uri.parse('$url/api/login'), headers: {"Content-Type": "application/json"}, body: body);
            print(response.body);
            if(response.statusCode == 201) {
              Map vals = jsonDecode(response.body) as Map<String, dynamic>;
              print(vals['data']['token']);
              await storage.write(key: "token", value: vals['data']['token']);
              if(!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successful"),));
              navigator.pop();
            }
            else {
              setState(() {
                Map vals = jsonDecode(response.body) as Map<String, dynamic>;
                error = vals['data'];
              });
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

}

class SignupAlert extends StatefulWidget {
  const SignupAlert({super.key});

  @override
  State<StatefulWidget> createState() => _SignupAlertState();
}

class _SignupAlertState extends State<SignupAlert> {
  late TextEditingController _controller1;
  late TextEditingController _controller2;
  late TextEditingController _controller3;
  String error = "";

  @override
  void initState() {
    super.initState();
    _controller1 = TextEditingController();
    _controller2 = TextEditingController();
    _controller3 = TextEditingController();
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Register'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: "Username",
              border: OutlineInputBorder(),
            ),
            controller: _controller1,

          ),
          const SizedBox(height: 20,),
          TextField(
            decoration: const InputDecoration(
              labelText: "Email Address",
              border: OutlineInputBorder(),
            ),
            controller: _controller2,

          ),
          const SizedBox(height: 20,),

          TextField(
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
            ),
            controller: _controller3,
          ),
          Text(error),
        ],),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            print("ok");
            var navigator = Navigator.of(context);
            var body = jsonEncode({"username": _controller1.text, "password": _controller3.text, "email": _controller2.text});
            final response = await http.post(Uri.parse('$url/api/signup'), headers: {"Content-Type": "application/json"}, body: body);
            print(response.body);
            if(response.statusCode == 201) {
              Map vals = jsonDecode(response.body) as Map<String, dynamic>;
              print(vals['data']['token']);
              await storage.write(key: "token", value: vals['data']['token']);
              if(!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration Successful"),));
              navigator.pop();
            }
            else {
              setState(() {
                Map vals = jsonDecode(response.body) as Map<String, dynamic>;
                error = vals['data'];
              });
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

}