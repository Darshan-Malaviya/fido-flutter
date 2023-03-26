// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'constant.dart';
import 'login.dart';

Future<SharedPreferences> getSharedPreferencesInstance() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs;
}

Future<bool> setStringValue(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString(key, value);
}

Future<String?> getStringValue(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? stringValue = prefs.getString(key);
  return stringValue;
}

postRequest(String path, Map<String, dynamic> params) async {
  var cookie = (await getStringValue("cookie"))!;
  final http.Response response = await http.post(
    Uri.parse(BASE_URL + path),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Cookie': cookie,
    },
    body: json.encode(params),
  );
  if (response.statusCode == 200) {
    dynamic body = jsonDecode(response.body);
    // debugPrint(body.toString());
    // if (body["status"] == "error") {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(body["message"]),
    //     duration: const Duration(milliseconds: 500),
    //   ));
    // } else {}
    return body;
  } else {
    debugPrint("response " + response.body.toString());
    if (response.statusCode == 401 ||
        json.decode(response.body)["error"].toString().contains("not signed in.")) {
      Navigator.of(contextMain!).pushAndRemoveUntil(
        MaterialPageRoute(builder: (builder) => LoginScreen()),
        (route) => false,
      );
    }
  }
}
