// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously, unnecessary_import, implementation_imports

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constant.dart';
import 'home.dart';
import 'login.dart';
import 'utilities.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> onSubmit() async {
    isLoading = true;
    setState(() {});

    final http.Response response = await http.post(
      Uri.parse("$BASE_URL/auth/registerUser"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "username": usernameController.text.trim(),
        "password": passwordController.text.trim(),
      }),
    );
    if (response.statusCode == 200) {
      dynamic body = jsonDecode(response.body);
      debugPrint(body.toString());
      if (body["status"] == "error") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(body["message"]),
          duration: Duration(milliseconds: 500),
        ));
      } else {
        setStringValue("cookie", response.headers['set-cookie'].toString());
        setStringValue("username", usernameController.text);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (builder) => HomeScreen()),
          (route) => false,
        );
      }
    } else {
      debugPrint(response.statusCode.toString());
      throw Exception('Failed to load album');
    }
    isLoading = false;
    setState(() {});
  }

  @override
  void dispose() {
    // ignore: todo
    // TODO: implement dispose
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    contextMain = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fido Demo"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: Icon(Icons.login),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
        child: Column(
          children: [
            Text(
              "Register User",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: usernameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                labelText: "Username",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  // borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: passwordController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                icon: Icon(Icons.password),
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                enabledBorder: OutlineInputBorder(
                  // borderSide: BorderSide(color: Colors.lightBlueAccent, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16.0)),
              onPressed: isLoading ? null : onSubmit,
              child: isLoading
                  ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                        // color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Text('SUBMIT'),
            )
          ],
        ),
      ),
    );
  }
}
