// @dart=2.9
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Configuration.dart';
import 'Services.dart';

class MyDialogContent extends StatefulWidget {
  MyDialogContent({
    Key key,
    @required this.title,
    @required this.secondButton,
    @required this.height,
    @required this.width,
    this.currentEncryptionPass
  }): super(key: key);

  String title;
  String secondButton;
  final double height;
  final double width;
  final String currentEncryptionPass;

  @override
  _MyDialogContentState createState() => _MyDialogContentState();
}

class _MyDialogContentState extends State<MyDialogContent> {
  bool _isObscure = true;
  bool _focused = false;
  bool _noError = true;
  bool _insertDeveloperPass = false;
  bool _insertEncryptionPass = false;
  bool _changeEncryptionPass = false;
  final _formKey = GlobalKey<FormState>();
  final _developerPassword = "l3ktorqr*cuj@e";
  String _currentEncryptionPass;
  final _controller = TextEditingController();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.title == 'Contraseña actual de encriptación'){
      _insertEncryptionPass = true;
    } else if (widget.secondButton == 'Aceptar'){
      _insertDeveloperPass = true;
    } else {
      _changeEncryptionPass = true;
    }

    return _getContent();
  }

  AlertDialog _getContent(){
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            SizedBox(
              height: widget.height * 0.01,
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                  obscureText: _isObscure,
                  cursorColor: _noError ? Colors.green[600] : Colors.red,
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: !_changeEncryptionPass ? "Contraseña" : "Nueva contraseña",
                    hintStyle: _insertDeveloperPass ? Services.setLabelStyleInsertPass(_focused) : Services.setLabelStyle(_focused, !_noError),
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
                    suffixIcon: IconButton(
                        splashRadius: 23,
                        icon: Icon(
                          _isObscure ? Icons.visibility : Icons.visibility_off,
                          color: _manageEyeColor(),
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        }
                    ),
                  ),
                  validator: (text){
                    String result;

                    if (text.isEmpty){
                      result = "Este campo no puede estar vacío";
                    } else if (text == _currentEncryptionPass){
                      result = "Por favor introduzca una contraseña\ndiferentre a la actual";
                    }

                    return result;
                  },
                  onFieldSubmitted: (text){
                    setState(() {
                      _focused = false;
                      if (_changeEncryptionPass) _noError = _formKey.currentState.validate();
                    });
                  },
                  onTap: (){
                    setState(() {
                      _focused = true;
                    });
                  },
                ),
            )
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'Cancelar',
            style: TextStyle(
                color: Colors.black
            ),
          ),
          onPressed: () {
            _controller.clear();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            widget.secondButton,
            style: const TextStyle(
                color: Colors.black
            ),
          ),
          onPressed: () async {
            if (_insertDeveloperPass){
              await _setControllerCurrentPass();
              if (_controller.text == _developerPassword){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const Configuration()
                    )
                );
              } else {
                _controller.clear();
                Navigator.of(context).pop();
                Services.showToastSystem(
                    Colors.grey[350],
                    const Duration(milliseconds: 2500),
                    "Contraseña incorrecta",
                    context,
                    widget.height,
                    widget.width,
                    0.1,
                    0.1,
                    0.1
                );
                Services.notification();
              }
            } else if (_changeEncryptionPass){
              await _loadCurrentPass();
              setState(() {
                _noError = _formKey.currentState.validate();
              });
              if (_noError){
                await _setControllerPass();
                _controller.clear();
                Navigator.of(context).pop();
                Services.showToastSystem(
                    Colors.grey[300],
                    const Duration(milliseconds: 2500),
                    "Contraseña cambiada exitosamente",
                    context,
                    widget.height,
                    widget.width,
                    0.1,
                    0.1,
                    0.1
                );
                Services.notification();
              }
            } else {
              await _loadCurrentPass();
              if (_controller.text == _currentEncryptionPass){
                setState(() {
                  widget.secondButton = 'Cambiar';
                  widget.title = 'Cambiar de contraseña de encriptación';
                  _controller.clear();
                });
              } else {
                Navigator.of(context).pop();
                _controller.clear();
                Services.showToastSystem(
                    Colors.grey[350],
                    const Duration(milliseconds: 2500),
                    "Contraseña incorrecta",
                    context,
                    widget.height,
                    widget.width,
                    0.1,
                    0.1,
                    0.1
                );
                Services.notification();
              }
            }
          },
        ),
      ],
    );
  }

  Color _manageEyeColor(){
    Color finalColor;

    if(_insertDeveloperPass){
      finalColor = _focused ? Colors.green[600] : Colors.green[900];
    } else {
      if(_noError){
        finalColor = _focused ? Colors.green[600] : Colors.green[900];
      } else {
        finalColor = Colors.red;
      }
    }

    return finalColor;
  }

  Future<void> _setControllerPass() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('newPass', _controller.text);
    });
  }

  Future<void> _loadCurrentPass() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _currentEncryptionPass = (prefs.getString('currentEncryptionPass'));
    });
  }

  Future<void> _setControllerCurrentPass() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('currentEncryptionPass', widget.currentEncryptionPass);
    });
  }
}