// @dart=2.9
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:scanqr/ManageDialogState.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Services.dart';

class Url extends StatefulWidget {
  const Url({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UrlState();
}

enum SingingCharacterAccess { Portero, Reloj }
enum SingingCharacterSendData { Automatico, Manual }

class _UrlState extends State<Url>{
  SingingCharacterAccess _characterAccess = SingingCharacterAccess.Portero;
  SingingCharacterSendData _characterSendData = SingingCharacterSendData.Automatico;
  bool _firstBuild = true;
  double _height;
  double _width;
  bool _connected = true;
  bool _activeToast = false;
  final String _defaultEncryptionPass = '3rN35t0';
  String _newPass;
  String _url;
  String _idDevice;
  Map _arguments = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_firstBuild){
      _height = MediaQuery.of(context).size.height;
      _width = MediaQuery.of(context).size.width;
      _arguments = ModalRoute.of(context).settings.arguments as Map;

      if (_arguments != null){
        if (_arguments['before'] == "role") {
          setState(() {
            _idDevice = _arguments['idDevice'];
          });
          _setControllerIdDevice();
        }else if (_arguments['before'] == "configuration") {
          if (_arguments['url'] != null){
            setState(() {
              _url = _arguments['url'];
            });
            _setControllerUrl();
          }

          if (_arguments['newEncryptionPass'] != null){
            setState(() {
              _newPass = _arguments['newEncryptionPass'];
            });
            _setControllerPass();
          }
        }
      }

      _loadUrl();
      _loadPass();
      _loadIdDevice();
      _firstBuild = false;
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            splashRadius: 23,
            icon: const Icon(
              Icons.settings,
              color: Colors.black,
            ),
            onPressed: () async {
              await _showDialogInsertPass();
            },
          ),
          title: const Text(
            "Configuración",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.green[800],
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              scale: 2.1,
              opacity: 0.2,
              image: AssetImage('assets/Cujae.png'),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget> [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text(
                        "Modo de acceso",
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.black
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(3),
                        shape: BoxShape.rectangle,
                        border: Border.all(
                          color: Colors.green[900],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            hoverColor: Colors.green[500],
                            title: const Text('Portero'),
                            onTap: (){
                              setState(() {
                                _characterAccess = SingingCharacterAccess.Portero;
                              });
                              },
                            leading: Radio<SingingCharacterAccess>(
                              activeColor: Colors.green[900],
                              value: SingingCharacterAccess.Portero,
                              groupValue: _characterAccess,
                              onChanged: (SingingCharacterAccess value) {
                                setState(() {
                                  _characterAccess = value;
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text('Reloj'),
                            onTap: (){
                              setState(() {
                                _characterAccess = SingingCharacterAccess.Reloj;
                              });
                            },
                            leading: Radio<SingingCharacterAccess>(
                              activeColor: Colors.green[900],
                              value: SingingCharacterAccess.Reloj,
                              groupValue: _characterAccess,
                              onChanged: (SingingCharacterAccess value) {
                                setState(() {
                                  _characterAccess = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget> [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Text(
                        "Envío de datos",
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.black
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(3),
                        shape: BoxShape.rectangle,
                        border: Border.all(
                          color: Colors.green[900],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: const Text('Automático'),
                            onTap: (){
                              setState(() {
                                _characterSendData = SingingCharacterSendData.Automatico;
                              });
                            },
                            leading: Radio<SingingCharacterSendData>(
                              activeColor: Colors.green[900],
                              value: SingingCharacterSendData.Automatico,
                              groupValue: _characterSendData,
                              onChanged: (SingingCharacterSendData value) {
                                setState(() {
                                  _characterSendData = value;
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text('Manual'),
                            onTap: (){
                              setState(() {
                                _characterSendData = SingingCharacterSendData.Manual;
                              });
                            },
                            leading: Radio<SingingCharacterSendData>(
                              activeColor: Colors.green[900],
                              value: SingingCharacterSendData.Manual,
                              groupValue: _characterSendData,
                              onChanged: (SingingCharacterSendData value) {
                                setState(() {
                                  _characterSendData = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green[800],
          onPressed: () async {
            _connected = await InternetConnectionChecker().hasConnection;

            if(_connected && _url != "" && _url != null) {
              bool activeCredential = await Services.credentialVerifier(_idDevice, _url, _newPass ?? _defaultEncryptionPass);

              if(activeCredential){
                Navigator.pushNamed(
                    context,
                    '/scanner',
                    arguments: {
                      'address': _url,
                      'mode': _characterAccess.name,
                      'sendDataMode': _characterSendData.name,
                      'encryptionPass': _newPass ?? _defaultEncryptionPass,
                      'idDevice': _idDevice
                    }
                );
              } else if (!_activeToast){
                _activeToast = true;
                Services.showToastSystem(
                    Colors.grey[350],
                    const Duration(milliseconds: 2500),
                    "Su credencial ha sido desactivada",
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
            } else if(!_connected && !_activeToast){
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
            } else if (!_activeToast && (_url == null || _url == "")){
              _activeToast = true;
              Services.showToastSystem(
                  Colors.grey[350],
                  const Duration(milliseconds: 2500),
                  "Es necesario definir el servidor\nen la configiración avanzada",
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
          },
          child: const Icon(
            Icons.camera_enhance_outlined,
            color: Colors.black,
          ),
        ),
    );
  }

  Future<void> _showDialogInsertPass() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return MyDialogContent(
          height: _height,
          width: _width,
          secondButton: 'Aceptar',
          title: 'Contraseña',
          currentPass: _newPass ?? _defaultEncryptionPass,
        );
      },
    );
  }

  Future<void> _loadIdDevice() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _idDevice = (prefs.getString('idDevice'));
    });
  }

  Future<void> _setControllerIdDevice() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('idDevice', _idDevice);
    });
  }

  Future<void> _loadUrl() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _url = (prefs.getString('url'));
    });
  }

  Future<void> _setControllerUrl() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('url', _url);
    });
  }

  Future<void> _loadPass() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _newPass = (prefs.getString('newPass'));
    });
  }

  Future<void> _setControllerPass() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('newPass', _newPass);
    });
  }
}
