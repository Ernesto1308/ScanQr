// @dart=2.9
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Services.dart';

class Configuration extends StatefulWidget{
  const Configuration({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration>{
  final String _developerPassword = "1234";
  String _newEncryptionPassword;
  bool _correctPassword = false;
  bool _isDeveloperSwitched = false;
  bool _isChangePassSwitched = false;
  final _controllerInsert = TextEditingController();
  final _controllerChange = TextEditingController();
  bool _firstBuild = true;
  double _height;
  double _width;
  FToast _fToast;
  final GlobalKey<FormState> _formKeyInsert = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyChange = GlobalKey<FormState>();
  final _controllerUrl = TextEditingController();
  bool _fieldEmpty = false;
  bool _invalidUrl = false;
  bool _containEndpoint = false;
  bool _focused = false;
  bool _anyError = false;
  FocusNode _node;

  @override
  void initState() {
    _loadText();
    _node = FocusNode();
    _node.addListener(_handleFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    _node.removeListener(_handleFocusChange);
    _node.dispose();
    _controllerInsert.dispose();
    _controllerChange.dispose();
    _controllerUrl.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_node.hasFocus != _focused) {
      setState(() {
        _focused = _node.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _fToast = FToast();
    _fToast.init(context);

    if (_firstBuild){
      _height = MediaQuery.of(context).size.height;
      _width = MediaQuery.of(context).size.width;
      _firstBuild = false;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          splashRadius: 23,
          onPressed: () async {
            bool validUrl = _controllerUrl.text.startsWith("w") ? await Services.urlValidator(_controllerUrl.text) : await Services.launchURL(_controllerUrl.text);

            setState(() {
              errorHandler(validUrl);
            });

            if(!_anyError) {
              _isDeveloperSwitched = false;
              _correctPassword = false;
              Navigator.popAndPushNamed(
                  context,
                  '/url',
                  arguments: <String,String>{
                    'before': "configuration",
                    'newEncryptionPass': _newEncryptionPassword,
                    'url': _controllerUrl.text
                  }
              );
            }
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: const Text(
          "Configuración Avanzada",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[800],
      ),
      body: Column(
        children: <Widget>[
          _createSwitchDeveloper(),
          if (_isDeveloperSwitched && _correctPassword) _createSwitchToChangePass(),
          if (_isDeveloperSwitched && _correctPassword) _createUrlTextField()
        ],
      ),
    );
  }

  SwitchListTile _createSwitchDeveloper(){
    return SwitchListTile(
      title: const Text(
        "Opciones del desarrollador",
      ),
      onChanged: (bool value) {
        setState(() {
          _isDeveloperSwitched = value;
        });
        if (_isDeveloperSwitched) _showDialogInsertPass();
      },
      value: _isDeveloperSwitched,
      activeColor: Colors.green[800],
      activeTrackColor: Colors.green.withOpacity(0.5),
    );
  }

  SwitchListTile _createSwitchToChangePass(){
    return SwitchListTile(
      title: const Text(
        "Cambiar contraseña de encriptación",
      ),
      onChanged: (bool value) {
        setState(() {
          _isChangePassSwitched = value;
        });
        if (_isChangePassSwitched) _showDialogChangePass();
      },
      value: _isChangePassSwitched,
      activeColor: Colors.green[800],
      activeTrackColor: Colors.green.withOpacity(0.5),
    );
  }

  Future<void> _showDialogInsertPass() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contraseña'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Inserte la contraseña'),
                Form(
                  key: _formKeyInsert,
                  child: TextFormField(
                    cursorColor: Colors.green[600],
                    controller: _controllerInsert,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          style: BorderStyle.solid,
                          color: Colors.green[900],
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          style: BorderStyle.solid,
                          color: Colors.green[600],
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Colors.green[900]
                  ),
              ),
              onPressed: () {
                setState(() {
                  _isDeveloperSwitched = false;
                  _correctPassword = false;
                });
                _controllerInsert.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                  'Aceptar',
                  style: TextStyle(
                      color: Colors.green[900]
                  ),
              ),
              onPressed: () {
                setState(() {
                  if (_developerPassword == _controllerInsert.text) {
                    _correctPassword = true;
                  } else {
                    _isDeveloperSwitched = false;
                    _correctPassword = false;
                  }
                });

                _controllerInsert.clear();
                Navigator.of(context).pop();

                if (!_correctPassword){
                  _showToastPass(Colors.grey[300], "Contraseña incorrecta");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDialogChangePass() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambio de contraseña'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Inserte la nueva contraseña de encriptación'),
                Form(
                  key: _formKeyChange,
                  child: TextFormField(
                    cursorColor: Colors.green[600],
                    controller: _controllerChange,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          style: BorderStyle.solid,
                          color: Colors.green[900],
                          width: 1.0,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          style: BorderStyle.solid,
                          color: Colors.green[600],
                          width: 1.0,
                        ),
                      ),
                    ),
                    validator: (value){
                      String result;
                      if (value.isEmpty) result = "Este campo no puede estar vacío";

                      return result;
                    },
                    onFieldSubmitted: (text){
                      _formKeyChange.currentState.validate();
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancelar',
                style: TextStyle(
                    color: Colors.green[900]
                ),
              ),
              onPressed: () {
                setState(() {
                  _isChangePassSwitched = false;
                });
                _controllerChange.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Cambiar',
                style: TextStyle(
                    color: Colors.green[900]
                ),
              ),
              onPressed: () {
                if (_formKeyChange.currentState.validate()){
                  setState(() {
                    _isChangePassSwitched = false;
                    _newEncryptionPassword = _controllerChange.text;
                  });
                  _controllerChange.clear();
                  Navigator.of(context).pop();
                  _showToastPass(Colors.grey[300], "Contraseña cambiada exitosamente");
                }
              },
            ),
          ],
        );
      },
    );
  }

