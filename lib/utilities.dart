// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings, avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:fido/register.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'constant.dart';
import 'login.dart';

Future<bool> setStringValue(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString(key, value);
}

Future<String?> getStringValue(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? stringValue = prefs.getString(key);
  return stringValue;
}

postRequest(String path, Map<String, dynamic> params, bool giveSession, bool setSession) async {
  Map<String, String> headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'X-Requested-With': 'XMLHttpRequest',
  };
  if (giveSession) {
    var cookie = (await getStringValue("cookie"))!;
    headers["Cookie"] = cookie;
    print("cookie get : " + cookie);
  }

  final http.Response response = await http.post(
    Uri.parse(BASE_URL + path),
    headers: headers,
    body: json.encode(params),
  );
  if (response.statusCode == 200) {
    dynamic body = jsonDecode(response.body);
    print("headers " + response.headers.toString());
    if (setSession) {
      var cookie = response.headers['set-cookie'].toString();
      setStringValue("cookie", cookie);
      print("cookie set : " + cookie);
    }
    return body;
  } else {
    debugPrint("response " + response.body.toString());
    if (response.statusCode == 401 ||
        json.decode(response.body)["error"].toString().contains("not signed in.")) {
      Navigator.of(contextMain!).pushAndRemoveUntil(
        MaterialPageRoute(builder: (builder) => RegisterScreen()),
        (route) => false,
      );
    }
    ScaffoldMessenger.of(contextMain!).showSnackBar(SnackBar(
      content: Text(response.body),
      duration: const Duration(milliseconds: 500),
    ));
    return null;
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class KeyRepository {
  static const String KEY_HANDLE_KEY = 'KEY_HANDLE';

  static Future<String?> loadKeyHandle(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? key = prefs.getString('${KeyRepository.KEY_HANDLE_KEY}#$username');
    return key;
  }

  static Future<void> storeKeyHandle(String keyHandle, String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String k = '${KeyRepository.KEY_HANDLE_KEY}#$username';
    await prefs.setString(k, keyHandle);
  }

  static void removeAllKeys() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getKeys().forEach((key) => prefs.remove(key));
  }
}
