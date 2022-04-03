// @dart=2.9
import 'package:device_information/device_information.dart';
import 'package:flutter/material.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Url extends StatefulWidget {
  const Url({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UrlState();
}

enum SingingCharacterAccess { Portero, Reloj }
enum SingingCharacterSendData { Automatico, Manual }

class _UrlState extends State<Url>{
  final _controller = TextEditingController();
  bool _fieldEmpty = false;
  bool _invalidUrl = false;
  FocusNode _node;
  bool _focused = false;
  SingingCharacterAccess _characterAccess = SingingCharacterAccess.Portero;
  SingingCharacterSendData _characterSendData = SingingCharacterSendData.Automatico;
  bool _firstBuild = true;
  double _height;
  double _width;
  bool _isConected = true;
  bool _active = false;
  FToast _fToast;
  bool _anyError = false;

  String _platformVersion = 'Unknown',
      _modelName = "",
      _manufacturerName = "",
      _productName = "";

  @override
  void initState() {
    initPlatformState();
    _loadText();
    _node = FocusNode();
    _node.addListener(_handleFocusChange);
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

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail,
    // so we use a try/catch PlatformException.
    String platformVersion,
        modelName = '',
        manufacturer = '',
        productName = '';
    try {
      platformVersion = await DeviceInformation.platformVersion;
      modelName = await DeviceInformation.deviceModel;
      manufacturer = await DeviceInformation.deviceManufacturer;
      productName = await DeviceInformation.productName;
    } on PlatformException catch (e) {
      platformVersion = e.message;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = "Running on :$platformVersion";
      _modelName = modelName;
      _manufacturerName = manufacturer;
      _productName = productName;
    });
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
        leading: const Icon(
          Icons.settings,
          color: Colors.black,
        ),
        title: const Text(
          "Configuración",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[800],
      ),
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
                     Center(
                       child: Column(
                         children: <Widget>[
                           SizedBox(height: _height * 0.235,),
                           Image.asset(
                             "assets/Cujae.png",
                             width: _width * 0.83,
                             color: Colors.white.withOpacity(0.2),
                             colorBlendMode: BlendMode.modulate,
                           ),
                         ],
                       ),
                     ),
                    Column(
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
                            controller: _controller,
                            focusNode: _node,
                            decoration: InputDecoration(
                              errorText: _anyError ? showMessageError() : null,
                              labelText: 'Inserte la Url',
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
                            onSubmitted: (text) async {
                              bool data = _controller.text.startsWith("w") ? await _urlValidator() : await _launchURL();
                              _setController();
                              setState(() {
                                errorHandler(data);
                              });
                            },
                          ),
                        ),
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[800],
        onPressed: () async {
          bool data = _controller.text.startsWith("w") ? await _urlValidator() : await _launchURL();
          bool internet = await InternetConnectionChecker().hasConnection;

          setState(() {
              errorHandler(data);
              _isConected = internet;
          });

          if(!_invalidUrl && !_fieldEmpty && _controller.text != "" && _isConected) {
            Navigator.pushNamed(context, '/scanner', arguments: {
              'address': _controller.text,
              'mode': _characterAccess.name,
              'identifier': _manufacturerName + " " + _modelName + " " + _productName,
              'sendDataMode': _characterSendData.name
            });
          } else if(!_isConected && !_active){
            _active = true;
            _showToast();
            Future.delayed(const Duration(milliseconds: 2500), ()=> _active = false);
          }
        },
        child: const Icon(
          Icons.camera_enhance_outlined,
          color: Colors.black,
        ),
      ),
    );
  }

  void errorHandler(bool data){
    if(_controller.text.isEmpty) {
      _invalidUrl = false;
      _fieldEmpty = true;
    } else if(data){
      _fieldEmpty = false;
      _invalidUrl = true;
    }else{
      _invalidUrl = false;
      _fieldEmpty = false;
    }

    _anyError = _fieldEmpty || _invalidUrl;
  }

  String showMessageError(){
    String stringError;

    if(_fieldEmpty) {
      stringError = "Este campo no puede estar vacío";
    } else {
      stringError = "La URL no es válida";
    }

    return stringError;
  }

  Future<bool> _urlValidator() async {
    final ping = Ping(_controller.text, count: 1);
    PingData data = await ping.stream.first;

    return data.error?.error != null ? true : false;
  }

  Future<bool> _launchURL() async {
    var pattern = r'^((?:.|\n)*?)((http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?)';
    RegExp regExp = RegExp(pattern);
    bool result = regExp.hasMatch(_controller.text);

    return !result;
  }

  void _loadText() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _controller.text = (prefs.getString('urlSaved') ?? "");
    });
  }

  Future<void> _setController() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('urlSaved', _controller.text);
    });
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
        });
  }
}