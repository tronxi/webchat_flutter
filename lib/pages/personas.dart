import 'package:flutter/material.dart';
import 'package:webchat_flutter/services/datosUsuario.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:webchat_flutter/services/conexionBD.dart' as conexion;
import 'package:webchat_flutter/models/personasModel.dart';
import 'package:flutter/foundation.dart';
import  'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:webchat_flutter/conexionIOManager/conexion_io_manager.dart';
import 'package:webchat_flutter/services/conexionSocket.dart' as socket;
import 'package:webchat_flutter/pages/chat.dart';


class Personas extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("personas"),
      ),
      body: PersonasPage(),
    );
  }
}

class PersonasPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return PersonasPageState();
  }
}

class PersonasPageState extends State<PersonasPage>{
  final user = DatosUsuario().getUser();
  SocketIO socketIO;
  Widget wd;
  @override
  PersonasPageState(){
    wd = construir();
  }
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }
  Future<void> initPlatformState() async {
    //SocketIOManager().destroyAllSocket();
    socketIO = SocketIOManager().createSocketIO(socket.ConexionSocket.getUrl(), "/");
    socketIO.init();
    socketIO.connect();
    socketIO.sendMessage("connect", {});
    socketIO.subscribe("nuevo-usuario",_onNuevoUsuario);

  }
  /*@override
  void dispose(){
    SocketIOManager().destroySocket(socketIO);
  }*/
  void _onNuevoUsuario(dynamic message) {
    setState((){
      wd = construir();
    });
  }

  Widget build(BuildContext context) {
    return Container(
        child: wd
    );
  }
  Future<List<PersonasModel>> fetchDatos(http.Client client) async {
    final response = await conexion.personas(user);
    return compute(PersonasModel.parseDatos, response);
  }
  FutureBuilder<List<PersonasModel>> construir() {
    return FutureBuilder<List<PersonasModel>>(
        future: fetchDatos(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? PersonasLista(datos: snapshot.data)
              : Center(child: CircularProgressIndicator());
        });
  }
}

class PersonasLista extends StatelessWidget {
  final List<PersonasModel> datos;

  PersonasLista({Key key, this.datos}) : super(key: key);

  List<PersonasItem>_buildContactList(){
    return datos.map((contact) => PersonasItem(contact)
    ).toList();
  }
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _buildContactList(),
    );
  }
}

class PersonasItem extends StatelessWidget{
  PersonasModel _conversacion;
  PersonasItem(this._conversacion);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
          child: Text(_conversacion.nombre[0].toUpperCase())
      ),
      title: Align(
        child: Text(_conversacion.nombre,
          style: TextStyle(
              fontSize: 20
          ),),
        alignment: Alignment.bottomLeft,
      ),
        onTap: (){
          DatosUsuario().setPersona(_conversacion.nombre);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Chat()));
        }
    );
  }
}