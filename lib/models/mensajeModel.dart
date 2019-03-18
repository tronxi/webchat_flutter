import 'dart:convert';
class MensajeModel{
  String nombre;
  String texto2;
  String fecha;

  MensajeModel({this.nombre, this.texto2, this.fecha});

  factory MensajeModel.fromJson(Map<String, dynamic> json) {
    return MensajeModel(
        nombre: json['nombre'],
        texto2: json['texto2'],
        fecha: json['fecha']
    );
  }
  static List<MensajeModel> parseDatos(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<MensajeModel>((json) => MensajeModel.fromJson(json)).toList();
  }
}