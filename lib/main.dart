// @dart=2.9
import 'package:flutter/material.dart';
import 'package:scanqr/Configuration.dart';
import 'package:scanqr/SignIn.dart';
import 'QRViewExample.dart';
import 'Url.dart';

void main() => runApp(
  MaterialApp(
    initialRoute: '/role',
    routes: getApplicationRoutes(),
    debugShowCheckedModeBanner: false,
  ),
);

Map<String, Widget Function(BuildContext)> getApplicationRoutes() {
  return <String, Widget Function(BuildContext)>{
    '/url': (context) => const Url(),
    '/scanner': (context) => const QRViewExample(),
    '/role': (context) => const SignIn(),
    '/configuration': (context) => const Configuration()
  };
}
