// @dart=2.9
import 'package:flutter/material.dart';
import 'package:scanqr/SignIn.dart';
import 'QRViewExample.dart';
import 'Url.dart';

void main() => runApp(
  MaterialApp(
    initialRoute: '/role',
    routes: {
      '/url': (context) => const Url(),
      '/scanner': (context) => const QRViewExample(),
      '/role': (context) => const SignIn(),
    },
    debugShowCheckedModeBanner: false,
  ),
);
