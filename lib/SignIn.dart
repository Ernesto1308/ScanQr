// @dart=2.9
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _node = FocusNode();
    _node.addListener(_handleFocusChange);
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
                                  width: 300,
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
                                    labelStyle: _focused ? TextStyle(fontSize: 16, color: Colors.green[600]) : TextStyle(fontSize: 16, color: Colors.green[900]),
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
                              SizedBox(height: _height * 0.2,),
                              ElevatedButton(
                                style: raisedButtonStyle,
                                onPressed: () {
                                  setState(() {
                                    errorHandler();
                                  });

                                  if (!_anyError){
                                    Navigator.pushNamed(context, '/url');
                                  }
                                },
                                child: const Text('Enrolar'),
                              ),
                              const SizedBox(height: 100,),
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
}