  Column _createUrlTextField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
            focusNode: _node,
            decoration: InputDecoration(
              errorText: _anyError ? showMessageError() : null,
              labelText: 'Inserte la Url',
              labelStyle: Services.setLabelStyle(_focused, _anyError),
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
              bool validUrl = _controllerUrl.text.startsWith("w") ? await Services.urlValidator(_controllerUrl.text) : await Services.launchURL(_controllerUrl.text);
              _setController();

              setState(() {
                errorHandler(validUrl);
              });
            },
          ),
        ),
      ],
    );
  }

  void errorHandler(bool validUrl){
    String url = _controllerUrl.text;

    if(url.isEmpty) {
      _invalidUrl = false;
      _containEndpoint = false;
      _fieldEmpty = true;
    } else if(validUrl){
      _fieldEmpty = false;
      _containEndpoint = false;
      _invalidUrl = true;
    } else if(url.endsWith("/enroll") || url.endsWith("/aut") || url.endsWith("/reg")){
      _fieldEmpty = false;
      _invalidUrl = false;
      _containEndpoint = true;
    } else{
      _invalidUrl = false;
      _containEndpoint = false;
      _fieldEmpty = false;
    }

    _anyError = _fieldEmpty || _invalidUrl || _containEndpoint;
  }

  String showMessageError(){
    String stringError;

    if(_fieldEmpty) {
      stringError = "Este campo no puede estar vacío";
    } else if(_containEndpoint){
      stringError = "El servidor no puede contener ningún endpoint";
    } else {
      stringError = "La URL no es válida";
    }

    return stringError;
  }

  void _loadText() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _controllerUrl.text = (prefs.getString('urlSaved') ?? "");
    });
  }

  Future<void> _setController() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('urlSaved', _controllerUrl.text);
    });
  }


  _showToastPass(Color color, String info) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
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
        toastDuration: const Duration(milliseconds: 2500),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            bottom: _height * 0.1,
            left: _width * 0.1,
            right: _width * 0.1,
          );
        }
    );
  }
}