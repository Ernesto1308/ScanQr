// @dart=2.9
import 'dart:convert';
import 'package:device_information/device_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;

class SignIn extends StatefulWidget{
  const SignIn({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignIn>{
  final _controller = TextEditingController();
  FocusNode _node;
  bool _focused = false;
  bool _fieldEmpty = false;
  bool _invalidLength = false;
  bool _notContainJustNumbers = false;
  bool _invalidDateCi = false;
  bool _anyError = false;
  bool _firstBuild = true;
  double _height;
  double _width;
  bool _isConected = true;
  bool _active = false;
  FToast _fToast;
  String _manufacturerName = "",
      _productName = "";

  @override
  void initState() {
    initPlatformState();
    _node = FocusNode();
    _node.addListener(_handleFocusChange);
    _fToast = FToast();
    _fToast.init(context);
    super.initState();
  }

  @override
  void dispose() {
    _node.removeListener(_handleFocusChange);
    _node.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_node.hasFocus != _focused) {
      setState(() {
        _focused = _node.hasFocus;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    if (_firstBuild){
      _height = MediaQuery.of(context).size.height;
      _width = MediaQuery.of(context).size.width;
      _firstBuild = false;
    }

    return Scaffold(
      body: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyText2,
          child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight,
                      ),
                      child: Stack(
                        alignment: AlignmentDirectional.topStart,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              SizedBox(height: _height * 0.265,),
                              Center(
                                child: Image.asset(
                                  'assets/Cujae.png',
                                  width: _width * 0.83,
                                  color: Colors.white.withOpacity(0.2),
                                  colorBlendMode: BlendMode.modulate,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget> [
                              SizedBox(height: _height * 0.38,),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 15),
                                child: Text("Es necesario que se registre en nuestra plataforma, por favor introduzca su número de identidad"),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: TextField(
                                  controller: _controller,
                                  maxLength: 11,
                                  focusNode: _node,
                                  decoration: InputDecoration(
                                    errorText: _anyError ? showMessageError() : null,
                                    labelText: 'Inserte su carnet de identidad',
                                    labelStyle: setLabelStyle(),
                                    fillColor: Colors.green[50],
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
                                      errorHandler();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: _height * 0.3,),
                              ElevatedButton(
                                style: raisedButtonStyle,
                                onPressed: () async {
                                  bool internet = await InternetConnectionChecker().hasConnection;

                                  setState(() {
                                    errorHandler();
                                    _isConected = internet;
                                  });

                                  if (!_anyError && _isConected){
                                    String jsonString = await _loadPasswordAsset();
                                    final jsonResponse = json.decode(jsonString);
                                    String token = await createJsonWebToken(jsonResponse);
                                    /*final response = await http.post(
                                    Uri.parse("www.google.com"),
                                    headers: <String, String>{
                                      'Content-Type': 'application/json; charset=UTF-8',
                                    },
                                    body: jsonEncode(<String, String>{
                                      'token': token,
                                    }),
                                    );*/
                                    verifyJsonWebToken(jsonResponse, token);
                                    Navigator.pushNamed(context, '/url');
                                  } else if(!_isConected && !_active){
                                    _active = true;
                                    _showToast();
                                    Future.delayed(const Duration(milliseconds: 2500), ()=> _active = false);
                                  }
                                },
                                child: const Text('Enrolar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                );
          }
        ),
      ),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail,
    // so we use a try/catch PlatformException.
    String manufacturer = '',
        productName = '';
    try {
      manufacturer = await DeviceInformation.deviceManufacturer;
      productName = await DeviceInformation.productName;
    } on PlatformException catch (e) {
      e.message;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _manufacturerName = manufacturer;
      _productName = productName;
    });
  }

  Future<String> _loadPasswordAsset() async {
    return await rootBundle.loadString('passphrase/password');
  }

  Future<String> createJsonWebToken(Map jsonResponse) async {
    String token;

    /* Sign */ {
      // Create a json web token
      final jwt = JWT(
        {
          'info': _controller.text + " " + _manufacturerName + " " + _productName,
        },
      );

      // Sign it
      token = jwt.sign(SecretKey(jsonResponse['password']));
      //print('Signed token: $token\n');
    }

    return token;
  }

  void verifyJsonWebToken(Map jsonResponse, String token){
    /* Verify */ {

      try {
        // Verify a token
        final jwt = JWT.verify(token, SecretKey(jsonResponse['password']));
        print('Payload: ${jwt.payload['info']}');
      } on JWTExpiredError {
        Exception('jwt expired');
      } on JWTError catch (ex) {
        Exception(ex.message); // ex: invalid signature
      }
    }
  }

  TextStyle setLabelStyle(){
    TextStyle result;

    if(_focused){
      result = TextStyle(fontSize: 16, color: Colors.green[600]);
    } else{
      result = TextStyle(fontSize: 16, color: Colors.green[900]);
    }

    if (_anyError){
      result = const TextStyle(fontSize: 16, color: Colors.red);
    }

    return result;
  }

  void errorHandler() {
    String ci = _controller.text;

    if(ci.isEmpty) {
      _notContainJustNumbers = false;
      _invalidLength = false;
      _invalidDateCi = false;
      _fieldEmpty = true;
    } else if(inValidCi(ci)){
      _fieldEmpty = false;
      _invalidLength = false;
      _invalidDateCi = false;
      _notContainJustNumbers = true;
    }
    else if(ci.length < 11){
      _fieldEmpty = false;
      _notContainJustNumbers = false;
      _invalidDateCi = false;
      _invalidLength = true;
    } else if(!verifyDateCi(ci)){
      _fieldEmpty = false;
      _notContainJustNumbers = false;
      _invalidLength = false;
      _invalidDateCi = true;
    }else {
      _fieldEmpty = false;
      _notContainJustNumbers = false;
      _invalidLength = false;
      _invalidDateCi = false;
    }

    _anyError = _fieldEmpty || _notContainJustNumbers || _invalidLength || _invalidDateCi;
  }

  String showMessageError(){
    String stringError;

    if(_fieldEmpty) {
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

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.yellow[700],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
        [
          const Icon(Icons.wifi_off_outlined),
          SizedBox(width: _width * 0.02,),
          const Text(
            "El dispositivo no tiene\n acceso a Internet",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    // Custom Toast Position
    _fToast.showToast(
        child: toast,
        toastDuration: const Duration(milliseconds: 2500),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            bottom: _height * 0.2,
            left: _width * 0.2,
            right: _width * 0.2,
          );
        });
  }
}