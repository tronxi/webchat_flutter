import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

  //const url = 'http://raspberrytronxi.ddns.net/webchat_server_node';
  const url = 'http://192.168.1.5/webchat_server_node';

Future<String> login(usuario, contrasena) async {
  Map data = {'usuario': usuario, 'pass' : contrasena};
  var body = json.encode(data);
  final response = await http
      .post(url + '/login', headers: {"Content-Type": "application/json"}, body: body);
  return response.body;
}
Future<String> token(usuario, token) async {
  Map data = {'usuario': usuario, 'token' : token};
  var body = json.encode(data);
  final response = await http
      .post(url + '/token', headers: {"Content-Type": "application/json"}, body: body);
  return response.body;
}

Future<String> registro(usuario, contrasena) async {
  Map data = {'usuario': usuario, 'pass' : contrasena};
  var body = json.encode(data);
  final response = await http
      .post(url + '/registro', headers: {"Content-Type": "application/json"}, body: body);
  return response.body;
}

Future<String> conversaciones_usuario(usuario) async {
  Map data = {'usuario': usuario};
  var body = json.encode(data);
  final response = await http
      .post(url + '/conversacionUsuario', headers: {"Content-Type": "application/json"}, body: body);
  return response.body;
}

Future<String> personas(usuario) async {
  Map data = {'usuario': usuario};
  var body = json.encode(data);
  final response = await http
      .post(url + '/personas', headers: {"Content-Type": "application/json"}, body: body);
  return response.body;
}

Future<String> crearConversacion(usuario, persona) async {
  Map data = {'usuario': usuario, 'persona': persona};
  var body = json.encode(data);
  final response = await http
      .post(url + '/crearConversacion', headers: {"Content-Type": "application/json"}, body: body);
  return response.body;
}

Future<String> mostrarMensajes(usuario, id) async {
  Map data = {'usuario': usuario, 'id': id};
  var body = json.encode(data);
  final response = await http
      .post(url + '/mostrarMensajes', headers: {"Content-Type": "application/json"}, body: body);
  return response.body;
}

Future<String> enviarMensajes(usuario, id, mensaje) async {
  Map data = {'usuario': usuario, 'id': id, 'mensaje': mensaje};
  var body = json.encode(data);
  final response = await http
      .post(url + '/enviarMensaje', headers: {"Content-Type": "application/json"}, body: body);
  return response.body;
}