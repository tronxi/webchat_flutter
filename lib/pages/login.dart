import 'package:flutter/material.dart';
import 'package:webchat_flutter/services/conexionBD.dart' as conexion;
import 'package:webchat_flutter/pages/registro.dart';
import 'package:webchat_flutter/services/datosUsuario.dart';
import 'package:webchat_flutter/pages/conversaciones-usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final TextEditingController controllerUsuario = new TextEditingController();
  final TextEditingController controllerContrasena = new TextEditingController();

  String usuario = "";
  String contrasena = "";
  String tokenG = "";
  LoginState() {
    _cargarPreferencias();
  }
  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token){
      tokenG = token;
    });
  }
  _cargarPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState((){
      usuario = prefs.getString('usuario') ?? "";
      contrasena = prefs.getString('contrasena') ?? "";
      if (usuario != "" && contrasena != "") {
        _onPressEnviar();
      }
    });
  }

  _guardarPreferencias() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario', usuario);
    await prefs.setString('contrasena', contrasena);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(
          appBar: AppBar(
            title: Text("webchat"),
          ),
          body: Center(
            child: Container(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(hintText: "Usuario"),
                    onChanged: (String value) {
                      _onChangedUsuario(value);
                    },
                    controller: controllerUsuario,
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(hintText: "Contraseña"),
                    onChanged: (String value) {
                      _onChangedContrasena(value);
                    },
                    controller: controllerContrasena,
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  SizedBox(
                      width: 200.0,
                      child: RaisedButton(
                        child: Text("Login"),
                        onPressed: _onPressEnviar,
                        color: Colors.lightBlue,
                      )),
                  Padding(padding: EdgeInsets.all(8.0)),
                  SizedBox(
                      width: 150.0,
                      child: RaisedButton(
                        child: Text("Registrarse"),
                        onPressed: _onPressRegistrarse,
                        color: Colors.grey,
                      )),
                ],
              ),
            ),
          ),
        ));
  }

  _onChangedUsuario(String value) {
    setState(() {
      usuario = value;
    });
  }

  _onChangedContrasena(String value) {
    setState(() {
      contrasena = value;
    });
  }

  _onPressEnviar() async {
    if (usuario != "" && contrasena != "") {
      _guardarPreferencias();
      var resultado = await conexion.login(usuario, contrasena);

      if (resultado == "\"ok\"") {
        DatosUsuario().setUser(usuario);
        DatosUsuario().setToken(tokenG);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => WillPopScope(
                    onWillPop: () => Future.value(false),
                    child: Conversaciones_usuario())));
      } else if (resultado == "\"passIncorrecta\"") {
        Toast.show(
            "Contraseña Incorrecta", context, gravity: Toast.CENTER);
      } else if (resultado == "\"noExiste\"") {
        Toast.show("El Usuario No existe", context, gravity: Toast.CENTER);
      } else {
        Toast.show("Error",context, gravity: Toast.CENTER);
      }
    } else {
      Toast.show("Introduce Todos los datos",context, gravity: Toast.CENTER);
    }
  }

  _onPressRegistrarse() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(
                appBar: AppBar(
                  title: Text("segunda pantalla"),
                ),
                body: Center(child: RegistroPage()))));
  }
}