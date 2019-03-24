import 'package:flutter/material.dart';
import 'package:webchat_flutter/services/datosUsuario.dart';
import 'package:webchat_flutter/services/conexionBD.dart' as conexion;
import 'package:webchat_flutter/services/conexionSocket.dart' as socket;
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:webchat_flutter/conexionIOManager/conexion_io_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:webchat_flutter/models/mensajeModel.dart';
import 'package:flutter/foundation.dart';
import 'package:webchat_flutter/pages/conversaciones-usuario.dart';

ScrollController _scrollController = new ScrollController();
bool primeraVez = true;

class Chat extends StatelessWidget {
  final TextEditingController controllerMensaje = new TextEditingController();
  String mensaje;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => WillPopScope(
                      onWillPop: () => Future.value(false),
                      child: Conversaciones_usuario())));
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(DatosUsuario().getPersona()),
          ),
          body: Container(
              child: Column(
            children: <Widget>[
              Flexible(child: ChatPage()),
              Divider(
                height: 1.0,
              ),
              Container(
                  padding: new EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: TextField(
                            controller: controllerMensaje,
                            onChanged: (String value) {
                              mensaje = value;
                            },
                            decoration: new InputDecoration.collapsed(
                                hintText: "Enviar mensaje")),
                      ),
                      Container(
                          child: IconButton(
                              icon: Icon(Icons.send),
                              onPressed: _enviarMensaje))
                    ],
                  ))
            ],
          )),
        ));
  }

  _enviarMensaje() async {
    if (mensaje != "" && mensaje != null) {
      String mensajeEnv = mensaje;
      controllerMensaje.text = "";
      this.mensaje = "";
      var resultado = await conexion.enviarMensajes(
          DatosUsuario().getUser(), DatosUsuario().getId(), mensajeEnv);
    }
  }
}

class ChatPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ChatPageState();
  }
}

class ChatPageState extends State<ChatPage> {
  bool mostrar = false;
  final user = DatosUsuario().getUser();
  final persona = DatosUsuario().getPersona();
  SocketIO socketIO;
  String id;

  Widget listaMensajes;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    Map data = {'id': id};
    var body = json.encode(data);
    socketIO.sendMessage("salir", body);
  }

  Future<void> initPlatformState() async {
    final response = await conexion.crearConversacion(user, persona);
    id = response;
    DatosUsuario().setId(id);
    socketIO =
        SocketIOManager().createSocketIO(socket.ConexionSocket.getUrl(), "/");
    socketIO.init();
    socketIO.connect();
    socketIO.sendMessage("connect", {});
    Map data = {'id': id};
    var body = json.encode(data);
    socketIO.sendMessage("union", body);
    socketIO.subscribe("actualizar-mensajes", _onActualizarMensajes);
    setState(() {
      listaMensajes = construir();
    });
  }

  void _onActualizarMensajes(dynamic message) {
    setState(() {
      listaMensajes = construir();
      _scrollController.animateTo(0.0,
          curve: Curves.easeOut, duration: const Duration(milliseconds: 10));
    });
  }

  Future<List<MensajeModel>> fetchDatos(http.Client client) async {
    final response = await conexion.mostrarMensajes(user, id);
    return compute(MensajeModel.parseDatos, response);
  }

  FutureBuilder<List<MensajeModel>> construir() {
    return FutureBuilder<List<MensajeModel>>(
        future: fetchDatos(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? MensajeLista(datos: snapshot.data)
              : Center(child: CircularProgressIndicator());
        });
  }

  @override
  Widget build(BuildContext context) {
    return listaMensajes;
  }
}

class MensajeLista extends StatelessWidget {
  final List<MensajeModel> datos;

  MensajeLista({Key key, this.datos}) : super(key: key);

  List<MensajeItem> _buildContactList() {
    return datos.reversed.map((contact) => MensajeItem(contact)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: new EdgeInsets.all(8.0),
      reverse: true,
      controller: _scrollController,
      children: _buildContactList(),
    );
  }
}

class MensajeItem extends StatelessWidget {
  MensajeModel _mensaje;

  MensajeItem(this._mensaje);

  @override
  Widget build(BuildContext context) {
    Alignment al;
    Color color;
    bool propio;
    if (_mensaje.nombre == DatosUsuario().getUser()) {
      al = Alignment.bottomRight;
      color = Color(0xffDFFFA9);
      propio = true;
    } else {
      al = Alignment.bottomLeft;
      color = Color(0xffCAFF70);
      propio = false;
    }
    return Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
        color: color,
        child: ListTile(
          leading: propio
              ? Text(_mensaje.fecha,
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic))
              : Text(""),
          title: Align(
            child: Text(
              _mensaje.nombre,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            alignment: al,
          ),
          subtitle: Align(
            child: Text(
              _mensaje.texto2,
              style: TextStyle(fontSize: 16),
            ),
            alignment: al,
          ),
          trailing: propio == false
              ? Text(_mensaje.fecha,
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic))
              : Text(""),
        ));
  }
}
