// @dart=2.9
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ManageDialogState.dart';
import 'Services.dart';

class Configuration extends StatefulWidget{
  const Configuration({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConfigurationState();
}

class _ConfigurationState extends State<Configuration>{
  bool _isChangePassSwitched = false;
  bool _wasBuildTextField = false;
  bool _firstBuild = true;
  double _height;
  double _width;
  final _controllerUrl = TextEditingController();
  bool _fieldEmpty = false;
  bool _invalidUrl = false;
  bool _containEndpoint = false;
  bool _focused = false;
  bool _anyError = false;
  bool _connected = false;
  bool _activeToast = false;
  FocusNode _node;
  String _newPass;

  @override
  void initState() {
    super.initState();
    _loadText();
    _node = FocusNode();
    _node.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _node.removeListener(_handleFocusChange);
    _node.dispose();
    _controllerUrl.dispose();
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
            if (_wasBuildTextField){
              await _manageProblemInternet();
            }

            if(!_anyError) {
              await _loadPass();
              Navigator.popAndPushNamed(
                  context,
                  '/url',
                  arguments: <String,String>{
                    'before': "configuration",
                    'newEncryptionPass': _newPass,
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
          _createSwitchToChangePass(),
          _createUrlTextField()
        ],
      ),
    );
  }

  SwitchListTile _createSwitchToChangePass(){
    return SwitchListTile(
      title: const Text(
        "Cambiar contraseña de encriptación",
      ),
      onChanged: (bool value) async {
        setState(() {
          _isChangePassSwitched = value;
        });
        if (_isChangePassSwitched) await _showDialogChangePass();
        setState(() {
          _isChangePassSwitched = false;
        });
      },
      value: _isChangePassSwitched,
      activeColor: Colors.green[800],
      activeTrackColor: Colors.green.withOpacity(0.5),
    );
  }

  Future<void> _showDialogChangePass() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return MyDialogContent(
          height: _height,
          width: _width,
          secondButton: 'Aceptar',
          title: 'Contraseña actual de encriptación',
        );
      },
    );
  }

  Column _createUrlTextField(){
    _wasBuildTextField = true;

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
              await _manageProblemInternet();
            }
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

  Future<void> _manageProblemInternet() async {
    _connected = await InternetConnectionChecker().hasConnection;

    if (_connected){
      bool validUrl = _controllerUrl.text.startsWith("w") ? await Services.urlValidator(_controllerUrl.text) : await Services.launchURL(_controllerUrl.text);
      _setController();

      setState(() {
        errorHandler(validUrl);
      });
    } else if (!_connected && !_activeToast){
      _anyError = true;
      _activeToast = true;
      Services.showToastSemaphore(
          Colors.yellow[700],
          const Duration(milliseconds: 2500),
          Icons.wifi_off_outlined,
          "El dispositivo no tiene\n acceso a Internet",
          context,
          _height,
          _width,
          0.12,
          0.1,
          0.1
      );
      Services.notification();
      Future.delayed(const Duration(milliseconds: 2500), ()=> _activeToast = false);
    }
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

  Future<void> _loadPass() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _newPass = (prefs.getString('newPass'));
    });
  }
}