// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously, unnecessary_import, implementation_imports

import 'package:fido2_client/registration_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:fido2_client/fido2_client.dart';
import 'constant.dart';
import 'utilities.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "";
  Fido2Client fido2Client = Fido2Client();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUsername();
  }

  registerWebuth() async {
    Map<String, dynamic> options = {
      "attestation": "none",
      "authenticatorSelection": {
        "authenticatorAttachment": "platform",
        "userVerification": "required",
        "requireResidentKey": false
      }
    };

    Map<String, dynamic> response = await postRequest("/auth/registerRequest", options);
    // print(response);
    RegistrationResult registrationResult = await fido2Client.initiateRegistration(
      response["challenge"],
      response["user"]["id"],
      response,
    );
  }

  setUsername() async {
    username = (await getStringValue("username"))!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    contextMain = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                username.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () => registerWebuth(),
                child: Text("Register a new Authn"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
