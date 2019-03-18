import 'package:flutter/material.dart';
import 'package:webchat_flutter/services/conexionBD.dart' as conexion;
import 'package:webchat_flutter/services/conexionSocket.dart';
import 'package:toast/toast.dart';

class RegistroPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return RegistroPageState();
  }
}

class RegistroPageState extends State<RegistroPage>{
  final TextEditingController controllerUsuario= new TextEditingController();
  final TextEditingController controllerContrasena = new TextEditingController();

  String usuario = "";
  String contrasena = "";
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(hintText: "Usuario"),
            onChanged: (String value){
              _onChangedUsuario(value);
            },
            controller: controllerUsuario,
          ),
          Padding(padding: EdgeInsets.all(8.0)),
          TextField(
            obscureText: true,
            decoration: InputDecoration(hintText: "Contraseña"),
            onChanged: (String value){
              _onChangedContrasena(value);
            },
            controller: controllerContrasena,
          ),
          Padding(padding: EdgeInsets.all(8.0)),
          SizedBox(
              width: 150.0,
              child: RaisedButton(
                child: Text("Registrarse"),
                onPressed: _onPressRegistrarse,
                color: Colors.grey,
              )
          ),
        ],
      ),
    );
  }
  _onChangedUsuario(String value){
    setState((){
      usuario = value;
    });
  }

  _onChangedContrasena(String value){
    setState((){
      contrasena = value;
    });
  }

  _onPressRegistrarse() async {
    if(usuario != "" && contrasena != ""){
      print("bien");
      var resultado = await conexion.registro(usuario, contrasena);
      if(resultado == "\"ok\""){
        Navigator.of(context).pop();
      }else{
        controllerContrasena.text = "";
        controllerUsuario.text = "";
        Toast.show("Datos Incorrectos",context, gravity: Toast.CENTER);
      }
    }
    else{
      Toast.show("Introduce Todos los datos",context, gravity: Toast.CENTER);
    }
  }
}