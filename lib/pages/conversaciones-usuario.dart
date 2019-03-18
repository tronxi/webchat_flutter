import 'package:webchat_flutter/services/datosUsuario.dart';
import 'package:flutter/material.dart';
import 'package:webchat_flutter/services/conexionBD.dart' as conexion;
import 'package:webchat_flutter/pages/login.dart';
import 'package:webchat_flutter/models/conversaciones-usuarioModel.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:webchat_flutter/conexionIOManager/conexion_io_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webchat_flutter/services/conexionSocket.dart' as socket;
import 'package:webchat_flutter/pages/personas.dart';
import 'package:webchat_flutter/pages/chat.dart';
import 'package:toast/toast.dart';

class Conversaciones_usuario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Conversaciones-usuario"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Personas()));
                }),
            IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  _guardarPreferencias();
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Login()));
                })
          ],
        ),
        body: Center(child: Conversaciones_usuarioPage()));
  }

  _guardarPreferencias() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario', "");
    await prefs.setString('contrasena', "");
  }
}

class Conversaciones_usuarioPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Conversaciones_usuarioPageState();
  }
}

class Conversaciones_usuarioPageState
    extends State<Conversaciones_usuarioPage> {
  final user = DatosUsuario().getUser();
  SocketIO socketIO;
  Widget wd;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Conversaciones_usuarioPageState() {
    print("El token es "+ DatosUsuario().getToken());
    wd = construir();
  }

  Future<void> initPlatformState() async {
    socketIO =
        SocketIOManager().createSocketIO(socket.ConexionSocket.getUrl(), "/");
    socketIO.init();
    socketIO.connect();
    socketIO.sendMessage("connect", {});
    socketIO.subscribe("nuevo-mensaje", _onActualizarMensajes);
  }

  void _onActualizarMensajes(dynamic message) {
    setState(() {
      wd = construir();
    });
  }

  /*@override
  void dispose(){
    SocketIOManager().destroySocket(socketIO);
  }*/
  Future<List<Conversaciones_usuarioModel>> fetchDatos(
      http.Client client) async {
    final response = await conexion.conversaciones_usuario(user);
    return compute(Conversaciones_usuarioModel.parseDatos, response);
  }

  FutureBuilder<List<Conversaciones_usuarioModel>> construir() {
    return FutureBuilder<List<Conversaciones_usuarioModel>>(
        future: fetchDatos(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? ConversacionUsuarioLista(datos: snapshot.data)
              : Center(child: CircularProgressIndicator());
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: wd);
  }
}

class ConversacionUsuarioLista extends StatelessWidget {
  final List<Conversaciones_usuarioModel> datos;

  ConversacionUsuarioLista({Key key, this.datos}) : super(key: key);

  List<ConversacionesUsuarioItem> _buildContactList() {
    return datos.map((contact) => ConversacionesUsuarioItem(contact)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _buildContactList(),
    );
  }
}

class ConversacionesUsuarioItem extends StatelessWidget {
  Conversaciones_usuarioModel _conversacion;

  ConversacionesUsuarioItem(this._conversacion);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        trailing: _conversacion.estado != 0
            ? CircleAvatar(
                backgroundColor: Colors.lightGreen,
                child: Text(
                  _conversacion.estado.toString(),
                  style: TextStyle(color: Colors.white),
                ))
            : Text(""),
        title: Align(
          child: Text(
            _conversacion.nombre,
            style: TextStyle(fontSize: 20),
          ),
          alignment: Alignment.bottomLeft,
        ),
        onTap: () {
          DatosUsuario().setPersona(_conversacion.nombre);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Chat()));
        });
  }
}
