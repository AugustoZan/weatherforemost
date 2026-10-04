class ExcepcionApi implements Exception {
  final String mensaje;
  final int? statusCode;
  const ExcepcionApi(this.mensaje, {this.statusCode});
  
  @override
  String toString() => 'Excepción de API: $mensaje';
}

class ExcepcionDeRed implements Exception {
  final String mensaje;
  const ExcepcionDeRed(this.mensaje);

  @override
  String toString() => 'Excepción de red: $mensaje';
}