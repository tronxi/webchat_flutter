class DatosUsuario {
  DatosUsuario._privateConstructor();
  static final DatosUsuario _instance = DatosUsuario._privateConstructor();
  String _user;
  String _persona;
  String _id;
  String _token;
  factory DatosUsuario(){
    return _instance;
  }
  getPersona(){
    return _persona;
  }
  getUser(){
    return _user;
  }
  getId(){
    return _id;
  }
  getToken(){
    return _token;
  }
  setUser(String user){
    _user = user;
  }

  setPersona(String persona){
    _persona = persona;
  }
  setId(String id){
    _id = id;
  }

  setToken(String token){
    _token = token;
  }
}