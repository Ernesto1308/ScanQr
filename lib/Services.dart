import 'dart:ui';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:device_information/device_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Services{
  static Future<String> featureDevice() async {
    String manufacturer = '',
        productName = '';

    try {
      manufacturer = await DeviceInformation.deviceManufacturer;
      productName = await DeviceInformation.productName;
    } on PlatformException catch (e) {
      e.message;
    }

    return manufacturer + " " + productName;
  }

  static Future<String> createJsonWebToken(String text) async {
    String token;
    String device = await featureDevice();

    /* Sign */ {
      // Create a json web token
      final jwt = JWT(
        {
          'info': text + " " + device,
        },
      );

      // Sign it
      token = jwt.sign(SecretKey('3rN35t0'));
      print('Signed token: $token\n');
    }

    return token;
  }

  static void verifyJsonWebToken(String token){
    /* Verify */ {

      try {
        // Verify a token
        final jwt = JWT.verify(token, SecretKey('3rN35t0'));
        print('Payload: ${jwt.payload['info']}');
      } on JWTExpiredError {
        Exception('jwt expired');
      } on JWTError catch (ex) {
        Exception(ex.message); // ex: invalid signature
      }
    }
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

  static String showMessageError(bool fieldEmpty){
    String stringError;

    if(fieldEmpty) {
      stringError = "Este campo no puede estar vacío";
    } else {
      stringError = "La URL no es válida";
    }

    return stringError;
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
}