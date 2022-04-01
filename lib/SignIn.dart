// @dart=2.9
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

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
  bool _anyError = false;
  final List<String> _numbers = ['0','1','2','3','4','5','6','7','8','9'];
  bool _firstBuild = true;
  double _height;
  double _width;
  bool _isConected = true;
  bool _active = false;
  FToast _fToast;

  @override
  void initState() {
    super.initState();
    _node = FocusNode();
    _node.addListener(_handleFocusChange);
    _fToast = FToast();
    _fToast.init(context);
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
    _notContainJustNumbers = _validCi(ci);

    if(ci.isEmpty) {
      _notContainJustNumbers = false;
      _invalidLength = false;
      _fieldEmpty = true;
    } else if(_notContainJustNumbers){
      _fieldEmpty = false;
      _invalidLength = false;
    }
    else if(ci.length < 11){
      _fieldEmpty = false;
      _notContainJustNumbers = false;
      _invalidLength = true;
    } else {
      _fieldEmpty = false;
      _notContainJustNumbers = false;
      _invalidLength = false;
    }

    _anyError = _fieldEmpty || _notContainJustNumbers || _invalidLength;
  }

  String showMessageError(){
    String stringError;

    if(_fieldEmpty) {
      stringError = "Este campo no puede estar vacío";
    } else if(_invalidLength) {
      stringError = "El carnet de identidad solo puede tener 11 dígitos";
    } else if(_notContainJustNumbers){
      stringError = "El carnet de identidad solo puede tener dígitos";
    }

    return stringError;
  }

  bool _validCi(String ci) {
    bool result = false;

    for(int i = 0; i < ci.length && !result; i++) {
      if(!_numbers.contains(ci[i])){
        result = true;
        break;
      }
    }

    return result;
  }

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.yellow,
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