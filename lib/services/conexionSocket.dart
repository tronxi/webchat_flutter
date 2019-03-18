import  'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:webchat_flutter/conexionIOManager/conexion_io_manager.dart';
class ConexionSocket {
  //static const url = "http://192.168.0.5:8889";
  static const url = "http://raspberrytronxi.ddns.net:8889";
  static getUrl(){
    return url;
  }
}