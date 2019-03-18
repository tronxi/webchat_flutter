import 'dart:convert';
import 'package:flutter/foundation.dart';
class Conversaciones_usuarioModel{
  String nombre;
  int id;
  String ultimaFecha;
  int estado;

  Conversaciones_usuarioModel({this.nombre, this.id, this.ultimaFecha, this.estado});

  factory Conversaciones_usuarioModel.fromJson(Map<String, dynamic> json) {
    return Conversaciones_usuarioModel(
      id: json['id'],
      nombre: json['nombre'],
      ultimaFecha: json['ultimaFecha'],
      estado: json['estado']
    );
  }
  static List<Conversaciones_usuarioModel> parseDatos(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Conversaciones_usuarioModel>((json) => Conversaciones_usuarioModel.fromJson(json)).toList();
  }
}