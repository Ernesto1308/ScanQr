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
  bool _invalidEndpoint = false;
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
  bool _enable = true;
  String _idDevice;
  Future<JWT> _credentialInfo;

  @override
  void initState() {
    _nodeUrl = FocusNode();
    _nodeUrl.addListener(_handleFocusChangeUrl);
    _nodeCi = FocusNode();
    _nodeCi.addListener(_handleFocusChangeCi);
    _loadUrl();
    _loadCi();
    _loadComponentsState();
    if (!_enable) _credentialInfo = Services.providerCredentialInfo(_idDevice, _controllerUrl.text, '3rN35t0');
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
      body: Stack(
        children: <Widget> [
          Container(
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text('Url',
                    style: TextStyle(
                        fontSize: 17,
                        color: _enable ? Colors.black : Colors.grey
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    enabled: _enable,
                    keyboardType: TextInputType.url,
                    controller: _controllerUrl,
                    focusNode: _nodeUrl,
                    style: TextStyle(
                        color: _enable ? Colors.black : Colors.grey
                    ),
                    decoration: InputDecoration(
                      errorText: _anyErrorUrl ? showMessageError() : null,
                      labelText: 'Inserte la Url',
                      labelStyle: _setLabelStyleSignIn(_focusedUrl, _anyErrorUrl),
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
                      setState(() {
                        errorHandlerUrl();
                      });
                    },
                  ),
                ),
                SizedBox(height: _height * 0.02,),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Text('CI',
                    style: TextStyle(
                        fontSize: 17,
                        color: _enable ? Colors.black : Colors.grey
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    enabled: _enable,
                    controller: _controllerCi,
                    maxLength: 11,
                    focusNode: _nodeCi,
                    style: TextStyle(
                        color: _enable ? Colors.black : Colors.grey
                    ),
                    decoration: InputDecoration(
                      errorText: _anyErrorCi ? showMessageErrorCi() : null,
                      labelText: 'Inserte su carnet de identidad',
                      labelStyle: _setLabelStyleSignIn(_focusedCi, _anyErrorCi),
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
                      onPressed: _enable ? () => _buttonEnabled() : null,
                      child: const Text('Enrolar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if(!_enable) FutureBuilder<JWT>(
            future: _credentialInfo,
            builder: (BuildContext context, AsyncSnapshot<JWT> snapshot) {
              if(snapshot.connectionState != ConnectionState.done){
                return Center(
                    child: CircularProgressIndicator(
                      color: Colors.green[900],
                    )
                );
              } else {
                if (snapshot.data.payload["status"] == "success"){
                  if (snapshot.data.payload["data"]["status_device"] == "1"){
                    Future.delayed(
                        const Duration(seconds: 1), () async {
                      await _loadIdDevice();
                      Navigator.pushNamed(
                          context,
                          '/url',
                          arguments: {
                            'before': "role",
                            'idDevice': _idDevice
                          }
                      );
                    }
                    );
                  } else if (snapshot.data.payload["data"]["status_device"] == "0"){
                    Future.delayed(const Duration(seconds: 1), ()=> Services.showToastSystem(
                        Colors.grey[350],
                        const Duration(milliseconds: 4500),
                        "Su credencial aún no está activa",
                        context,
                        _height,
                        _width,
                        0.25,
                        0.1,
                        0.1
                    ));
                    Services.notification();
                  }
                }
                return const Center();
              }
            },
          ),
        ],
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

  void _buttonEnabled() async {
    _connected = await InternetConnectionChecker().hasConnection;

    setState(() {
      errorHandlerCi();
      errorHandlerUrl();
    });

    if (!_anyErrorCi && !_anyErrorUrl && _connected){
      await _setControllerUrl();
      await _setControllerCi();
      String device = await _featureDevice();
      String token = await Services.createJsonWebToken({'ci': _controllerCi.text, 'phone_features': device}, '3rN35t0');

      if (!_controllerUrl.text.endsWith("/enroll")){
        _controllerUrl.text = _controllerUrl.text + "/enroll";
      }

      final response = await http.post(
        Uri.parse(_controllerUrl.text),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'token': token,
        }),
      );
      token = jsonDecode(response.body)['token'];
      JWT jwt = Services.verifyJsonWebToken(token, '3rN35t0');

      setState(() {
        _enable = false;
      });

      await _setComponentsState();

      if (jwt.payload['status'] == "success"){
        setState(() {
          _idDevice = jwt.payload['data']["id_device"];
        });

        _setControllerIdDevice();

        JWT credential = await Services.providerCredentialInfo(_idDevice, _controllerUrl.text, '3rN35t0');

        if (credential.payload["status"] == "success"){
          if (credential.payload["data"]["status_device"] == "1"){
            _setControllerEnroll();
            Future.delayed(
                const Duration(seconds: 1), () async {
              await _loadIdDevice();
              Navigator.pushNamed(
                  context,
                  '/url',
                  arguments: {
                    'before': "role",
                    'idDevice': _idDevice
                  }
              );
            }
            );
          } else if (credential.payload["data"]["status_device"] == "0"){
            Future.delayed(const Duration(seconds: 1), ()=> Services.showToastSystem(
                Colors.grey[350],
                const Duration(milliseconds: 4500),
                "Su credencial aún no está activa",
                context,
                _height,
                _width,
                0.25,
                0.1,
                0.1
            ));
            Services.notification();
          }
        }
      } else {
        Services.showToastSystem(
            Colors.grey[350],
            const Duration(milliseconds: 2500),
            "En estos momentos no está\n disponible su acceso, por favor\n contacte con un administrador",
            context,
            _height,
            _width,
            0.23,
            0.1,
            0.1
        );
        Services.notification();
      }
    } else if(!_connected && !_active){
      _active = true;
      Services.showToastSemaphore(
          Colors.yellow[700],
          const Duration(milliseconds: 2500),
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
  }

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

  Future<void> errorHandlerUrl() async {
    String url = _controllerUrl.text;
    bool data = _controllerUrl.text.startsWith("w") ? await Services.urlValidator(_controllerUrl.text) : await Services.launchURL(_controllerUrl.text);

    if(url.isEmpty) {
      _invalidEndpoint = false;
      _invalidUrl = false;
      _fieldEmptyUrl = true;
    } else if(data){
      _invalidEndpoint = false;
      _fieldEmptyUrl = false;
      _invalidUrl = true;
    } else if(url.endsWith("/reg") || url.endsWith("/aut")){
      _invalidUrl = false;
      _fieldEmptyUrl = false;
      _invalidEndpoint = true;
    } else{
      _invalidEndpoint = false;
      _invalidUrl = false;
      _fieldEmptyUrl = false;
    }

    _anyErrorUrl = _fieldEmptyUrl || _invalidUrl || _invalidEndpoint;
  }

  String showMessageError(){
    String stringError;

    if(_fieldEmptyUrl) {
      stringError = "Este campo no puede estar vacío";
    } else if(_invalidUrl){
      stringError = "La URL no es válida";
    } else {
      stringError = "Solo se permite el endpoint /enroll";
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

  Future<void> _setControllerUrl() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('url', _controllerUrl.text);
    });
  }

  Future<void> _loadUrl() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _controllerUrl.text = (prefs.getString('url'));
    });
  }

  Future<void> _setControllerCi() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('ci', _controllerCi.text);
    });
  }

  Future<void> _loadCi() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _controllerCi.text = (prefs.getString('ci'));
    });
  }

  Future<void> _setComponentsState() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setBool('enabled', _enable);
    });
  }

  Future<void> _loadComponentsState() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      if (prefs.getBool('enabled')!= null) {
        _enable = prefs.getBool('enabled');
      }
    });
  }

  Future<void> _setControllerIdDevice() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('idDevice', _idDevice);
    });
  }

  Future<String> _loadIdDevice() async {
    final prefs = await SharedPreferences.getInstance();

    return (prefs.getString('idDevice'));
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

  TextStyle _setLabelStyleSignIn(bool focused, bool anyError){
    TextStyle result;

    if(focused){
      result = TextStyle(fontSize: 16, color: Colors.green[600]);
    } else{
      result = TextStyle(fontSize: 16, color: Colors.green[900]);
    }

    if (anyError){
      result = const TextStyle(fontSize: 16, color: Colors.red);
    }

    if (!_enable){
      result = const TextStyle(fontSize: 16, color: Colors.grey);
    }

    return result;
  }
}