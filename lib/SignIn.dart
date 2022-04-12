// @dart=2.9
import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:device_information/device_information.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:scanqr/Services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget{
  const SignIn({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignIn>{
  final _controllerUrl = TextEditingController();
  FocusNode _nodeUrl;
  bool _focusedUrl = false;
  bool _fieldEmptyUrl = false;
  bool _invalidUrl = false;
  bool _anyErrorUrl = false;
  final _controllerCi = TextEditingController();
  FocusNode _nodeCi;
  bool _focusedCi = false;
  bool _fieldEmptyCi = false;
  bool _invalidLength = false;
  bool _notContainJustNumbers = false;
  bool _invalidDateCi = false;
  bool _anyErrorCi = false;
  bool _firstBuild = true;
  double _height;
  double _width;
  bool _connected = true;
  bool _active = false;

  @override
  void initState() {
    _nodeUrl = FocusNode();
    _nodeUrl.addListener(_handleFocusChangeUrl);
    _nodeCi = FocusNode();
    _nodeCi.addListener(_handleFocusChangeCi);
    super.initState();
  }

  @override
  void dispose() {
    _nodeUrl.removeListener(_handleFocusChangeUrl);
    _nodeUrl.dispose();
    _controllerUrl.dispose();
    _nodeCi.removeListener(_handleFocusChangeCi);
    _nodeCi.dispose();
    _controllerCi.dispose();
    super.dispose();
  }

  void _handleFocusChangeUrl() {
    if (_nodeUrl.hasFocus != _focusedUrl) {
      setState(() {
        _focusedUrl = _nodeUrl.hasFocus;
      });
    }
  }

  void _handleFocusChangeCi() {
    if (_nodeCi.hasFocus != _focusedCi) {
      setState(() {
        _focusedCi = _nodeCi.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_firstBuild){
      _height = MediaQuery.of(context).size.height;
      _width = MediaQuery.of(context).size.width;
      _firstBuild = false;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            scale: 2.1,
            opacity: 0.2,
            image: AssetImage('assets/Cujae.png'),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            SizedBox(height: _height * 0.225,),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text('Url',
                style: TextStyle(fontSize: 17, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: _controllerUrl,
                focusNode: _nodeUrl,
                decoration: InputDecoration(
                  errorText: _anyErrorUrl ? showMessageError() : null,
                  labelText: 'Inserte la Url',
                  labelStyle: Services.setLabelStyle(_focusedUrl, _anyErrorUrl),
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      style: BorderStyle.solid,
                      color: Colors.green[900],
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      style: BorderStyle.solid,
                      color: Colors.green[600],
                      width: 1.0,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                ),
                cursorColor: Colors.grey,
                onSubmitted: (text) async {
                  bool data = _controllerUrl.text.startsWith("w") ? await Services.urlValidator(_controllerUrl.text) : await Services.launchURL(_controllerUrl.text);

                  setState(() {
                    errorHandlerUrl(data);
                  });
                },
              ),
            ),
            SizedBox(height: _height * 0.02,),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text('CI',
                style: TextStyle(fontSize: 17, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: _controllerCi,
                maxLength: 11,
                focusNode: _nodeCi,
                decoration: InputDecoration(
                  errorText: _anyErrorCi ? showMessageErrorCi() : null,
                  labelText: 'Inserte su carnet de identidad',
                  labelStyle: Services.setLabelStyle(_focusedCi, _anyErrorCi),
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      style: BorderStyle.solid,
                      color: Colors.green[900],
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      style: BorderStyle.solid,
                      color: Colors.green[600],
                      width: 1.0,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                ),
                cursorColor: Colors.grey,
                onSubmitted: (text) {
                  setState(() {
                    errorHandlerCi();
                  });
                },
              ),
            ),
            SizedBox(height: _height * 0.2,),
            Row(
              children: <Widget>[
                SizedBox(width: _width * 0.38,),
                ElevatedButton(
                  style: raisedButtonStyle,
                  onPressed: () async {
                    bool internet = await InternetConnectionChecker().hasConnection;
                    bool data = _controllerUrl.text.startsWith("w") ? await Services.urlValidator(_controllerUrl.text) : await Services.launchURL(_controllerUrl.text);

                    setState(() {
                      errorHandlerCi();
                      errorHandlerUrl(data);
                      _connected = internet;
                    });

                    if (!_anyErrorCi && !_anyErrorUrl && _connected){
                      String device = await _featureDevice();
                      String token = await _createJsonWebTokenEnroll(_controllerCi.text, device, '3rN35t0');/*
                      final response = await http.post(
                        Uri.parse("www.google.com"),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode(<String, String>{
                          'token': token,
                        }),
                      );*/
                      _verifyJsonWebTokenEnroll(token, '3rN35t0');
                      _setControllerEnroll();
                      Navigator.pushNamed(
                          context,
                          '/url',
                          arguments: {
                            'before': "role",
                            'idDevice': "20202020"
                          }
                      );
                    } else if(!_connected && !_active){
                      _active = true;
                      Services.showToastSemaphore(
                          Colors.yellow[700],
                          Icons.wifi_off_outlined,
                          "El dispositivo no tiene\n acceso a Internet",
                          context,
                          _height,
                          _width,
                          0.205,
                          0.2,
                          0.2
                      );
                      Services.notification();
                      Future.delayed(const Duration(milliseconds: 2500), ()=> _active = false);
                    }
                  },
                  child: const Text('Enrolar'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
    onPrimary: Colors.green[900],
    primary: Colors.green[100],
    minimumSize: const Size(88, 36),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  );

  void errorHandlerCi() {
    String ci = _controllerCi.text;

    if(ci.isEmpty) {
      _notContainJustNumbers = false;
      _invalidLength = false;
      _invalidDateCi = false;
      _fieldEmptyCi = true;
    } else if(inValidCi(ci)){
      _fieldEmptyCi = false;
      _invalidLength = false;
      _invalidDateCi = false;
      _notContainJustNumbers = true;
    }
    else if(ci.length < 11){
      _fieldEmptyCi = false;
      _notContainJustNumbers = false;
      _invalidDateCi = false;
      _invalidLength = true;
    } else if(!verifyDateCi(ci)){
      _fieldEmptyCi = false;
      _notContainJustNumbers = false;
      _invalidLength = false;
      _invalidDateCi = true;
    }else {
      _fieldEmptyCi = false;
      _notContainJustNumbers = false;
      _invalidLength = false;
      _invalidDateCi = false;
    }

    _anyErrorCi = _fieldEmptyCi || _notContainJustNumbers || _invalidLength || _invalidDateCi;
  }

  void errorHandlerUrl(bool data){
    if(_controllerUrl.text.isEmpty) {
      _invalidUrl = false;
      _fieldEmptyUrl = true;
    } else if(data){
      _fieldEmptyUrl = false;
      _invalidUrl = true;
    }else{
      _invalidUrl = false;
      _fieldEmptyUrl = false;
    }

    _anyErrorUrl = _fieldEmptyUrl || _invalidUrl;
  }

  String showMessageError(){
    String stringError;

    if(_fieldEmptyUrl) {
      stringError = "Este campo no puede estar vacío";
    } else {
      stringError = "La URL no es válida";
    }

    return stringError;
  }

  String showMessageErrorCi(){
    String stringError;

    if(_fieldEmptyCi) {
      stringError = "Este campo no puede estar vacío";
    } else if(_invalidLength) {
      stringError = "El carnet de identidad solo puede tener 11 dígitos";
    } else if(_notContainJustNumbers){
      stringError = "El carnet de identidad solo puede tener dígitos";
    } else {
      stringError = "Formato de fecha incorrecto";
    }

    return stringError;
  }

  bool inValidCi(String ci) {
    bool result = false;
    List<String> numbers = ['0','1','2','3','4','5','6','7','8','9'];

    for(int i = 0; i < ci.length && !result; i++) {
      if(!numbers.contains(ci[i])){
        result = true;
        break;
      }
    }

    return result;
  }

  bool verifyDateCi(String ci){
    bool result = true;
    List<int> months30 = [4,6,9,11];

    int day = int.parse(ci[4] + ci[5]);
    int year = int.parse(ci[0] + ci[1]);
    int month = int.parse(ci[2] + ci[3]);

    if (day > 31 || month > 12 || day == 0 || month == 0){
      result = false;
    } else if (months30.contains(month) && day == 31){
      result = false;
    } else if (month == 2 && year % 4 != 0 && day > 28){
      result = false;
    } else if (month == 2 && year % 4 == 0 && day > 29){
      result = false;
    }

    return result;
  }

  void _setControllerEnroll() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isEnroll', true);
  }

  Future<String> _featureDevice() async {
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

  Future<String> _createJsonWebTokenEnroll(String ci, String phoneFeatures, String password) async {
    String token;

    /* Sign */ {
      // Create a json web token
      final jwt = JWT(
        {
          'ci': ci,
          'phoneFeatures': phoneFeatures,
        },
      );

      // Sign it
      token = jwt.sign(SecretKey(password));
      //print('Signed token: $token\n');
    }

    return token;
  }

  void _verifyJsonWebTokenEnroll(String token, String password){
    /* Verify */ {

      try {
        // Verify a token
        final jwt = JWT.verify(token, SecretKey(password));
        print('Payload: ${jwt.payload['ci']}\n ${jwt.payload['phoneFeatures']}');
      } on JWTExpiredError {
        Exception('jwt expired');
      } on JWTError catch (ex) {
        Exception(ex.message); // ex: invalid signature
      }
    }
  }
}