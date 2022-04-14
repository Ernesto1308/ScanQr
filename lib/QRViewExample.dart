// @dart=2.9
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
import 'Services.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool _flashOn = false;
  bool _accepted = false;
  String _message;
  String _result;
  int _counter;
  double _width;
  double _height;
  bool _firstBuild = true;
  bool _connected = true;
  bool _active = false;
  Map _arguments = {};

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller?.resumeCamera();
    _arguments = ModalRoute.of(context).settings.arguments as Map;

    if (_firstBuild){
      _width = MediaQuery.of(context).size.width;
      _height = MediaQuery.of(context).size.height;
      _firstBuild = false;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Expanded(flex: 3, child: _buildQrView(context)),
          Expanded(flex: 1, child: _buildQrPanel()),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = _height * 0.25;

    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller){
    setState(() {
      this.controller = controller;
    });
    Timer firstTimer = Timer(const Duration(),(){});
    Timer secondTimer = Timer(const Duration(),(){});
    controller.scannedDataStream.listen((scanData) async {
      if(_result != scanData.code){
        if(firstTimer.isActive){
          firstTimer.cancel();
        }

        if(secondTimer.isActive){
          secondTimer.cancel();
        }

        _counter = 0;

        setState(() {
          _result = scanData.code;
          _message = _result;

          firstTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            _counter = timer.tick;
            if(_counter == 5) {
              timer.cancel();
            }
          });
        });
      } else {
        if(_counter == 5) {
          if(secondTimer.isActive){
            secondTimer.cancel();
          }

          _counter = 0;

          setState(() {
            _message = _result;

            secondTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              _counter = timer.tick;
              if(_counter == 5) {
                timer.cancel();
              }
            });
          });
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  Widget _buildQrPanel() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _message == null ?
          const Expanded(
            child: Center(
              child: Text('Escanee un código',
                style: TextStyle(fontSize: 20 , color: Colors.white),
              ),
            )
          )
              : _arguments['sendDataMode'] != "Manual" ? _buildAutomaticPanel() : _buildRowDataScanned(),
          const Divider(
              color: Colors.white,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              IconButton(
                splashRadius: 23,
                onPressed: () async {
                  Navigator.pop(context,'/url');
                },
                icon: const Icon(Icons.settings, color: Colors.white,),
              ),

              IconButton(
                splashRadius: 23,
                onPressed: () async {
                  await controller?.pauseCamera();
                },
                icon: const Icon(Icons.pause, color: Colors.white,),
              ),
              IconButton(
                splashRadius: 23,
                onPressed: () async {
                  await controller?.resumeCamera();
                },
                icon: const Icon(Icons.play_arrow, color: Colors.white,),
              ),

              IconButton(
                alignment: Alignment.center,
                splashRadius: 23,
                onPressed: () async {
                  await controller?.toggleFlash();
                  setState(() {
                    _flashOn = !_flashOn;
                  });
                },
                icon: _flashOn ? const Icon(Icons.wb_incandescent_sharp, color: Colors.amberAccent,) :
                const Icon(Icons.wb_incandescent_outlined, color: Colors.white,),
              ),
            ],
          ),
          //const SizedBox(height: 10,),
        ],
    );
  }

  Widget _buildRowDataScanned(){
    Vibration.vibrate(duration: 150);

    return Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Container(
            height: _height * 0.15,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(
                _message,
                style: const TextStyle(
                    fontSize: 20 ,
                    color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Expanded(flex: 1,
          child: IconButton(
            splashRadius: 25,
            onPressed: () async {
              await callPost();
            },
            icon: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> _createPost(String address, String token) async {
    try {
      final response = await http.post(
        Uri.parse(address),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'token': token,
        }),
      );

      int value = jsonDecode(response.body)['_arguments'];
      return value != 0 && value != null;
    } catch (e){
      throw Exception('Failed to send data');
    }
  }

  Widget _buildAutomaticPanel(){
    callPost();
    
    return const Expanded(
        child: Center(
          child: Text('Escanee un código',
            style: TextStyle(fontSize: 20 , color: Colors.white),
          ),
        )
    );
  }

  Future<void> callPost() async {
    _connected = await InternetConnectionChecker().hasConnection;

    if (_connected){
      Map map = {
        'qr': _message,
        'mode': _arguments['mode'],
        'idDevice': _arguments['idDevice'],
      };
      String token = await Services.createJsonWebToken(map, _arguments['encryptionPass']);
      _accepted = await _createPost(_arguments['address'], token);
      Services.verifyJsonWebToken(token, _arguments['encryptionPass']);

      if (_accepted){
        Services.showToastSemaphore(
            Colors.greenAccent,
            const Duration(milliseconds: 2500),
            Icons.check,
            "Acceso Permitido",
            context,
            _height,
            _width,
            0.27,
            0.17,
            0.17
        );
      } else {
        Services.showToastSemaphore(
            Colors.red,
            const Duration(milliseconds: 2500),
            Icons.warning_amber_outlined,
            "Acceso Denegado",
            context,
            _height,
            _width,
            0.27,
            0.17,
            0.17
        );
      }

      setState(() {
        _message = null;
      });
      Services.notification();
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
          0.27,
          0.2,
          0.2
      );
      Services.notification();
      Future.delayed(const Duration(milliseconds: 2500), ()=> _active = false);
    }
  }
}