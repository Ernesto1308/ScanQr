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
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  FToast _fToast;
  FToast _fToastNoInternet;
  double _width;
  double _height;
  bool _firstBuild = true;
  bool _isConected = true;
  bool _active = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  void initState() {
    super.initState();
    _fToast = FToast();
    _fToast.init(context);
    _fToastNoInternet = FToast();
    _fToastNoInternet.init(context);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    controller?.resumeCamera();
    Map data = {};
    data = ModalRoute.of(context)?.settings?.arguments as Map;

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
          Expanded(flex: 1, child: _buildQrPanel(data)),
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

  Widget _buildQrPanel(Map data) {
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
              : data['sendDataMode'] != "Manual" ? _buildAutomaticPanel(data) : _buildRowDataScanned(data),
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

  Widget _buildRowDataScanned(Map data){
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
              bool internet = await InternetConnectionChecker().hasConnection;

              setState(() {
                _isConected = internet;
              });

              if (_isConected){
                await callPost(data);
              } else if(!_isConected && !_active){
                _active = true;
                _showToastNoInternet();
                Future.delayed(const Duration(milliseconds: 2500), ()=> _active = false);
              }

              setState(() {
                FlutterRingtonePlayer.play(
                    android: AndroidSounds.notification,
                    ios: IosSounds.glass,
                    looping: false,
                    volume: 0.1,
                    asAlarm: false
                );
              });
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

  Future<bool> _createPost(String address, String mode) async {
    try {
      final response = await http.post(
        Uri.parse(address),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'qr': _message,
          'mode': mode,
        }),
      );

      int value = jsonDecode(response.body)['data'];
      return value != 0 && value != null;
    } catch (e){
      throw Exception('Failed to send data');
    }
  }

  Widget _buildAutomaticPanel(Map data){
    Vibration.vibrate(duration: 200);
    callPost(data);
    
    return const Expanded(
        child: Center(
          child: Text('Escanee un código',
            style: TextStyle(fontSize: 20 , color: Colors.white),
          ),
        )
    );
  }

  Future<void> callPost(Map data) async {
    bool internet = await InternetConnectionChecker().hasConnection;

    if (internet){
      _accepted = await _createPost(data['address'],data['mode']);
      _showToast();
      _message = null;
    } else if(!internet && !_active){
      _active = true;
      _showToastNoInternet();
      Future.delayed(const Duration(milliseconds: 2500), ()=> _active = false);
    }
  }

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: _accepted ? Colors.greenAccent : Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _accepted ?
        [
          const Icon(Icons.check),
          SizedBox(width: _width * 0.03,),
          const Text("Acceso Permitido"),
        ] :
        [
          const Icon(Icons.warning_amber_outlined),
          SizedBox(width: _width * 0.03,),
          const Text("Acceso Denegado"),
        ],
      ),
    );

    // Custom Toast Position
    _fToast.showToast(
        child: toast,
        toastDuration: const Duration(milliseconds: 1500),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            bottom: _height * 0.27,
            left: _width * 0.17,
            right: _width * 0.17,
          );
        });
  }

  _showToastNoInternet() {
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
    _fToastNoInternet.showToast(
        child: toast,
        toastDuration: const Duration(milliseconds: 2500),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            bottom: _height * 0.27,
            left: _width * 0.2,
            right: _width * 0.2,
          );
        });
  }
}