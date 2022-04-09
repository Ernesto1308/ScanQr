// @dart=2.9
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:scanqr/Configuration.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _isConected = true;
  bool _activeToast = false;
  FToast _fToast;
  String _defaultEncryptionPass = '3rN35t0';
  String _newPass;

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
    _fToast = FToast();
    _fToast.init(context);
    Map data = ModalRoute.of(context).settings.arguments as Map;

    if (_firstBuild){
      _height = MediaQuery.of(context).size.height;
      _width = MediaQuery.of(context).size.width;
      _firstBuild = false;
    }

    if (data['before'] == "configuration" && data['newEncryptionPass'] != null) {
      setState(() {
        _newPass = data['newEncryptionPass'];
      });
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.black,
          ),
            onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const Configuration()
                    )
                );
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
            bool internet = await InternetConnectionChecker().hasConnection;

            setState(() {
                _isConected = internet;
            });

            if(_isConected) {
              Navigator.pushNamed(context, '/scanner', arguments: {
                'address': "algo",
                'mode': _characterAccess.name,
                'sendDataMode': _characterSendData.name
              });
            } else if(!_isConected && !_activeToast){
              _activeToast = true;
              _showToast();
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

  Future<String> _loadUrl() async {
    final prefs = await SharedPreferences.getInstance();

    return (prefs.getString('urlSaved') ?? "");
  }

  Future<void> _setController(String url) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('urlSaved', url);
    });
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
            bottom: _height * 0.13,
            left: _width * 0.2,
            right: _width * 0.2,
          );
        }
    );
  }
}