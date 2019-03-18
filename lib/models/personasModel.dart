import 'dart:convert';

class PersonasModel{
  String nombre;

  PersonasModel({this.nombre});

  factory PersonasModel.fromJson(Map<String, dynamic> json) {
    return PersonasModel(
        nombre: json['nombre']
    );
  }
  static List<PersonasModel> parseDatos(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<PersonasModel>((json) => PersonasModel.fromJson(json)).toList();
  }
}