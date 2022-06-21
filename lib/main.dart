// @dart=2.9
import 'package:flutter/material.dart';
import 'package:scanqr/Configuration.dart';
import 'package:scanqr/SignIn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'QRViewExample.dart';
import 'Url.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  bool result = false;
  if (prefs.getBool('isEnroll') != null){
    result = true;
  }
  runApp(
    MaterialApp(
      initialRoute: result ? '/url' : '/enroll',
      routes: getApplicationRoutes(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

  Map<String, Widget Function(BuildContext)> getApplicationRoutes() {
    return <String, Widget Function(BuildContext)>{
      '/url': (context) => const Url(),
      '/scanner': (context) => const QRViewExample(),
      '/enroll': (context) => const SignIn(),
      '/configuration': (context) => const Configuration()
    };
  }
