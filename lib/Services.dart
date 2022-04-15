import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';
import 'package:http/http.dart' as http;

class Services{
  static Future<String> createJsonWebToken(Map map, String password) async {
    String token;
    /* Sign */
    {
      // Create a json web token
      final jwt = JWT(
        {
          'data' : map
        }
      );

      // Sign it
      token = jwt.sign(SecretKey(password));
      //print('Signed token: $token\n');
    }

    return token;
  }

  static JWT? verifyJsonWebToken(String token, String password){
    /* Verify */
    {
      try {
        // Verify a token
        final jwt = JWT.verify(token, SecretKey(password));
        //print('Payload:\n ${jwt.payload['qr']}\n ${jwt.payload['mode']}\n ${jwt.payload['idDevice']}');
        return jwt;
      } on JWTExpiredError {
        Exception('jwt expired');
      } on JWTError catch (ex) {
        Exception(ex.message); // ex: invalid signature
      }
    }

    return null;
  }

  static Future<bool> urlValidator(String text) async {
    final ping = Ping(text, count: 1);
    PingData data = await ping.stream.first;

    return data.error?.error != null ? true : false;
  }

  static Future<bool> launchURL(String text) async {
    var pattern = r'^((?:.|\n)*?)((http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?)';
    RegExp regExp = RegExp(pattern);
    bool result = regExp.hasMatch(text);

    return !result;
  }

  static TextStyle setLabelStyle(bool focused, bool anyError){
    TextStyle result;

    if(focused){
      result = TextStyle(fontSize: 16, color: Colors.green[600]);
    } else{
      result = TextStyle(fontSize: 16, color: Colors.green[900]);
    }

    if (anyError){
      result = const TextStyle(fontSize: 16, color: Colors.red);
    }

    return result;
  }

  static TextStyle setLabelStyleInsertPass(bool focused){
    TextStyle result;

    if(focused){
      result = TextStyle(fontSize: 16, color: Colors.green[600]);
    } else{
      result = TextStyle(fontSize: 16, color: Colors.green[900]);
    }

    return result;
  }

  static showToastSystem(Color color, Duration duration, String info, BuildContext context, double height, double width, double percentBottomLocation, double percentRightLocation, double percentLeftLocation) {
    FToast _fToast = FToast();
    _fToast.init(context);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
        [
          Text(
            info,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    // Custom Toast Position
    _fToast.showToast(
        child: toast,
        toastDuration: duration,
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            bottom: height * percentBottomLocation,
            left: width * percentLeftLocation,
            right: width * percentRightLocation,
          );
        }
    );
  }

  static showToastSemaphore(Color color, Duration duration,  IconData icon,String info, BuildContext context, double height, double width, double percentBottomLocation, double percentRightLocation, double percentLeftLocation) {
    FToast _fToast = FToast();
    _fToast.init(context);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
        [
          Icon(icon),
          SizedBox(width: width * 0.02,),
          Text(
            info,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    // Custom Toast Position
    _fToast.showToast(
        child: toast,
        toastDuration: duration,
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            bottom: height * percentBottomLocation,
            left: width * percentLeftLocation,
            right: width * percentRightLocation,
          );
        }
    );
  }

  static Future<void> notification() async {
    Vibration.vibrate(duration: 200);
    return await FlutterRingtonePlayer.play(
        android: AndroidSounds.notification,
        ios: IosSounds.glass,
        looping: false,
        volume: 0.1,
        asAlarm: false
    );
  }

  static Future<bool> credentialVerifier(String idDevice, String url, String password) async {
    await Future.delayed(const Duration(seconds: 10));
    String token = await createJsonWebToken( {"idDevice" : idDevice}, password);
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
      }),
    );
    token = jsonDecode(response.body)['token'];
    JWT? jwt = verifyJsonWebToken(token, password);

    return jwt?.payload["credential"] == "active";
    //return true;
  }
}