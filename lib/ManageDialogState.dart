// @dart=2.9
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Configuration.dart';
import 'Services.dart';

class MyDialogContent extends StatefulWidget {
  const MyDialogContent({
    Key key,
    @required this.title,
    @required this.subtitle,
    @required this.secondButton,
    @required this.height,
    @required this.width
  }): super(key: key);

  final String title;
  final String subtitle;
  final String secondButton;
  final double height;
  final double width;

  @override
  _MyDialogContentState createState() => _MyDialogContentState();
}

class _MyDialogContentState extends State<MyDialogContent> {
  bool _isObscure = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String _developerPassword = "1234";
  final _controller = TextEditingController();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _getContent();
  }

  AlertDialog _getContent(){
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(widget.subtitle),
            Form(
              key: _formKey,
              child: TextFormField(
                obscureText: _isObscure,
                cursorColor: Colors.green[600],
                controller: _controller,
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
                  suffixIcon: IconButton(
                      splashRadius: 23,
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                        color: Colors.green[600],
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      }
                  ),
                ),
                validator: (text){
                  return text.isEmpty ? "Este campo no puede estar vacío" : null;
                },
                onFieldSubmitted: (text){
                  widget.secondButton == "Aceptar" ? null : _formKey.currentState.validate();
                },
              ),
            )
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
            _controller.clear();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            widget.secondButton,
            style: TextStyle(
                color: Colors.green[900]
            ),
          ),
          onPressed: () async {
            if (widget.secondButton == 'Aceptar'){
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
                    Colors.grey[300],
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
            } else {
              if (_formKey.currentState.validate()){
                await _setControllerPass();
                _controller.clear();
                Navigator.of(context).pop();
                Services.showToastSystem(
                    Colors.grey[300],
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
            }
          },
        ),
      ],
    );
  }

  Future<void> _setControllerPass() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('newPass', _controller.text);
    });
  }
}