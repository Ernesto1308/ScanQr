// @dart=2.9
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Configuration.dart';
import 'Services.dart';

class MyDialogContent extends StatefulWidget {
  const MyDialogContent({
    Key key,
    @required this.title,
    @required this.secondButton,
    @required this.height,
    @required this.width
  }): super(key: key);

  final String title;
  final String secondButton;
  final double height;
  final double width;

  @override
  _MyDialogContentState createState() => _MyDialogContentState();
}

class _MyDialogContentState extends State<MyDialogContent> {
  bool _isObscure = true;
  bool _focused = false;
  bool _isNotEmpty = true;
  bool _insertPassDialog = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String _developerPassword = "1234";
  final _controller = TextEditingController();


  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _insertPassDialog = widget.secondButton == 'Aceptar';

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
                  cursorColor: _isNotEmpty ? Colors.green[600] : Colors.red,
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: _insertPassDialog ? "Inserte la contraseña" : "Nueva contraseña",
                    hintStyle: _insertPassDialog ? Services.setLabelStyleInsertPass(_focused) : Services.setLabelStyle(_focused, !_isNotEmpty),
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
                    return text.isEmpty ? "Este campo no puede estar vacío" : null;
                  },
                  onFieldSubmitted: (text){
                    setState(() {
                      _focused = false;
                      if (!_insertPassDialog) _isNotEmpty = _formKey.currentState.validate();
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
            if (_insertPassDialog){
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
            } else {
              setState(() {
                _isNotEmpty = _formKey.currentState.validate();
              });
              if (_isNotEmpty){
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

  Color _manageEyeColor(){
    Color finalColor;

    if(_insertPassDialog){
      finalColor = _focused ? Colors.green[600] : Colors.green[900];
    } else {
      if(_isNotEmpty){
        finalColor = _focused ? Colors.green[600] : Colors.green[900];
      } else {
        finalColor = Colors.red;
      }
    }

    return finalColor;
  }
}