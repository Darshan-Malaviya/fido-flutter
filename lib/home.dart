// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously, unnecessary_import, implementation_imports

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'constant.dart';
import 'utilities.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "";
  static const fidoChannel = MethodChannel(fidoMethodChannel);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUsername();
    fidoChannel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onRegistrationComplete":
        Map args = call.arguments;
        String keyHandleBase64 = args['keyHandle'];
        await KeyRepository.storeKeyHandle(keyHandleBase64, username);
        print("args $args");
        // registerResponse(args);
        break;
      case "onSigningComplete":
        break;
      case 'onRegAuthError':
        Map args = call.arguments;
        String errorName = args['errorName'];
        String errorMsg = args['errorMsg'];
        // _signCompleter.completeError(AuthenticatorError(errorName, errorMsg));
        break;
      case 'onSignAuthError':
        Map args = call.arguments;
        String errorName = args['errorName'];
        String errorMsg = args['errorMsg'];
        // _signCompleter.completeError(AuthenticatorError(errorName, errorMsg));
        break;
      default:
        throw ('Method not defined');
    }
  }

  registerRequest() async {
    Map<String, dynamic> options = {
      "attestation": "none",
      "authenticatorSelection": {
        "authenticatorAttachment": "platform",
        "userVerification": "required",
        "requireResidentKey": false
      }
    };

    Map<String, dynamic> response =
        await postRequest("/auth/registerRequest", options, true, false);
    if (response != null) {
      try {
        String result = await fidoChannel.invokeMethod("createCredentials", response);
        print(result);
      } on PlatformException catch (e) {
        print(e);
      }
    } else {}
  }

  registerResponse(Map args) async {
    Map<String, dynamic> options = {
      'id': args['keyHandle'],
      'type': 'public-key',
      'rawId': args['keyHandle'],
      'response': {
        'clientDataJSON': args['clientDataJSON'],
        'attestationObject': args['attestationObject'],
      }
    };

    Map<String, dynamic> response =
        await postRequest("/auth/registerResponse", options, true, false);

    if (response != null) {
      // try {
      //   String result = await fidoChannel.invokeMethod("createCredentials", response);
      print(response);
      // } on PlatformException catch (e) {
      //   print(e);
      // }
    } else {}
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
                onPressed: () => registerRequest(),
                child: Text("Register a new Authn"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
